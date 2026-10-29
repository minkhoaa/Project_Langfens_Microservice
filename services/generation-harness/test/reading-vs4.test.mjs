import './offline.mjs';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { evaluate } from '../.generation/evaluation/report.mjs';
import fixture from '../.generation/evaluation/fixtures/records.mjs';

// A reporter that treats UNCERTAIN or synthetic decisions as approval must fail.
test('held-out synthetic records remain insufficient and expose hierarchy', () => {
  const report = evaluate(fixture);
  assert.equal(report.pilotDecision, 'INSUFFICIENT_EVIDENCE');
  assert.equal(report.evidenceClass, 'SYNTHETIC_NOT_QUALITY_EVIDENCE');
  assert.equal(report.questions.length, 3);
  assert.equal(report.groups.length, 2);
  assert.equal(report.sections.length, 1);
  assert.equal(report.paper.questionCount, 3);
  assert.equal(report.questions[2].verdict, 'UNCERTAIN');
});

test('critical failure overrides incomplete evidence and reports disagreement', () => {
  const input = structuredClone(fixture);
  input.reviews[0].judgments[0] = {criterion:'answerability', verdict:'FAIL', severity:'critical', reason:'No defensible answer.', category:'unanswerable'};
  const r = evaluate(input);
  assert.equal(r.pilotDecision, 'NO-GO');
  assert.equal(r.questions[0].verdict, 'FAIL');
  assert.ok(r.questions[0].disagreements.includes('answerability'));
});

test('rejects duplicate reviewer sessions and incomplete or foreign coverage', () => {
  const input = structuredClone(fixture);
  input.reviews[1].sessionId = input.reviews[0].sessionId;
  assert.throws(() => evaluate(input), /session/i);
  const missing = structuredClone(fixture);
  missing.reviews[0].judgments.pop();
  assert.throws(() => evaluate(missing), /schema|criteria/i);
  const foreign = structuredClone(fixture);
  foreign.solverAnswers[0].questionId = 'foreign';
  assert.throws(() => evaluate(foreign), /coverage/i);
});

test('uncertain and disagreements require independent human adjudication', () => {
  const input = structuredClone(fixture);
  input.evidenceClass = 'REAL_MODEL';
  input.reviews[4].judgments[0].verdict = 'PASS';
  const r = evaluate(input);
  assert.equal(r.questions[2].verdict, 'UNCERTAIN');
  assert.equal(r.pilotDecision, 'INSUFFICIENT_EVIDENCE');
  assert.ok(r.questions[2].disagreements.includes('answerability'));
});
