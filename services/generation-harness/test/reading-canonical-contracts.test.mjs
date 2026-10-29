import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { Value } from 'typebox/value';
import { canonicalQuestion, canonicalPilot } from '../.generation/fixtures/canonical-v1.mjs';
import { canonicalSchema, canonicalValidators, semanticRules, validateCanonicalQuestion, validateCanonicalExam } from '../.generation/reading/canonical.ts';
import { families, diagnostic } from '../.generation/reading/contracts.ts';
import { inspectDraft } from '../.generation/reading/validation.ts';
import { QuestionRepairPolicy } from '../.generation/reading/repair-policy.ts';
import reading from '../.generation/extensions/reading.ts';
import { studentProjection, validateBlindTaskInput } from '../.generation/reading/projection.ts';

const errors = r => r.diagnostics.filter(d => d.severity === 'error');
const clone = structuredClone;
for (const type of Object.keys(families)) {
  test(`canonical v1 ${type}: positive, missing, wrong shape and contradictory semantics`, () => {
    const q = canonicalQuestion(type);
    assert.equal(Value.Check(canonicalSchema, q), true);
    assert.deepEqual(errors(validateCanonicalQuestion(q)), [], JSON.stringify(validateCanonicalQuestion(q)));
    assert.equal(validateCanonicalQuestion(q).ieltsQualityEstablished, false);
    assert.equal(validateCanonicalQuestion(q).compatibility, 'UNVERIFIED');
    for (const bad of [{ ...q, idx: '1' }, { ...q, options: null }, { ...q, privateUnknown: true }, { ...q, promptMd: null }]) {
      assert.equal(Value.Check(canonicalSchema, bad), false);
      assert.equal(validateCanonicalQuestion(bad).structuralStatus, 'FAIL');
    }
    const missing = clone(q); delete missing.sectionId;
    assert.equal(validateCanonicalQuestion(missing).status, 'FAIL');
    const missingKey=clone(q),family=families[type];
    if (family === 'single' || family === 'multiple') missingKey.options.forEach(o=>o.isCorrect=false);
    else delete missingKey[{completion:'blankAcceptTexts',matching:'matchPairs',flow:'orderCorrects',short:'shortAnswerAcceptTexts'}[family]];
    assert.equal(validateCanonicalQuestion(missingKey).structuralStatus,'FAIL',`${type} requires its own key family`);
    const unrelated=clone(q);unrelated[family==='short'?'orderCorrects':'shortAnswerAcceptTexts']=[];
    assert.equal(validateCanonicalQuestion(unrelated).structuralStatus,'FAIL','unrelated empty key families must be absent, not silently ignored');
    const bad = clone(q);
    if (families[type] === 'completion') bad.promptMd = 'Write ONE WORD ONLY. A missing blank.';
    else if (families[type] === 'flow') bad.promptMd = `Correct order: ${bad.orderCorrects.join(' -> ')}`;
    else if (families[type] === 'short') bad.skill = 'LISTENING';
    else if (families[type] === 'matching') bad.promptMd = '23. Wrong visible statement';
    else bad.options[1].idx = 1;
    assert.equal(Value.Check(canonicalSchema, bad), true, 'semantic contradiction must be structurally valid');
    const negative = validateCanonicalQuestion(bad, families[type] === 'short' ? {profile:'strict-academic'} : {});
    assert.ok(errors(negative).length > 0, JSON.stringify(negative));
  });
}

test('19 literal schemas and every normative semantic rule have executable implementations', () => {
  assert.deepEqual(Object.keys(canonicalValidators), Object.keys(families));
  assert.deepEqual(Object.keys(semanticRules).sort(), Object.keys(canonicalSchema['x-langfens'].semanticRules).sort());
  for (const [type, v] of Object.entries(canonicalValidators)) {
    assert.deepEqual(v.rules, canonicalSchema['x-langfens'].registry[type].rules);
    assert.equal(v.schema.$ref, `#/$defs/${type}`);
  }
  for (const type of ['constructor', '__proto__', 'toString', 'WRITING', 'SUMMARY_COMPLETION_BOX']) assert.equal(validateCanonicalQuestion({ type }).status, 'FAIL');
});

