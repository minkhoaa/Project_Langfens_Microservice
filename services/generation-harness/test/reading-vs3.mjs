// Registered by reading.test.mjs; uses its existing offline native-session fixture.
import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";
import { fauxAssistantMessage, fauxToolCall } from "generation-ai";
import { executeSubagent } from "generation-subagents";
import { vs2Exam } from "../.generation/fixtures/reading.mjs";
import { vs3Blueprint, vs3Fixture } from "../.generation/fixtures/paper-vs3.mjs";

const clone = structuredClone;
const questions = paper => paper.sections.flatMap(s => s.questionGroups.flatMap(g => g.questions));
const sectionQuestions = s => s.questionGroups.flatMap(g => g.questions);
const codes = r => r.diagnostics.map(d => d.code);
const transcript = child => readFileSync(child.results[0].sessionFile, "utf8").trim().split("\n").map(JSON.parse).filter(e => e.type === "message").map(e => e.message);
const userText = ctx => ctx.messages.filter(m => m.role === "user").map(m => m.content[0].text);
const toolReports = ctx => ctx.messages.filter(m => m.role === "toolResult").map(m => JSON.parse(m.content[0].text));
function requireAnswerCoverage(qs, answers) {
  assert.equal(answers.length, qs.length, "Every scoring unit needs one blind answer record");
  assert.equal(new Set(answers.map(a => a.questionId)).size, qs.length, "Duplicate blind answers");
  assert.deepEqual(answers.map(a => a.questionId).sort(), qs.map(q => q.id).sort(), "Unknown or missing blind answer IDs");
}
// Assertion/aggregation helper only; no runtime, retry, scheduling or model delegation.
async function gradeAll(tools, qs, answers, expected = () => true) {
  requireAnswerCoverage(qs, answers);
  const reports = await tools(qs.map(q => ["check_grading_parity", { question: q, cases: [{
    id: `blind-${q.idx}`, answer: answers.find(a => a.questionId === q.id).answer, expectedCorrect: expected(q),
  }] }]));
  reports.forEach((r, i) => {
    for (const result of r.results ?? []) assert.equal(result.id, `blind-${qs[i].idx}`, "Grade must correlate to the requested scoring unit");
  });
  const scores = { correct: 0, incorrect: 0, ungradable: 0, processed: reports.length, total: qs.length, awardedPoints: 0, possiblePoints: qs.length };
  for (const r of reports) {
    // Invalid keys, unsupported regex or ingestion errors must never count as correct,
    // even when the source-derived backend diagnostic happens to contain a true result.
    const result = r.results?.[0];
    // A disagreement with the caller's expected correctness is a parity FAIL,
    // not an inability to grade a valid answer. Keep those two outcomes separate.
    const invalid = r.nativeError || r.diagnostics?.some(d => d.severity === "error" && d.code !== "GRADING_IELTS_DIVERGENCE");
    if (invalid || !result || result.needsManualReview || result.isCorrect === null) scores.ungradable++;
    else { scores[result.isCorrect ? "correct" : "incorrect"]++; scores.awardedPoints += result.awardedPoints; }
  }
  assert.equal(scores.correct + scores.incorrect + scores.ungradable, scores.total);
  return { scores, reports };
}
function evidenceInput(data, i) {
  return { exam: data.paper, sectionId: data.paper.sections[i].id, evidence: data.evidence[i], blindSolverId: "offline-blind", semanticReviews: [{
    reviewerId: `offline-independent-${i}`, questionIds: sectionQuestions(data.paper.sections[i]).map(q => q.id), verdict: "PASS", rationale: "Mocked section review; no semantic quality assertion.", mocked: true,
  }] };
}
function assertNoOtherSections(ctx, paper, ownIndex) {
  const serialized = JSON.stringify(ctx.messages);
  for (const [i, section] of paper.sections.entries()) {
    if (i !== ownIndex) {
      assert.ok(!serialized.includes(section.passageMd.slice(0, 90)), "Another section's passage contaminated this child");
      assert.ok(!serialized.includes(`PRIVATE-VS3-S${section.idx}-`), "Another section's private key contaminated this child");
    }
  }
}

