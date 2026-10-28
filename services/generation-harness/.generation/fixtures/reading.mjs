// Deterministic fixtures, not examples of real IELTS quality.
export const types = [
  "MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN", "MULTIPLE_CHOICE_SINGLE_IMAGE",
  "SUMMARY_COMPLETION", "TABLE_COMPLETION", "NOTE_COMPLETION", "FORM_COMPLETION", "SENTENCE_COMPLETION", "SHORT_ANSWER",
  "DIAGRAM_LABEL", "MAP_LABEL", "MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION", "FLOW_CHART",
];
export const uuid = n => `00000000-0000-0000-0000-${String(n).padStart(12, "0")}`;
export function question(type, idx = 1, groupId = "g1") {
  const q = { id: uuid(idx), groupId, idx, type, promptMd: "The plants are watered every [1] days.", options: [], explanationMd: "PRIVATE-EXPLANATION-SENTINEL", modelAnswers: ["PRIVATE-MODEL-ANSWER-SENTINEL"] };
  if (["MULTIPLE_CHOICE_SINGLE", "MULTIPLE_CHOICE_MULTIPLE", "MULTIPLE_CHOICE_SINGLE_IMAGE", "TRUE_FALSE_NOT_GIVEN", "YES_NO_NOT_GIVEN"].includes(type)) {
    const labels = type === "TRUE_FALSE_NOT_GIVEN" ? ["TRUE", "FALSE", "NOT GIVEN"] : type === "YES_NO_NOT_GIVEN" ? ["YES", "NO", "NOT GIVEN"] : ["Two days", "Three days", "Four days"];
    q.promptMd = "How often are the plants watered?";
    q.options = labels.map((contentMd, i) => ({ id: uuid(1000 + idx * 10 + i), idx: i + 1, contentMd, isCorrect: i === 0 || (i === 1 && type === "MULTIPLE_CHOICE_MULTIPLE") }));
    if (type === "MULTIPLE_CHOICE_SINGLE_IMAGE") q.imageUrl = "fixtures/plant.svg";
  } else if (type === "SHORT_ANSWER") q.shortAnswerAcceptTexts = ["two"];
  else if (["MATCHING_HEADING", "MATCHING_INFORMATION", "MATCHING_FEATURES", "MATCHING_ENDINGS", "CLASSIFICATION"].includes(type)) {
    q.promptMd = "Match statement 1 to heading A (Watering) or B (Harvest).";
    q.matchPairs = { "1": ["A", "Watering"] };
  } else if (type === "FLOW_CHART") {
    q.promptMd = "Arrange nodes: water, plant, harvest.";
    q.orderCorrects = ["plant", "water", "harvest"];
  } else q.blankAcceptTexts = { "1": ["two"] };
  return q;
}
export function group(questions = [question("SUMMARY_COMPLETION")], id = "g1", sectionId = "s1") {
  return { id, sectionId, idx: 1, startIdx: questions[0]?.idx ?? 1, endIdx: questions.at(-1)?.idx ?? 1, instructionMd: "Write ONE WORD for each answer.", questions };
}
export const passageMd = "In the glasshouse, the plants are watered every two days. The harvest begins in June.";
export function exam(g = group()) {
  return { id: "e1", title: "Offline Reading fixture", sections: [{ id: "s1", examId: "e1", idx: 1, title: "Glasshouse", passageMd, questionGroups: [g] }] };
}
export function completeExam() {
  let idx = 1;
  return { id: "e1", title: "Complete offline paper", sections: [14, 13, 13].map((n, i) => {
    const sid = `s${i + 1}`, gid = `g${i + 1}`;
    const questions = Array.from({ length: n }, () => question("SUMMARY_COMPLETION", idx++, gid));
    return { id: sid, examId: "e1", idx: i + 1, title: sid, passageMd, questionGroups: [group(questions, gid, sid)] };
  }) };
}
export function correctAnswer(q) {
  if (q.options.length) return { selectedOptionIds: q.options.filter(o => o.isCorrect).map(o => o.id) };
  if (q.matchPairs) return { textAnswer: JSON.stringify(Object.fromEntries(Object.entries(q.matchPairs).map(([k, xs]) => [k, xs[0]]))) };
  if (q.orderCorrects) return { textAnswer: JSON.stringify(q.orderCorrects) };
  return { textAnswer: "two" };
}
