import { Type } from "typebox";
import { Value } from "typebox/value";
import { kindSchema, type Exam } from "./contracts.ts";

/** Allowlist-only, pure paper-wide projection. Never clone private fields and delete them. */
export function studentProjection(exam: Exam) {
  let idx = 1;
  return {
    id: exam.id, title: exam.title,
    sections: [...exam.sections].sort((a, b) => a.idx - b.idx).map(s => ({
      id: s.id, idx: s.idx, title: s.title, passageMd: s.passageMd,
      questionGroups: [...s.questionGroups].sort((a, b) => a.idx - b.idx).map(g => {
        const startIdx = idx;
        const questions = [...g.questions].sort((a, b) => a.idx - b.idx).map(q => ({
          id: q.id, groupId: q.groupId, idx: idx++, type: q.type, promptMd: q.promptMd,
          ...("sectionId" in q ? { sectionId: q.sectionId as string } : {}),
          ...("skill" in q ? { skill: q.skill as "READING" | "LISTENING" } : {}),
          ...("difficulty" in q ? { difficulty: q.difficulty as number } : {}),
          ...(q.imageUrl ? { imageUrl: q.imageUrl } : {}),
          ...(q.wordList ? { wordList: [...q.wordList] } : {}),
          options: [...q.options].sort((a, b) => a.idx - b.idx).map(o => ({
            id: o.id, idx: o.idx, contentMd: o.contentMd,
            ...(o.imageUrl ? { imageUrl: o.imageUrl, ...(o.altText ? { altText: o.altText } : {}) } : {}),
          })),
          ...(q.type === "FLOW_CHART" ? { flowChartNodes: [...new Set(q.orderCorrects ?? [])].sort().map(key => ({ key, label: key.replace(/-/g, " ").trim() })) } : {}),
        }));
        return { id: g.id, idx: g.idx, startIdx, endIdx: idx - 1, instructionMd: g.instructionMd, questions };
      }),
    })),
  };
}
export const privateKeys = new Set(["isCorrect", "blankAcceptTexts", "blankAcceptRegex", "matchPairs", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex", "modelAnswers", "explanationMd", "evidence", "semanticReviews"]);
export function privatePaths(value: unknown, path = "projection"): string[] {
  if (!value || typeof value !== "object") return [];
  return Object.entries(value).flatMap(([key, child]) => privateKeys.has(key) ? [`${path}.${key}`] : privatePaths(child, `${path}.${key}`));
}
export function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") return `{${Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => `${JSON.stringify(k)}:${stableJson(v)}`).join(",")}}`;
  return JSON.stringify(value);
}

// The public delivery shape is deliberately separate from the key-bearing
// generation schemas. Reuse the canonical type enum, not an arbitrary string.
const strict = { additionalProperties: false } as const;
const id = Type.String({ minLength: 1 });
const idx = Type.Integer({ minimum: 1 });
const text = Type.String();
const publicOption = Type.Object({
  id, idx, contentMd: text,
  imageUrl: Type.Optional(text), altText: Type.Optional(text),
}, strict);
const publicNode = Type.Object({ key: id, label: text }, strict);
const publicQuestion = Type.Object({
  id, groupId: id, idx, type: kindSchema, promptMd: text,
  sectionId: Type.Optional(id), skill: Type.Optional(Type.Union([Type.Literal("READING"), Type.Literal("LISTENING")])),
  difficulty: Type.Optional(Type.Integer({ minimum: 1, maximum: 5 })),
  imageUrl: Type.Optional(text), wordList: Type.Optional(Type.Array(text)),
  options: Type.Array(publicOption),
  flowChartNodes: Type.Optional(Type.Array(publicNode)),
}, strict);
const publicGroup = Type.Object({
  id, idx, startIdx: idx, endIdx: idx, instructionMd: text,
  questions: Type.Array(publicQuestion, { minItems: 1 }),
}, strict);
const publicSection = Type.Object({
  id, idx, title: text, passageMd: text,
  questionGroups: Type.Array(publicGroup, { minItems: 1 }),
}, strict);
const publicExam = Type.Object({
  id, title: text, sections: Type.Array(publicSection, { minItems: 1 }),
}, strict);
const publicProjection = Type.Union([
  publicExam, publicSection, publicGroup, Type.Array(publicGroup, { minItems: 1 }),
]);

export function containsPrivateSentinel(str: string): boolean {
  if (typeof str !== "string") return false;
  if (/PRIVATE-/i.test(str)) return true;
  for (const k of privateKeys) {
    if (k === "evidence") {
      if (/["']?evidence["']?\s*:/i.test(str)) return true;
    } else if (str === k || str.includes(k)) {
      return true;
    }
  }
  // Check for base64 encoded strings
  const b64Matches = str.match(/[A-Za-z0-9+/]{12,}={0,2}/g) || [];
  for (const match of b64Matches) {
    try {
      const decoded = Buffer.from(match, "base64").toString("utf8");
      if (/PRIVATE-/i.test(decoded)) return true;
      for (const k of privateKeys) {
        if (decoded.includes(`"${k}"`) || decoded.includes(`${k}:`) || decoded === k || decoded.includes(k)) return true;
      }
    } catch {}
  }
  // Check for percent encoding
  if (/%[0-9A-Fa-f]{2}/.test(str)) {
    try {
      const decoded = decodeURIComponent(str);
      if (/PRIVATE-/i.test(decoded)) return true;
      for (const k of privateKeys) {
        if (decoded.includes(`"${k}"`) || decoded.includes(`${k}:`) || decoded === k || decoded.includes(k)) return true;
      }
    } catch {}
  }
  // Check for hex encoding (min 16 chars)
  const hexMatches = str.match(/\b[0-9a-fA-F]{16,}\b/g) || [];
  for (const match of hexMatches) {
    try {
      const decoded = Buffer.from(match, "hex").toString("utf8");
      if (/PRIVATE-/i.test(decoded)) return true;
      for (const k of privateKeys) {
        if (decoded.includes(`"${k}"`) || decoded.includes(`${k}:`) || decoded === k || decoded.includes(k)) return true;
      }
    } catch {}
  }
  // Check for embedded JSON with private keys
  if (str.includes("{") && str.includes("}")) {
    for (const k of privateKeys) {
      if (str.includes(`"${k}"`) || str.includes(`${k}:`)) return true;
    }
  }
  return false;
}

function hasPrivateString(value: unknown): boolean {
  if (typeof value === "string") return containsPrivateSentinel(value);
  if (Array.isArray(value)) return value.some(hasPrivateString);
  if (value && typeof value === "object") return Object.values(value).some(hasPrivateString);
  return false;
}

export function validateProjectionCandidate(parsed: unknown): boolean {
  return Value.Check(publicProjection, parsed) && !hasPrivateString(parsed);
}

export function extractMessageText(msg: unknown): string {
  if (!msg || typeof msg !== "object") return "";
  const m = msg as Record<string, unknown>;
  if (typeof m.prompt === "string") return m.prompt;
  if (typeof m.text === "string") return m.text;
  if (typeof m.command === "string") return m.command;
  if (typeof m.output === "string") return m.output;
  if (typeof m.content === "string") return m.content;
  if (Array.isArray(m.content)) {
    return m.content.map(c => {
      if (typeof c === "string") return c;
      if (c && typeof c === "object" && "text" in c && typeof (c as { text: unknown }).text === "string") {
        return (c as { text: string }).text;
      }
      return "";
    }).join(" ");
  }
  return "";
}

export function validateBlindTaskInput(text: string): { ok: boolean; reason?: string } {
  if (typeof text !== "string" || !text.trim()) {
    return { ok: false, reason: "BLIND_INPUT_EMPTY: Task content is empty." };
  }
  const trimmed = text.trim();
  if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
    return { ok: false, reason: "BLIND_INPUT_NOT_JSON: Blind solver requires canonical student projection JSON." };
  }

  let parsed: unknown;
  try {
    parsed = JSON.parse(trimmed);
  } catch {
    return { ok: false, reason: "BLIND_INPUT_MALFORMED: Malformed JSON in blind task." };
  }

  if (!validateProjectionCandidate(parsed)) {
    return { ok: false, reason: "BLIND_INPUT_REJECTED: Structured artifact does not conform to canonical student projection allowlist." };
  }

  return { ok: true };
}
