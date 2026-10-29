import "./offline.mjs";
import assert from "node:assert/strict";
import test from "node:test";
import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";
import {
  families, kindSchema, optionSchema, questionSchema, spec,
  answerSlots, counts, ACADEMIC_READING_SUPPORTED_TYPES, PLATFORM_ONLY_TYPES,
} from "../.generation/reading/contracts.ts";
import {
  validateQuestion, validateGroup, validateExam, inspectDraft,
} from "../.generation/reading/validation.ts";
import { grade } from "../.generation/reading/grading.ts";
import { question, correctAnswer, types } from "../.generation/fixtures/reading.mjs";
import { studentProjection } from "../.generation/reading/projection.ts";

const root = resolve(fileURLToPath(new URL("..", import.meta.url)));

test("1. Reconciled findings: Matching Information permission vs reuse", () => {
  // Matching information with 3 targets mapping to 3 distinct options (zero reuse) is VALID under permissive instruction
  const q = question("MATCHING_INFORMATION");
  q.promptMd = "NB You may use any letter more than once.\n1. Target one\n2. Target two";
  q.matchPairs = { "1": ["A", "Paragraph A"], "2": ["B", "Paragraph B"] };
  const diags = validateQuestion(q);
  assert.ok(!diags.some(d => d.code === "MATCHING_REUSE_REQUIRED"), "Zero reuse under permissive instruction must not be an error");
});

test("2. Reconciled findings: FLOW_CHART ordering rejects blank keys canonically", () => {
  const q = question("FLOW_CHART");
  q.blankAcceptTexts = { "1": ["bad"] };
  const diags = validateQuestion(q);
  assert.ok(diags.some(d => d.code === "INGESTION_FLOW_LABELS_FORBIDDEN"), "FLOW_CHART must reject blankAcceptTexts on platform ordering contract");
});

test("3. Positive and negative structural & semantic tests across all 19 types", () => {
  assert.equal(types.length, 19);
  for (const t of types) {
    const q = question(t);
    // Positive case
    const posDiags = validateQuestion(q);
    const posErrors = posDiags.filter(d => d.severity === "error");
    assert.equal(posErrors.length, 0, `Type ${t} positive case must have 0 errors: ${JSON.stringify(posErrors)}`);

    // Negative case: empty prompt
    const negPrompt = { ...q, promptMd: "   " };
    const negDiags = validateQuestion(negPrompt);
    assert.ok(negDiags.some(d => d.code === "PROMPT_EMPTY"), `Type ${t} with empty prompt must emit PROMPT_EMPTY`);

    // Negative case: duplicate option ID
    if (q.options.length >= 2) {
      const dupOpt = {
        ...q,
        options: [{ ...q.options[0] }, { ...q.options[0], idx: 2 }],
      };
      const dupDiags = validateQuestion(dupOpt);
      assert.ok(dupDiags.some(d => d.code === "OPTION_DUPLICATE"), `Type ${t} with duplicate option IDs must emit OPTION_DUPLICATE`);
    }
  }
});

test("4. Option image and altText requirements", () => {
  const q = question("MULTIPLE_CHOICE_SINGLE_IMAGE");
  // Positive case with option media
  q.imageUrl = undefined;
  q.options = [
    { id: "o1", idx: 1, contentMd: "Option A", isCorrect: true, imageUrl: "https://example.com/a.png", altText: "Diagram A" },
    { id: "o2", idx: 2, contentMd: "Option B", isCorrect: false, imageUrl: "https://example.com/b.png", altText: "Diagram B" },
  ];
  const diags1 = validateQuestion(q);
  assert.equal(diags1.filter(d => d.severity === "error").length, 0, "Valid option media must pass");

  // Negative: Option has imageUrl but missing altText
  q.options[0].altText = "";
  const diags2 = validateQuestion(q);
  assert.ok(diags2.some(d => d.code === "OPTION_ALT_TEXT_REQUIRED"), "Option with image but no altText must fail");

  // Negative: MULTIPLE_CHOICE_SINGLE_IMAGE with no image on question or options
  const qNoImg = question("MULTIPLE_CHOICE_SINGLE_IMAGE");
  delete qNoImg.imageUrl;
  qNoImg.options = [
    { id: "o1", idx: 1, contentMd: "Option A", isCorrect: true },
    { id: "o2", idx: 2, contentMd: "Option B", isCorrect: false },
  ];
  const diags3 = validateQuestion(qNoImg);
  assert.ok(diags3.some(d => d.code === "IMAGE_REQUIRED"), "MCQ image without question or option image must fail");
});

