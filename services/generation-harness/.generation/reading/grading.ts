import { families, sortedKeys, type Answer, type Question } from "./contracts.ts";

// Mirrors TextNorm.Normalize, including its existing compound-number lookahead
// quirks. Do not improve this independently of attempt-service.
const words: Record<string, number> = Object.fromEntries([
  ..."zero one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen".split(" ").map((w, i) => [w, i]),
  ...["twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety"].map((w, i) => [w, (i + 2) * 10]),
  ["hundred", 100], ["thousand", 1000], ["million", 1000000],
]);
// .NET whitespace includes NEXT LINE (U+0085), but not JavaScript's BOM.
const trim = (s: string) => s.replace(/^[\u0009-\u000d\u0085\p{Z}]+|[\u0009-\u000d\u0085\p{Z}]+$/gu, "");
const collapseSpaces = (s: string) => trim(s.replace(/[\u0009-\u000d\u0085\p{Z}]+/gu, " "));
// Shared with canonical option-conflict checks: JavaScript trim() differs from .NET.
export const choiceTextIdentity = (text: string) => trim(text).toLowerCase();
export function normalize(input = ""): string {
  const tokens = collapseSpaces(trim(input).toLowerCase().normalize("NFD").replace(/\p{Mn}/gu, "").normalize("NFC")).split(" ");
  const out: string[] = [];
  for (let i = 0; i < tokens.length;) {
    const w = tokens[i].replace(/^,+|,+$/g, "");
    if (w === "a" && tokens[i + 1] === "hundred") { out.push("100"); i += 2; continue; }
    const val = Object.hasOwn(words, w) ? words[w] : undefined;
    if (val === undefined) { out.push(tokens[i++]); continue; }
    const next = tokens[i + 1], nnext = tokens[i + 2], unit = Object.hasOwn(words, nnext) ? words[nnext] : undefined;
    if (i + 2 < tokens.length && val >= 100 && (next === "and" || !Object.hasOwn(words, next)) && unit !== undefined && unit < 100) {
      out.push(String(val + unit)); i += next === "and" ? 3 : 2;
    } else if (i + 2 < tokens.length && val >= 20 && val < 100 && unit !== undefined && unit < 10) {
      out.push(String(val + unit)); i += 2;
    } else { out.push(String(val)); i++; }
  }
  return out.join(" ");
}
function parse(raw: string): unknown { try { return JSON.parse(raw); } catch { return undefined; } }
function stringMap(value: unknown): value is Record<string, string | null> {
  // System.Text.Json permits null Dictionary<string,string> values, including
  // unrelated extra properties. Numeric/array values instead fail deserialization.
  return typeof value === "object" && value !== null && !Array.isArray(value) && Object.values(value).every(v => v === null || typeof v === "string");
}
const equal = (a: string, b: string) => a.toLowerCase() === b.toLowerCase();
const mapValue = (map: Record<string, string | null>, key: string) => Object.hasOwn(map, key) ? map[key] ?? "" : "";
// Guid.TryParse accepts N/D/B/P/X text forms, not just the JSON wire's D form.
function guidValue(raw: string): string | undefined {
  let value = trim(raw).toLowerCase();
  const compact = value.replace(/[\u0009-\u000d\u0085\p{Z}]+/gu, "");
  const hex = compact.match(/^\{0x([0-9a-f]{1,8}),0x([0-9a-f]{1,4}),0x([0-9a-f]{1,4}),\{0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2}),0x([0-9a-f]{1,2})\}\}$/);
  if (hex) return hex.slice(1).map((part, i) => part.padStart(i === 0 ? 8 : i < 3 ? 4 : 2, "0")).join("");
  const wrapped = (value.startsWith("{") && value.endsWith("}")) || (value.startsWith("(") && value.endsWith(")"));
  if (wrapped) value = value.slice(1, -1);
  if (/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/.test(value)) return value.replaceAll("-", "");
  return !wrapped && /^[0-9a-f]{32}$/.test(value) ? value : undefined;
}
const node = (s: string) => collapseSpaces(s.toLowerCase().replace(/-/g, " ").replace(/[^a-z0-9\u0009-\u000d\u0085\p{Z}]/gu, " "));
export type Grade = { awardedPoints: 0 | 1; isCorrect: boolean | null; needsManualReview: boolean };
export function grade(q: Question, answer: Answer): Grade {
  const result = (ok: boolean): Grade => ({ awardedPoints: ok ? 1 : 0, isCorrect: ok, needsManualReview: false });
  const raw = answer.textAnswer ?? "", family = families[q.type];
  const correct = q.options.filter(o => o.isCorrect);
  if (family === "single") {
    const selected = [...new Set((answer.selectedOptionIds ?? []).map(id => id.toLowerCase()))];
    return result((selected.length === 1 && correct.some(o => equal(o.id, selected[0]))) ||
      (!!trim(raw) && correct.some(o => (guidValue(raw) !== undefined && guidValue(o.id) === guidValue(raw)) || (!!o.contentMd && equal(trim(o.contentMd), trim(raw))))));
  }
  if (family === "multiple") {
    const selected = new Set((answer.selectedOptionIds ?? []).map(id => id.toLowerCase()));
    return result(selected.size === correct.length && correct.every(o => selected.has(o.id.toLowerCase())));
  }
  if (family === "short") return result((q.shortAnswerAcceptTexts ?? []).some(x => normalize(x) === normalize(raw)));
  if (family === "matching") {
    if (!trim(raw)) return result(false);
    const pairs = q.matchPairs ?? {}, entries = Object.entries(pairs);
    const map = parse(trim(raw));
    if (stringMap(map)) return result(entries.length > 0 && entries.every(([key, accepts]) => {
      const value = Object.hasOwn(map, key) ? map[key] : null;
      // Unlike completion normalization, matching distinguishes null from "".
      return value !== null && accepts.some(x => equal(x, value));
    }));
    return result(entries.length === 1 && entries[0][1].some(x => equal(x, trim(raw))));
  }
  if (family === "completion") {
    if (!trim(raw)) return result(false);
    const texts = q.blankAcceptTexts ?? {}, regs = q.blankAcceptRegex ?? {};
    const keys = sortedKeys({ ...texts, ...regs });
    const accepts = (key: string, value: string) => (texts[key] ?? []).some(x => normalize(x) === normalize(value));
    const map = parse(trim(raw));
    if (stringMap(map)) return result(keys.length > 0 && keys.every(key => accepts(key, mapValue(map, key))));
    // Backend adds dictionary counts here, not union cardinality.
    if (Object.keys(texts).length + Object.keys(regs).length === 1) return result(Object.values(texts).flat().some(x => !!trim(x) && normalize(x) === normalize(raw)));
    const parts = trim(raw).split("\n").map(trim);
    return result(keys.length > 0 && keys.every((key, i) => accepts(key, parts[i] ?? "")));
  }
  const expected = (q.orderCorrects ?? []).map(node).filter(Boolean);
  if (!expected.length) return { awardedPoints: 0, isCorrect: null, needsManualReview: true };
  const parsed = parse(raw);
  // Committed legacy oracle is case-sensitive. The pre-existing dirty .NET patch
  // accepts lowercase; reading-dotnet-contract.test.mjs records that divergence.
  const payload = parsed as { Steps?: unknown; Labels?: unknown } | undefined;
  const steps = Array.isArray(parsed) ? parsed : payload?.Steps;
  if (!Array.isArray(parsed) && payload?.Labels !== undefined && payload.Labels !== null && !stringMap(payload.Labels)) return result(false);
  if (!Array.isArray(steps) || steps.some(s => s !== null && typeof s !== "string")) return result(false);
  // List<string> deserialization permits null; the backend filters null/empty nodes.
  const actual = (steps as (string | null)[]).filter((x): x is string => x !== null && x !== "").map(node);
  const labels = stringMap(payload?.Labels) ? payload.Labels : {};
  return result(actual.length === expected.length && actual.every((x, i) => x === expected[i]) &&
    Object.entries(q.blankAcceptTexts ?? {}).every(([k, xs]) => {
      const value = trim(mapValue(labels, k));
      return !!value && xs.some(x => equal(trim(x), value));
    }));
}
// Never silently equate JavaScript RegExp with .NET Regex. The offline parity
// surface fails closed for regex-bearing keys; exact text/JSON/set paths are executable.
export function hasRegex(q: Question) {
  return Object.values(q.blankAcceptRegex ?? {}).some(xs => xs.length > 0) || !!q.shortAnswerAcceptRegex?.length;
}