test('reuse is permission, not an obligation; illegal repetition and headings/endings still fail', () => {
  const q = canonicalQuestion('MATCHING_INFORMATION');
  assert.equal(validateCanonicalQuestion(q).status, 'PASS');
  q.matchPairs['2'][0] = 'A';
  assert.equal(validateCanonicalQuestion(q).status, 'PASS');
  q.promptMd = q.promptMd.replace('You may use any letter more than once.', 'Use each letter only once.');
  assert.ok(errors(validateCanonicalQuestion(q)).some(d => d.code === 'REUSE_INSTRUCTION_MISMATCH'));
  for (const type of ['MATCHING_HEADING', 'MATCHING_ENDINGS']) {
    const v = canonicalQuestion(type); v.matchPairs['2'][0] = v.matchPairs['1'][0];
    assert.ok(errors(validateCanonicalQuestion(v)).some(d => /REUSED$/.test(d.code)));
  }
});

test('strict profile is separate; all-or-nothing multislot and FLOW blank conversion are blocked', () => {
  for (const type of Object.keys(families)) {
    const q = canonicalQuestion(type), r = validateCanonicalQuestion(q, { profile: 'strict-academic' });
    if (['MULTIPLE_CHOICE_MULTIPLE', 'MAP_LABEL', 'FORM_COMPLETION', 'FLOW_CHART', 'MULTIPLE_CHOICE_SINGLE_IMAGE'].includes(type) || families[type] === 'matching') {
      assert.equal(r.status, 'FAIL', type);
      assert.ok(errors(r).some(d => d.category === 'unsupported-capability'));
    } else assert.equal(r.status, 'PASS', JSON.stringify(r));
  }
  const distinctFlow = canonicalQuestion('FLOW_CHART');distinctFlow.orderCorrects = ['a-b','ab'];
  assert.equal(validateCanonicalQuestion(distinctFlow).status,'PASS','NormNode preserves word boundaries, so a-b and ab do not collide');
  const q = canonicalQuestion('FLOW_CHART'); q.blankAcceptTexts = { '1': ['river'] };
  assert.equal(validateCanonicalQuestion(q).structuralStatus, 'FAIL');
  const regex = canonicalQuestion('SHORT_ANSWER'); regex.shortAnswerAcceptRegex = ['(?i)river'];
  assert.ok(errors(validateCanonicalQuestion(regex)).some(d => d.code === 'DOTNET_REGEX_PARITY_UNVERIFIED'));
});

test('group-first 13-question pilot: 13 independent units/slots/intended marks; no consumer claim', () => {
  const pilot = canonicalPilot(), r = validateCanonicalExam(pilot, false, 'strict-academic');
  assert.equal(r.status, 'PASS', JSON.stringify(errors(r)));
  assert.deepEqual([r.questionCount, r.scoringUnitCount, r.answerSlotCount, r.intendedMarkCount], [13,13,13,13]);
  assert.equal(r.compatibility, 'UNVERIFIED');
  const bad = clone(pilot); bad.sections[0].questionGroups[1].questions[0].sectionId = 'foreign';
  assert.ok(errors(validateCanonicalExam(bad, false, 'strict-academic')).some(d => d.code === 'MEMBERSHIP_INVALID'));
  const strict = validateCanonicalExam(pilot, true, 'strict-academic');
  assert.ok(errors(strict).some(d => d.code === 'PAPER_SCORING_UNIT_COUNT'));
  // Reference fixtures are not automatically forced into a three-section forty-item Academic paper.
  assert.ok(!errors(validateCanonicalExam(pilot, true, 'platform-reference')).some(d => d.code === 'PAPER_SCORING_UNIT_COUNT'));
});

test('canonical student projection preserves v1 public metadata and strict-blind shape without private keys', async () => {
  const pilot = canonicalPilot(), projected = studentProjection(pilot);
  const schema = { $defs: canonicalSchema.$defs, $ref:'#/$defs/StudentQuestion' };
  for (const q of projected.sections.flatMap(s=>s.questionGroups.flatMap(g=>g.questions))) {
    assert.equal(Value.Check(schema,q),true);
    assert.equal(q.skill,'READING');assert.equal(q.sectionId,'s1');assert.equal(q.difficulty,2);
    assert.equal('explanationMd' in q,false);assert.equal('modelAnswers' in q,false);
  }
  assert.equal(validateBlindTaskInput(JSON.stringify(projected)).ok,true);
  const tools = new Map();reading({registerTool:t=>tools.set(t.name,t),on:()=>{}});
  const tool=tools.get('inspect_delivery_projection');
  const r=await tool.execute('p',tool.prepareArguments({canonicalExam:pilot}));
  assert.equal(r.details.status,'PASS');assert.deepEqual(r.details.projection,projected);
});