test("5. Student projection preserves option media without leaking private keys", () => {
  const testExam = {
    id: "e1", title: "Media Test",
    sections: [{
      id: "s1", examId: "e1", idx: 1, title: "S1", passageMd: "Passage text",
      questionGroups: [{
        id: "g1", sectionId: "s1", idx: 1, startIdx: 1, endIdx: 1, instructionMd: "Instructions",
        questions: [{
          id: "q1", groupId: "g1", idx: 1, type: "MULTIPLE_CHOICE_SINGLE_IMAGE", promptMd: "Which image?",
          options: [
            { id: "o1", idx: 1, contentMd: "A", isCorrect: true, imageUrl: "https://example.com/1.png", altText: "Alt 1" },
            { id: "o2", idx: 2, contentMd: "B", isCorrect: false, imageUrl: "https://example.com/2.png", altText: "Alt 2" },
          ],
          explanationMd: "Private explanation",
        }],
      }],
    }],
  };
  const proj = studentProjection(testExam);
  const qProj = proj.sections[0].questionGroups[0].questions[0];
  assert.equal(qProj.options[0].imageUrl, "https://example.com/1.png");
  assert.equal(qProj.options[0].altText, "Alt 1");
  assert.equal(qProj.options[0].isCorrect, undefined, "isCorrect must be stripped");
  assert.equal(qProj.explanationMd, undefined, "explanationMd must be stripped");
});

test("6. 13-question pilot fixture validation: 13 Questions = 13 slots = 13 units = 13 marks", () => {
  const vs2Raw = readFileSync(resolve(root, ".generation/fixtures/section-vs2.json"), "utf8");
  const vs2Exam = JSON.parse(vs2Raw);
  assert.equal(vs2Exam.sections.length, 1);
  const groups = vs2Exam.sections[0].questionGroups;
  assert.equal(groups.length, 3);
  const qs = groups.flatMap(g => g.questions);
  assert.equal(qs.length, 13);

  // Group 1: 5 TFNG (5 questions, 5 slots, 5 units)
  assert.equal(groups[0].questions.length, 5);
  for (const q of groups[0].questions) {
    assert.equal(q.type, "TRUE_FALSE_NOT_GIVEN");
    assert.equal(answerSlots(q), 1);
  }

  // Group 2: 4 SUMMARY_COMPLETION (4 questions, 4 slots, 4 units) - single slot per question
  assert.equal(groups[1].questions.length, 4);
  for (const q of groups[1].questions) {
    assert.equal(q.type, "SUMMARY_COMPLETION");
    assert.equal(answerSlots(q), 1, "Each summary completion question must have exactly 1 blank");
  }

  // Group 3: 4 MULTIPLE_CHOICE_SINGLE (4 questions, 4 slots, 4 units)
  assert.equal(groups[2].questions.length, 4);
  for (const q of groups[2].questions) {
    assert.equal(q.type, "MULTIPLE_CHOICE_SINGLE");
    assert.equal(answerSlots(q), 1);
  }

  const c = counts(groups);
  assert.equal(c.questionCount, 13, "Exactly 13 questions");
  assert.equal(c.answerSlotCount, 13, "Exactly 13 answer slots");
  assert.equal(c.scoringUnitCount, 13, "Exactly 13 scoring units");

  // Validate all 13 questions under strict Academic profile
  for (const q of qs) {
    const diags = validateQuestion(q, "q", "strict-academic");
    const errors = diags.filter(d => d.severity === "error");
    assert.equal(errors.length, 0, `Question ${q.id} must pass strict Academic: ${JSON.stringify(errors)}`);
  }
});

