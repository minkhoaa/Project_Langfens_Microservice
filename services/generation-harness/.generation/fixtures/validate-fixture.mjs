// Offline validation/grading runner for a canonical exam fixture.
// Uses the extension's own validation + grading sources (no network, no LLM).
import { build } from "esbuild";
import { readFileSync, mkdtempSync, rmSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";

const fixture = process.argv[2] ?? ".generation/fixtures/matching-heading-demo.json";
const dir = mkdtempSync(join(tmpdir(), "ielts-"));
const out = join(dir, "bundle.mjs");
await build({
  stdin: {
    contents: `export * from "./.generation/reading/validation.ts";
export * from "./.generation/reading/grading.ts";`,
    resolveDir: process.cwd(),
    sourcefile: "entry.ts",
    loader: "ts",
  },
  outfile: out,
  bundle: true,
  format: "esm",
  platform: "node",
  logLevel: "silent",
});
const mod = await import(`file://${out}?v=${Date.now()}`);
const { validateExam, validateGroup, validateQuestion, grade, hasRegex } = mod;

const exam = JSON.parse(readFileSync(fixture, "utf8"));
const report = (label, diagnostics) => ({
  label,
  status: diagnostics.some(d => d.severity === "error") ? "FAIL" : "PASS",
  diagnostics,
});

const results = [report("validateExam(complete=false)", validateExam(exam, false))];
for (const s of exam.sections) {
  for (const g of s.questionGroups) {
    results.push(report(`validateGroup(${g.id})`, validateGroup(g)));
    for (const q of g.questions) results.push(report(`validateQuestion(${q.id})`, validateQuestion(q)));
  }
}

// Grading parity for matching questions: canonical answer vs. perturbations.
const grading = [];
for (const s of exam.sections) {
  for (const g of s.questionGroups) {
    for (const q of g.questions) {
      if (!q.matchPairs) continue;
      const canonical = Object.fromEntries(Object.entries(q.matchPairs).map(([k, xs]) => [k, xs[0]]));
      const wrong = Object.fromEntries(Object.entries(q.matchPairs).map(([k, xs]) => [k, k === "A" ? "iii" : xs[0]]));
      grading.push({
        questionId: q.id,
        regexBearing: hasRegex(q),
        canonical: { answer: { textAnswer: JSON.stringify(canonical) }, grade: grade(q, { textAnswer: JSON.stringify(canonical) }) },
        swapped: { answer: { textAnswer: JSON.stringify(wrong) }, grade: grade(q, { textAnswer: JSON.stringify(wrong) }) },
        empty: { answer: { textAnswer: "" }, grade: grade(q, { textAnswer: "" }) },
      });
    }
  }
}
console.log(JSON.stringify({ validation: results, grading }, null, 2));
rmSync(dir, { recursive: true, force: true });