test('permissive drafts never throw or invent keys and cannot mislabel malformed inputs ingestion-ready', () => {
  for (const value of [null, [], 1, {}, { type: 'constructor' }, { type: 'MULTIPLE_CHOICE_SINGLE', options: [null, 3] }, { type:'SUMMARY_COMPLETION', promptMd:'[1]', blankAcceptTexts: [] }, { ...canonicalQuestion('SHORT_ANSWER'), idx: 1.5 }]) {
    const before = JSON.stringify(value), r = inspectDraft(value);
    assert.equal(r.validForIngestion, false);
    assert.equal(JSON.stringify(value), before);
  }
});

test('TypeBox native diagnostics include field pointers, expected/actual shapes; seven names remain', async () => {
  const tools = new Map(), handlers = new Map();
  reading({ registerTool: t => tools.set(t.name,t), on: (e,f) => handlers.set(e,f) });
  assert.equal(tools.size, 7);
  const v = tools.get('validate_question');
  assert.throws(() => v.prepareArguments({ question: { idx: '1' } }), /expected.*actual.*Repair guidance:/s);
  for (const args of [{}, { draft: {}, question: {} }]) await assert.rejects(() => v.execute('a', args), /INPUT_SCHEMA_INVALID/);
  const q = canonicalQuestion('SUMMARY_COMPLETION');
  const result = await v.execute('b', v.prepareArguments({ canonicalQuestion:q, profile:'strict-academic' }));
  assert.equal(result.details.status, 'PASS');
  assert.equal(result.details.dotnetVerified, false);
});

test('public session_start restores native validation repair receipts on resume', async () => {
  const tools=new Map(),events=new Map();
  reading({registerTool:t=>tools.set(t.name,t),on:(name,fn)=>events.set(name,fn)});
  const q=canonicalQuestion('SUMMARY_COMPLETION');q.promptMd='Write ONE WORD ONLY. Missing marker.';
  const v=tools.get('validate_question'),args={canonicalQuestion:q};
  await v.execute('first',args);const stopped=await v.execute('second',args);
  const restoredTools=new Map(),restoredEvents=new Map();
  reading({registerTool:t=>restoredTools.set(t.name,t),on:(name,fn)=>restoredEvents.set(name,fn)});
  restoredEvents.get('session_start')({}, {sessionManager:{getEntries:()=>[{type:'message',message:{role:'toolResult',toolName:'validate_question',details:stopped.details}}]}});
  q.promptMd='Write ONE WORD ONLY. Water from [1].';
  const after=await restoredTools.get('validate_question').execute('resumed',{canonicalQuestion:q});
  assert.ok(after.details.diagnostics.some(d=>d.code==='REPAIR_LIMIT_EXCEEDED'));
});

test('question-local budget compares consecutive signatures, stops no-progress, restores on resume, never retries capability blockers', () => {
  const policy = new QuestionRepairPolicy(), q = canonicalQuestion('SUMMARY_COMPLETION');
  const ds = code => [diagnostic(code, '/promptMd', code)];
  assert.equal(policy.check(q, ds('A')).repairState.attempts, 0);
  assert.equal(policy.check(q, ds('B')).repairState.attempts, 1);
  const capped = policy.check(q, ds('C'));
  assert.equal(capped.repairState.attempts, 2);
  assert.equal(capped.repairState.stopped, true);
  const resumed = new QuestionRepairPolicy(); resumed.restore(capped.repairState);
  assert.ok(resumed.check(q, []).diagnostics.some(d => d.code === 'REPAIR_LIMIT_EXCEEDED'));
  const p = new QuestionRepairPolicy(); p.check(q, ds('A')); p.check(q, ds('B'));
  assert.ok(p.check(q, ds('B')).diagnostics.some(d => d.code === 'REPAIR_NO_PROGRESS'));
  const success = new QuestionRepairPolicy();success.check(q,ds('A'));success.check(q,ds('B'));
  const resolved=success.check(q,[]);assert.equal(resolved.repairState.attempts,2);assert.match(resolved.repairState.reason,/Two repair submissions/);
  assert.ok(!success.check(q,[]).diagnostics.some(d=>d.message.includes('undefined')));
  const isolated = new QuestionRepairPolicy(); isolated.check(q, ds('A'));
  assert.equal(isolated.check({...q,id:'other'}, ds('A')).repairState.attempts, 0);
  const blocked = new QuestionRepairPolicy();
  const b = blocked.check(q, [diagnostic('BLOCKED', '/', 'capability', 'error', 'unsupported-capability')]);
  assert.equal(b.repairState.stopped, true); assert.equal(b.repairState.attempts, 0);
  assert.ok(blocked.check(q, []).diagnostics.some(d => d.code === 'REPAIR_LIMIT_EXCEEDED'));
});
