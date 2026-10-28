import type { Exam } from "./contracts.js";

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
          ...(q.imageUrl ? { imageUrl: q.imageUrl } : {}),
          ...(q.wordList ? { wordList: [...q.wordList] } : {}),
          options: [...q.options].sort((a, b) => a.idx - b.idx).map(o => ({ id: o.id, idx: o.idx, contentMd: o.contentMd })),
          ...(q.type === "FLOW_CHART" ? { flowChartNodes: [...new Set(q.orderCorrects ?? [])].sort().map(key => ({ key, label: key.replace(/-/g, " ").trim() })) } : {}),
        }));
        return { id: g.id, idx: g.idx, startIdx, endIdx: idx - 1, instructionMd: g.instructionMd, questions };
      }),
    })),
  };
}
const privateKeys = new Set(["isCorrect", "blankAcceptTexts", "blankAcceptRegex", "matchPairs", "orderCorrects", "shortAnswerAcceptTexts", "shortAnswerAcceptRegex", "modelAnswers", "explanationMd", "evidence", "semanticReviews"]);
export function privatePaths(value: unknown, path = "projection"): string[] {
  if (!value || typeof value !== "object") return [];
  return Object.entries(value).flatMap(([key, child]) => privateKeys.has(key) ? [`${path}.${key}`] : privatePaths(child, `${path}.${key}`));
}
export function stableJson(value: unknown): string {
  if (Array.isArray(value)) return `[${value.map(stableJson).join(",")}]`;
  if (value && typeof value === "object") return `{${Object.entries(value).sort(([a], [b]) => a.localeCompare(b)).map(([k, v]) => `${JSON.stringify(k)}:${stableJson(v)}`).join(",")}}`;
  return JSON.stringify(value);
}