export function registerVS3Tests({ fixture, names }) {
  test("VS3 fixture blueprint preserves VS2, configures types and distinguishes 40 slots from 40 marks", async t => {
    const { tools } = await fixture(t);
    const data = vs3Fixture();
    assert.deepEqual(data.paper.sections[0], vs2Exam().sections[0]);
    assert.deepEqual(data.paper.sections.map(s => sectionQuestions(s).length), [13, 13, 14]);
    assert.equal(new Set(data.paper.sections.map(s => s.passageMd)).size, 3);
    assert.deepEqual(questions(data.paper).map(q => q.idx), Array.from({ length: 40 }, (_, i) => i + 1));
    for (const config of vs3Blueprint.sections) {
      const groups = data.paper.sections.find(s => s.idx === config.idx).questionGroups;
      assert.deepEqual(groups.map(g => [g.questions[0].type, g.startIdx, g.questions.length]), config.groups.map(g => [g.type, g.start, g.count]));
    }
    const alternate = clone(vs3Blueprint);
    alternate.sections[1].groups[2].type = "NOTE_COMPLETION";
    const alternateData = vs3Fixture(alternate);
    assert.equal(alternateData.paper.sections[1].questionGroups[2].questions[0].type, "NOTE_COMPLETION");
    const [valid, alternateValid, unconstrained, constrained] = await tools([
      ["validate_exam", { exam: data.paper, complete: true, requirements: data.requirements }],
      ["validate_exam", { exam: alternateData.paper, complete: true, requirements: data.requirements }],
      ["validate_exam", { exam: data.paper, complete: true }],
      ["validate_exam", { exam: data.paper, complete: true, requirements: { sectionScoringUnits: [14, 13, 13] } }],
    ]);
    for (const r of [valid, alternateValid, unconstrained]) assert.equal(r.status, "PASS", JSON.stringify(r));
    assert.deepEqual([valid.questionCount, valid.answerSlotCount, valid.scoringUnitCount, valid.questionGroupCount], [40, 40, 40, 11]);
    assert.ok(codes(constrained).includes("SECTION_SCORING_UNIT_COUNT"));
    for (const [i, spans] of data.evidence.entries()) for (const span of spans) {
      assert.ok(sectionQuestions(data.paper.sections[i]).some(q => q.id === span.questionId));
      assert.equal(data.paper.sections[i].passageMd.slice(span.start, span.end), span.quote);
      for (let j = 0; j < 3; j++) if (j !== i) assert.ok(!data.paper.sections[j].passageMd.includes(span.quote));
    }
  });

  test("VS3 rejects incomplete papers, cross-section collisions, wrong memberships, keys and scoring mismatches", async t => {
    const { tools } = await fixture(t);
    const data = vs3Fixture();
    const cases = [];
    function invalid(code, mutate) { const paper = clone(data.paper); mutate(paper); cases.push([code, paper]); }
    invalid("PAPER_SCORING_UNIT_COUNT", p => p.sections[2].questionGroups[3].questions.pop());
    invalid("QUESTION_DUPLICATE", p => p.sections[2].questionGroups[3].questions.push(clone(p.sections[0].questionGroups[0].questions[0])));
    invalid("QUESTION_DUPLICATE", p => p.sections[1].questionGroups[0].questions[0].id = questions(p)[0].id);
    invalid("GROUP_DUPLICATE", p => p.sections[2].questionGroups[0].id = p.sections[0].questionGroups[0].id);
    invalid("OPTION_DUPLICATE", p => p.sections[2].questionGroups[3].questions[0].options[0].id = questions(p)[0].options[0].id);
    invalid("SECTION_INDEX_COVERAGE", p => p.sections[2].id = p.sections[0].id);
    invalid("PAPER_INDEX_COVERAGE", p => p.sections[1].questionGroups[0].questions[0].idx = 1);
    invalid("GROUP_SECTION_MEMBERSHIP", p => p.sections[1].questionGroups[0].sectionId = p.sections[0].id);
    invalid("QUESTION_GROUP_MEMBERSHIP", p => p.sections[2].questionGroups[0].questions[0].groupId = p.sections[0].questionGroups[0].id);
    invalid("CHOICE_KEY_COUNT", p => p.sections[2].questionGroups[3].questions[0].options.forEach(o => o.isCorrect = false));
    invalid("INGESTION_MATCH_PAIR_INVALID", p => p.sections[1].questionGroups[0].questions[0].matchPairs = { "14": ["ii"] });
    invalid("INGESTION_BLANK_KEY_REQUIRED", p => p.sections[2].questionGroups[2].questions[0].blankAcceptTexts = {});
    invalid("ACADEMIC_SECTION_COUNT", p => p.sections.pop());
    invalid("PAPER_ANSWER_SLOT_COUNT", p => {
      const q = p.sections[1].questionGroups[0].questions[0]; q.matchPairs["15"] = ["iv", "Preparing seeds for long storage"];
    });
    // Still 40 slots, but only 39 independently marked Questions.
    invalid("PAPER_SCORING_UNIT_COUNT", p => {
      const g = p.sections[1].questionGroups[2];
      g.questions[0].promptMd += " [22]";
      g.questions[0].blankAcceptTexts["22"] = g.questions[1].blankAcceptTexts["22"];
      g.questions.splice(1, 1);
    });
    const results = await tools(cases.map(([, paper]) => ["validate_exam", { exam: paper, complete: true, requirements: data.requirements }]));
    results.forEach((r, i) => { assert.equal(r.status, "FAIL"); assert.ok(codes(r).includes(cases[i][0]), JSON.stringify(r)); });
    assert.equal(results.at(-1).answerSlotCount, 40);
    assert.equal(results.at(-1).scoringUnitCount, 39);
    const slotMismatch = results.at(-2);
    assert.equal(slotMismatch.scoringUnitCount, 40);
    assert.equal(slotMismatch.answerSlotCount, 41);
    const qs = questions(data.paper);
    for (const bad of [data.answers.slice(1), [...data.answers, data.answers[0]], data.answers.map((a, i) => i === 1 ? data.answers[0] : a), data.answers.map((a, i) => i === 0 ? { ...a, questionId: "foreign" } : a)]) {
      assert.throws(() => requireAnswerCoverage(qs, bad));
    }
    const [contaminatedAnswer, malformedKey, unsupportedRegex, flow] = await tools([
      ["check_grading_parity", { question: qs[37], cases: [{ id: "cross-section-selection", answer: data.answers[0].answer, expectedCorrect: false }] }],
      ["check_grading_parity", { question: { ...qs[13], matchPairs: {} }, cases: [{ id: "empty-key", answer: data.answers[13].answer, expectedCorrect: false }] }],
      ["check_grading_parity", { question: { ...qs[23], shortAnswerAcceptRegex: ["(?i)five years"] }, cases: [{ id: "dotnet-regex", answer: data.answers[23].answer, expectedCorrect: true }] }],
      ["get_question_spec", { type: "FLOW_CHART" }],
    ]);
    assert.ok(codes(contaminatedAnswer).includes("ANSWER_SELECTION_INVALID"));
    assert.equal(contaminatedAnswer.results[0].awardedPoints, 0);
    assert.equal(malformedKey.status, "FAIL");
    assert.ok(codes(malformedKey).includes("INGESTION_MATCH_KEY_REQUIRED"));
    assert.ok(codes(unsupportedRegex).includes("PARITY_REGEX_UNSUPPORTED"));
    assert.equal(flow.ieltsCorrectness, "INCOMPATIBLE_STANDARD_FLOW_COMPLETION");

    // Exercise counters beyond the happy path while still processing all forty answers.
    const mixedQs = clone(qs), mixedAnswers = clone(data.answers);
    mixedAnswers[0].answer = {}; // valid missing input is incorrect, not ungradable
    mixedQs[23].shortAnswerAcceptRegex = ["(?i)five years"]; // fail closed
    const mixed = await gradeAll(tools, mixedQs, mixedAnswers);
    assert.ok(codes(mixed.reports[0]).includes("GRADING_IELTS_DIVERGENCE"), "Wrong but gradable must not become ungradable on parity disagreement");
    assert.deepEqual(mixed.scores, { correct: 38, incorrect: 1, ungradable: 1, processed: 40, total: 40, awardedPoints: 38, possiblePoints: 40 });
    const invalidKeyQs = clone(qs); invalidKeyQs[37].options.forEach(o => o.isCorrect = false);
    const invalidKeyRun = await gradeAll(tools, invalidKeyQs, data.answers, q => q.idx !== 38);
    assert.equal(invalidKeyRun.scores.ungradable, 1);
    assert.equal(invalidKeyRun.scores.awardedPoints, 39);
    t.diagnostic(JSON.stringify({ status: "PASS", mixedGrading: mixed.scores, invalidKeyGrading: invalidKeyRun.scores }));
  });

  test("VS3 section-bound evidence rejects contamination, unknown selectors and non-independent reviews", async t => {
    const { tools } = await fixture(t);
    const data = vs3Fixture();
    const valid = await tools([0, 1, 2].map(i => ["verify_evidence", evidenceInput(data, i)]));
    valid.forEach((r, i) => { assert.equal(r.status, "PASS", JSON.stringify(r)); assert.equal(r.evidenceCount, [13, 13, 14][i]); });
    const cases = [];
    function invalid(code, mutate) { const input = clone(evidenceInput(data, 1)); mutate(input); cases.push([code, input]); }
    invalid("EVIDENCE_QUESTION_UNKNOWN", x => x.evidence[0] = data.evidence[2][0]);
    invalid("EVIDENCE_SPAN_MISMATCH", x => x.evidence[0] = { ...data.evidence[2][0], questionId: x.evidence[0].questionId });
    invalid("EVIDENCE_SPAN_MISMATCH", x => x.exam.sections[1].passageMd = x.exam.sections[2].passageMd);
    invalid("PASSAGE_MISMATCH", x => x.passageMd = x.exam.sections[0].passageMd);
    invalid("SEMANTIC_REVIEW_COVERAGE", x => x.semanticReviews[0].questionIds = sectionQuestions(data.paper.sections[2]).map(q => q.id));
    invalid("REVIEW_NOT_INDEPENDENT", x => x.semanticReviews[0].reviewerId = x.blindSolverId);
    invalid("REVIEW_NOT_INDEPENDENT", x => x.semanticReviews.push(clone(x.semanticReviews[0])));
    invalid("EVIDENCE_SECTION_UNKNOWN", x => x.sectionId = "foreign-section");
    invalid("EVIDENCE_MISSING", x => x.evidence.pop());
    invalid("EVIDENCE_SECTION_TARGET_INVALID", x => { x.groups = x.exam.sections[1].questionGroups; delete x.exam; });
    const results = await tools(cases.map(([, input]) => ["verify_evidence", input]));
    results.forEach((r, i) => { assert.equal(r.status, "FAIL"); assert.ok(codes(r).includes(cases[i][0]), JSON.stringify(r)); });
  });

  test("VS3 private cross-section annotations fail projection inspection and blind launch before model invocation", async t => {
    const { tools, faux, context } = await fixture(t);
    const data = vs3Fixture();
    const [delivery] = await tools([["inspect_delivery_projection", { exam: data.paper }]]);
    assert.equal(delivery.status, "PASS");
    const attacks = [
      p => p.sections[1].passageMd += " PRIVATE-VS3-S3-Q38: secret answer",
      p => p.sections[1].questionGroups[0].questions[0].promptMd += " " + Buffer.from("PRIVATE-VS3-S3-Q38").toString("base64"),
      p => p.sections[2].questionGroups[0].instructionMd += " " + encodeURIComponent('"blankAcceptTexts":{"21":["silica"]}'),
      p => p.sections[1].title += " " + Buffer.from("PRIVATE-VS3-S3-Q38").toString("hex"),
      p => p.sections[2].questionGroups[0].questions[0].modelAnswers = ["answer from another section"],
    ];
    let modelInvocations = 0;
    for (const attack of attacks) {
      const poisoned = clone(delivery.projection); attack(poisoned);
      const [inspection] = await tools([["inspect_delivery_projection", { exam: data.paper, projectionJson: JSON.stringify(poisoned) }]]);
      assert.equal(inspection.status, "FAIL");
      faux.setResponses([() => { modelInvocations++; return fauxAssistantMessage("must not run"); }]);
      const child = await executeSubagent({ agent: "blind-solver", task: JSON.stringify(poisoned) }, context);
      assert.ok(!child.results[0]?.output?.includes("must not run"));
      assert.equal(modelInvocations, 0, "Private cross-section input reached the model");
      assert.ok(!JSON.stringify(child).includes("PRIVATE-VS3"), "Refusal leaked private task data");
    }
    const privatePublicText = clone(data.paper);
    privatePublicText.sections[2].passageMd += " PRIVATE-VS3-S2-Q21";
    const [refused] = await tools([["inspect_delivery_projection", { exam: privatePublicText }]]);
    assert.ok(codes(refused).includes("DELIVERY_PRIVATE_CONTENT"));
  });

  test("VS3 full deterministic paper executes native cross-section handoffs, independent reviews and all 40 blind grades", async t => {
    const { faux, context, tools, session } = await fixture(t);
    const data = vs3Fixture(), generatedPaper = clone(data.paper), children = [];
    const actualToolNames = new Set();
    assert.deepEqual(session.getAllTools().filter(t => names.includes(t.name)).map(t => t.name).sort(), [...names].sort());
    for (const [i, section] of data.paper.sections.entries()) {
      const task = JSON.stringify({ passageMd: section.passageMd, sectionId: section.id, blueprint: vs3Blueprint.sections[i].groups });
      faux.setResponses([
        ctx => {
          assert.deepEqual(userText(ctx), [task]); assertNoOtherSections(ctx, data.paper, i);
          return fauxAssistantMessage([
            ...section.questionGroups.map(g => fauxToolCall("get_question_spec", { type: g.questions[0].type })),
            ...section.questionGroups.map(g => fauxToolCall("validate_group", { group: g })),
          ], { stopReason: "toolUse" });
        },
        ctx => {
          assertNoOtherSections(ctx, data.paper, i);
          assert.ok(toolReports(ctx).every(r => r.status === "PASS"));
          return fauxAssistantMessage(JSON.stringify(section.questionGroups));
        },
      ]);
      const child = await executeSubagent({ agent: "reading-generator", task }, context);
      assert.equal(child.status, "completed", JSON.stringify(child)); children.push(child);
      generatedPaper.sections[i].questionGroups = JSON.parse(child.results[0].output);
    }
    const validatorTask = JSON.stringify({ exam: generatedPaper, requirements: data.requirements });
    faux.setResponses([
      ctx => {
        assert.deepEqual(userText(ctx), [validatorTask]);
        const supplied = JSON.parse(userText(ctx)[0]);
        supplied.exam.sections.forEach((s, i) => assert.deepEqual(s.questionGroups, JSON.parse(children[i].results[0].output)));
        return fauxAssistantMessage([
          fauxToolCall("validate_exam", { ...supplied, complete: true }),
          fauxToolCall("validate_question", { question: questions(supplied.exam)[39] }),
          fauxToolCall("inspect_delivery_projection", { exam: supplied.exam }),
        ], { stopReason: "toolUse" });
      },
      ctx => { const reports = toolReports(ctx); assert.ok(reports.every(r => r.status === "PASS")); return fauxAssistantMessage(JSON.stringify(reports)); },
    ]);
    const validator = await executeSubagent({ agent: "question-validator", task: validatorTask }, context);
    assert.equal(validator.status, "completed", JSON.stringify(validator)); children.push(validator);
    const delivery = JSON.parse(validator.results[0].output).find(r => r.projection);
    assert.equal(delivery.status, "PASS");
    const blindTask = JSON.stringify(delivery.projection);
    const assertBlind = ctx => {
      assert.deepEqual(userText(ctx), [blindTask]);
      for (const token of ["PRIVATE-", "MOCK-VS3-REVIEW-", '"blankAcceptTexts":', '"matchPairs":', '"isCorrect":', '"modelAnswers":']) {
        assert.ok(!JSON.stringify(ctx.messages).includes(token), `Blind context leaked ${token}`);
      }
      assert.deepEqual(ctx.messages.filter(m => m.role === "system").flatMap(m => m.toolsAdded ?? []).map(t => t.name), ["get_question_spec"]);
    };
    faux.setResponses([
      ctx => { assertBlind(ctx); return fauxAssistantMessage(fauxToolCall("get_question_spec", { type: "MATCHING_HEADING" }), { stopReason: "toolUse" }); },
      ctx => { assertBlind(ctx); assert.ok(toolReports(ctx).every(r => r.status === "PASS")); return fauxAssistantMessage(JSON.stringify(data.answers.map(a => ({ ...a, confidence: 1, mocked: true })))); },
    ]);
    const blind = await executeSubagent({ agent: "blind-solver", task: blindTask }, context);
    assert.equal(blind.status, "completed", JSON.stringify(blind)); children.push(blind);
    const blindAnswers = JSON.parse(blind.results[0].output);
    requireAnswerCoverage(questions(generatedPaper), blindAnswers);
    const evidenceReports = [];
    for (const [i, section] of generatedPaper.sections.entries()) {
      const reviewTask = JSON.stringify({ passageMd: section.passageMd, groups: section.questionGroups, evidence: data.evidence[i], mocked: true });
      const reviews = [];
      for (let j = 0; j < 2; j++) {
        faux.setResponses([
          ctx => {
            assert.deepEqual(userText(ctx), [reviewTask]); assertNoOtherSections(ctx, generatedPaper, i);
            assert.ok(!JSON.stringify(ctx.messages).includes('"confidence"'));
            assert.ok(!JSON.stringify(ctx.messages).includes("MOCK-VS3-REVIEW-"));
            return fauxAssistantMessage(fauxToolCall("get_question_spec", { type: section.questionGroups[0].questions[0].type }), { stopReason: "toolUse" });
          },
          ctx => {
            assert.ok(toolReports(ctx).every(r => r.status === "PASS"));
            return fauxAssistantMessage(JSON.stringify({ reviewerId: "untrusted-model-label", questionIds: sectionQuestions(section).map(q => q.id), verdict: "PASS", rationale: `MOCK-VS3-REVIEW-${i}-${j}: section-local deterministic approval only.`, mocked: true }));
          },
        ]);
        const reviewer = await executeSubagent({ agent: "semantic-reviewer", task: reviewTask }, context);
        assert.equal(reviewer.status, "completed", JSON.stringify(reviewer)); children.push(reviewer);
        reviews.push({ ...JSON.parse(reviewer.results[0].output), reviewerId: reviewer.results[0].sessionId });
      }
      const [report] = await tools([["verify_evidence", { exam: generatedPaper, sectionId: section.id, evidence: data.evidence[i], blindSolverId: blind.results[0].sessionId, semanticReviews: reviews }]]);
      assert.equal(report.status, "PASS", JSON.stringify(report));
      assert.equal(report.scoringUnitCount, [13, 13, 14][i]);
      assert.equal(report.semanticReviewCount, 2);
      assert.equal(report.ieltsQualityEstablished, false);
      evidenceReports.push(report);
    }
    const grading = await gradeAll(tools, questions(generatedPaper), blindAnswers);
    assert.ok(grading.reports.every(r => r.status === "PASS"));
    assert.deepEqual(grading.scores, { correct: 40, incorrect: 0, ungradable: 0, processed: 40, total: 40, awardedPoints: 40, possiblePoints: 40 });
    const [complete, projection] = await tools([
      ["validate_exam", { exam: generatedPaper, complete: true, requirements: data.requirements }],
      ["inspect_delivery_projection", { exam: generatedPaper, projectionJson: blindTask }],
    ]);
    assert.equal(complete.status, "PASS"); assert.equal(projection.status, "PASS");
    assert.equal(evidenceReports.reduce((n, r) => n + r.evidenceCount, 0), 40);
    assert.equal(new Set(children.map(c => c.results[0].sessionId)).size, 11);
    for (const child of children) {
      const result = child.results[0];
      assert.notEqual(result.sessionId, context.parentSessionId);
      assert.ok(result.sessionFile.startsWith(context.sessionDir));
      const messages = transcript(child);
      assert.equal(messages.filter(m => m.role === "user").length, 1, "Child inherited parent history");
      const calls = messages.filter(m => m.role === "toolResult" && names.includes(m.toolName));
      assert.ok(calls.length > 0, `No native IELTS result in ${result.agent}`);
      calls.forEach(c => actualToolNames.add(c.toolName));
    }
    // Evidence and parity must be present as actual results in the parent native session.
    const parentResults = session.messages.filter(m => m.role === "toolResult");
    for (const name of ["verify_evidence", "check_grading_parity"]) {
      const results = parentResults.filter(m => m.toolName === name);
      assert.equal(results.length, name === "verify_evidence" ? 3 : 40);
      assert.ok(results.every(r => !r.isError && r.details.status === "PASS"));
      actualToolNames.add(name);
    }
    assert.deepEqual([...actualToolNames].sort(), [...names].sort());
    const blindLog = readFileSync(blind.results[0].sessionFile, "utf8");
    for (const token of ["PRIVATE-", "MOCK-VS3-REVIEW-", '\\"modelAnswers\\":', '\\"isCorrect\\":', '\\"matchPairs\\":', '\\"blankAcceptTexts\\":']) assert.ok(!blindLog.includes(token), `Blind transcript leaked ${token}`);
    // Every validator/blind/reviewer handoff is checked in the persisted native transcript too.
    assert.equal(userText({ messages: transcript(validator) })[0], validatorTask);
    assert.equal(userText({ messages: transcript(blind) })[0], blindTask);
    children.slice(5).forEach((c, index) => {
      const sectionIndex = Math.floor(index / 2);
      const supplied = JSON.parse(userText({ messages: transcript(c) })[0]);
      assert.deepEqual(supplied.groups, generatedPaper.sections[sectionIndex].questionGroups);
      assert.deepEqual(supplied.evidence, data.evidence[sectionIndex]);
      assertNoOtherSections({ messages: transcript(c) }, generatedPaper, sectionIndex);
    });
    t.diagnostic(JSON.stringify({ status: "PASS", mocked: true, semanticQuality: "UNVERIFIED", nativeChildSessionCount: children.length, nativeToolNames: [...actualToolNames].sort(), sections: generatedPaper.sections.map((s, i) => ({ id: s.id, questions: sectionQuestions(s).length, evidence: evidenceReports[i].status })), questionCount: complete.questionCount, answerSlotCount: complete.answerSlotCount, scoringUnitCount: complete.scoringUnitCount, questionGroupCount: complete.questionGroupCount, grading: grading.scores, completePaper: complete.status, studentProjection: projection.status }));
  });
}