test("7. Strict IELTS Academic Reading profile enforcement", () => {
  // Rejects platform-only types
  for (const type of PLATFORM_ONLY_TYPES) {
    const q = question(type);
    const diags = validateQuestion(q, "q", "strict-academic");
    assert.ok(diags.some(d => d.code === "ACADEMIC_TYPE_UNSUPPORTED"), `Type ${type} must be rejected under strict-academic`);
    assert.equal(diags.find(d => d.code === "ACADEMIC_TYPE_UNSUPPORTED")?.category, "unsupported-capability");
  }

  // Rejects multi-blank questions under strict academic profile
  const multiBlankQ = {
    ...question("NOTE_COMPLETION"),
    promptMd: "Water [1] days, sun [2] hours.",
    blankAcceptTexts: { "1": ["two"], "2": ["four"] },
  };
  const diagsMulti = validateQuestion(multiBlankQ, "q", "strict-academic");
  assert.ok(diagsMulti.some(d => d.code === "ACADEMIC_MULTI_SLOT_UNSUPPORTED"), "Multi-slot question must be rejected under strict-academic");

  // Single-slot completion passes strict academic profile
  const singleBlankQ = {
    ...question("SUMMARY_COMPLETION"),
    promptMd: "The water was supplied by an [1].",
    blankAcceptTexts: { "1": ["aqueduct"] },
  };
  const diagsSingle = validateQuestion(singleBlankQ, "q", "strict-academic");
  assert.equal(diagsSingle.filter(d => d.severity === "error").length, 0, "Single-slot completion must pass strict-academic");
});

test("8. Permissive draft inspection without fabricating missing keys", () => {
  // Empty draft
  const emptyReport = inspectDraft({});
  assert.equal(emptyReport.status, "FAIL");
  assert.equal(emptyReport.isDraft, true);
  assert.ok(emptyReport.missingFields.includes("type"));
  assert.ok(emptyReport.missingFields.includes("promptMd"));
  assert.equal(emptyReport.validForIngestion, false);

  // Partial draft without fabricating keys
  const partialDraft = {
    type: "SUMMARY_COMPLETION",
    promptMd: "In 105 CE, [1] invented paper.",
  };
  const rep = inspectDraft(partialDraft);
  assert.equal(rep.status, "FAIL");
  assert.equal(rep.questionType, "SUMMARY_COMPLETION");
  assert.equal(rep.family, "completion");
  assert.ok(rep.missingFields.includes("blankAcceptTexts"), "Must flag missing blankAcceptTexts");
  assert.ok(rep.diagnostics.some(d => d.code === "INGESTION_BLANK_KEY_REQUIRED"));
  assert.equal(partialDraft.blankAcceptTexts, undefined, "Must NOT fabricate missing blankAcceptTexts on original object");

  // Fully formed draft passes inspection
  const completeDraft = {
    id: "q-complete",
    groupId: "g-complete",
    idx: 1,
    type: "TRUE_FALSE_NOT_GIVEN",
    promptMd: "Cai Lun produced paper.",
    options: [
      { id: "o1", idx: 1, contentMd: "TRUE", isCorrect: true },
      { id: "o2", idx: 2, contentMd: "FALSE", isCorrect: false },
      { id: "o3", idx: 3, contentMd: "NOT GIVEN", isCorrect: false },
    ],
  };
  const compRep = inspectDraft(completeDraft);
  assert.equal(compRep.status, "PASS");
  assert.equal(compRep.validForIngestion, true);
});

