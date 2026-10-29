import './offline.mjs';
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { evaluate } from '../.generation/evaluation/report.mjs';
import fixture from '../.generation/evaluation/fixtures/records.mjs';

// A synthetic or incomplete run must never be mistaken for a real pilot.
test('real-labeled records without raw solver and reviewer call provenance remain insufficient', () => {
  const f=structuredClone(fixture);
  f.evidenceClass='REAL_MODEL';
  f.generator.metadata={provider:'fixture',model:'m',version:'v',prompt:'p',temperature:0,usage:{inputTokens:1,outputTokens:1},latencyMs:1,cost:0,currency:'USD',costBasis:'synthetic'};
  f.reviews.forEach(r=>{r.source='model'; r.judgments.forEach(j=>{j.verdict='PASS'; j.severity='none';});});
  const template=structuredClone(f.artifact.questions[0]);
  for(let i=3;i<13;i++) {
    const id=`q-extra-${i}`;
    f.artifact.questions.push({...template,id});
    f.solverAnswers.push({...f.solverAnswers[0],questionId:id});
    f.reviews.push(...f.reviews.slice(0,2).map((r,j)=>({...structuredClone(r),questionId:id,sessionId:`extra-${i}-${j}`})));
  }
  assert.equal(evaluate(f).pilotDecision,'INSUFFICIENT_EVIDENCE');
});