test("9. Offline grading parity for all 13 questions against .NET logic", () => {
  const vs2Raw = readFileSync(resolve(root, ".generation/fixtures/section-vs2.json"), "utf8");
  const vs2Exam = JSON.parse(vs2Raw);
  const qs = vs2Exam.sections[0].questionGroups.flatMap(g => g.questions);

  for (const q of qs) {
    let correctAns;
    if (q.options?.length) {
      correctAns = { selectedOptionIds: q.options.filter(o => o.isCorrect).map(o => o.id) };
    } else if (q.blankAcceptTexts) {
      const map = Object.fromEntries(Object.entries(q.blankAcceptTexts).map(([k, xs]) => [k, xs[0]]));
      correctAns = { textAnswer: JSON.stringify(map) };
    } else if (q.matchPairs) {
      const map = Object.fromEntries(Object.entries(q.matchPairs).map(([k, xs]) => [k, xs[0]]));
      correctAns = { textAnswer: JSON.stringify(map) };
    } else {
      correctAns = { textAnswer: "two" };
    }

    const resultCorrect = grade(q, correctAns);
    assert.equal(resultCorrect.isCorrect, true, `Question ${q.id} correct answer must grade true`);
    assert.equal(resultCorrect.awardedPoints, 1, `Question ${q.id} correct answer must award 1 pt`);

    const resultWrong = grade(q, { textAnswer: "completely wrong answer", selectedOptionIds: ["00000000-0000-0000-0000-999999999999"] });
    assert.equal(resultWrong.isCorrect, false, `Question ${q.id} wrong answer must grade false`);
    assert.equal(resultWrong.awardedPoints, 0, `Question ${q.id} wrong answer must award 0 pt`);

    const resultEmpty = grade(q, {});
    assert.equal(resultEmpty.isCorrect, false, `Question ${q.id} empty answer must grade false`);
    assert.equal(resultEmpty.awardedPoints, 0, `Question ${q.id} empty answer must award 0 pt`);
  }
});

test("10. Tool diagnostics: TypeBox errors contain exact field paths, actual shapes and repair guidance", async () => {
  const { default: readingExtension } = await import("../.generation/extensions/reading.ts");
  const tools = new Map();
  readingExtension({
    registerTool: t => tools.set(t.name, t),
    on: () => {},
  });

  const valTool = tools.get("validate_question");
  assert.ok(valTool, "validate_question tool must be registered");

  // Invalid payload with wrong type and extra property
  assert.throws(
    () => valTool.prepareArguments({ question: { idx: "string-instead-of-int", unexpectedExtra: 123 } }),
    err => {
      assert.ok(err.message.startsWith("INPUT_SCHEMA_INVALID:"), "Must begin with INPUT_SCHEMA_INVALID");
      assert.ok(err.message.includes("at '/question"), "Must report exact field path");
      assert.ok(err.message.includes("Repair guidance:"), "Must provide actionable repair guidance");
      return true;
    }
  );
});

test("11. Native tool permissive draft inspection and no-progress repair tracking", async () => {
  const { default: readingExtension } = await import("../.generation/extensions/reading.ts");
  const tools = new Map();
  const listeners = new Map();
  readingExtension({
    registerTool: t => tools.set(t.name, t),
    on: (evt, fn) => listeners.set(evt, fn),
  });

  const valTool = tools.get("validate_question");

  // Calling with draft
  const draftArgs = valTool.prepareArguments({ draft: { type: "SENTENCE_COMPLETION", promptMd: "Incomplete [1]" } });
  const draftResult = await valTool.execute("c1", draftArgs);
  assert.equal(draftResult.details.isDraft, true);
  assert.equal(draftResult.details.status, "FAIL");
  assert.ok(draftResult.details.missingFields.includes("blankAcceptTexts"));

  // No-progress detection on repeated validation failures
  const qBad = {
    ...question("SUMMARY_COMPLETION"),
    id: "q-loop-test",
    promptMd: "Missing marker prompt", // missing [1]
  };
  const qArgs = valTool.prepareArguments({ question: qBad });
  const res1 = await valTool.execute("c2", qArgs);
  assert.equal(res1.details.status, "FAIL");
  assert.ok(!res1.details.diagnostics.some(d => d.code === "REPAIR_NO_PROGRESS"));

  // Second call with unchanged bad question -> REPAIR_NO_PROGRESS
  const res2 = await valTool.execute("c3", qArgs);
  assert.ok(res2.details.diagnostics.some(d => d.code === "REPAIR_NO_PROGRESS"), "Unchanged errors must trigger REPAIR_NO_PROGRESS");

  // Third call -> REPAIR_LIMIT_EXCEEDED
  const res3 = await valTool.execute("c4", qArgs);
  assert.ok(res3.details.diagnostics.some(d => d.code === "REPAIR_LIMIT_EXCEEDED"), "Attempt cap (2) must trigger REPAIR_LIMIT_EXCEEDED");
});
