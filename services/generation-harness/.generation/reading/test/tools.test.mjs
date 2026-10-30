import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { callTool, createDomain } from '../domain.ts';

const vectors = JSON.parse(readFileSync(new URL('../../contracts/test-vectors/canonical-questions.v1.json', import.meta.url)));
const clone = x => structuredClone(x);
const q = type => clone(vectors.find(q => q.type === type));
const run = (name, args) => callTool(name, args);
const has = (r, code) => r.diagnostics.some(d => d.code === code);
const check = (r, id) => r.checks.find(c => c.id === id)?.status;
const group = () => ({id:'g1', idx:1, questions:[{...q('MULTIPLE_CHOICE_SINGLE'), idx:1}]});
const exam = () => ({id:'e1', sections:[{id:'s1',idx:1,questionGroups:[group()]}]});
const wire = question => ({questionId:question.id, sectionId:'11111111-1111-1111-1111-111111111111', selectedOptionIds:[]});

test('all 19 specs resolve only the requested type with canonical example and provenance', () => {
  for (const question of vectors) {
    const r = run('get_question_spec', {type:question.type});
    assert.equal(r.status,'PASS');
    assert.equal(r.contractVersion,'1.0.0');
    assert.equal(r.data.type,question.type);
    assert.ok(r.data.requiredFields.includes('sectionId'));
    assert.ok(r.data.answerFamily);
    assert.ok(r.data.semanticConstraints.length);
    assert.equal(check(run('validate_question',{question:r.data.example}),'STRUCTURE'),'PASS');
    assert.ok(r.contractHash);
    assert.equal(r.data.registry,undefined);
  }
  const r=run('get_question_spec',{type:'ALIEN'});
  assert.equal(r.status,'FAIL'); assert.equal(r.data.availableTypes.length,19);
});

test('19 positive shapes and negative required/unknown/type/answer-family mutations', () => {
  for (const question of vectors) {
    assert.equal(check(run('validate_question',{question}),'STRUCTURE'),'PASS',question.type);
    for (const mutate of [x=>delete x.id, x=>x.extra='secret', x=>x.difficulty=0, x=>x.type='ALIEN', x=>x.options=null]) {
      const bad=clone(question); mutate(bad);
      const r=run('validate_question',{question:bad}); assert.equal(r.status,'FAIL',question.type);
      assert.ok(r.diagnostics.every(d=>d.path.startsWith('/')));
    }
  }
});

test('all tools return recoverable diagnostics for absent/null/primitive/unknown inputs without leaking payload', () => {
  for (const name of ['get_question_spec','validate_question','validate_group','validate_exam','verify_evidence','check_grading_parity','inspect_delivery_projection']) {
    for (const args of [undefined,null,[],3,{}, {unexpected:'PRIVATE_SENTINEL'}]) {
      const r=run(name,args); assert.equal(r.status,'FAIL',name);
      assert.ok(r.diagnostics.length); assert.ok(!JSON.stringify(r).includes('PRIVATE_SENTINEL'));
      for(const d of r.diagnostics) assert.ok(d.code && d.path && d.message && d.suggestedCorrection);
    }
  }
});

test('input bounds and corrupt/unreadable contracts fail safely', () => {
  let deep={}; let p=deep; for(let i=0;i<80;i++) p=p.child={};
  for(const args of [{question:deep},{question:'x'.repeat(2_100_000)}]) assert.ok(has(run('validate_question',args),'INPUT_LIMIT'));
  const cycle={}; cycle.self=cycle; assert.equal(run('validate_question',{question:cycle}).status,'FAIL');
  const dir=mkdtempSync(join(tmpdir(),'reading-contract-'));
  try {
    const file=join(dir,'bad.json'); writeFileSync(file,'{');
    for(const contractUrl of [file,join(dir,'missing.json')]) {
      const r=createDomain({contractUrl}).call('validate_question',{question:q('SHORT_ANSWER')});
      assert.equal(r.status,'ERROR'); assert.ok(!JSON.stringify(r).includes(dir));
    }
  } finally {rmSync(dir,{recursive:true,force:true});}
});

test('choice identity, contiguous ordinals, duplicate text, cardinality and stated selection count', () => {
  let question=q('MULTIPLE_CHOICE_SINGLE');
  question.options[1].id=question.options[0].id.toUpperCase(); question.options[1].idx=4; question.options[1].contentMd=' river ';
  let r=run('validate_question',{question});
  for(const code of ['IDENTITY_DUPLICATE','OPTION_INDEX_COVERAGE','OPTION_CONTENT_DUPLICATE']) assert.ok(has(r,code),code);
  question=q('MULTIPLE_CHOICE_MULTIPLE'); question.promptMd='Choose THREE answers.';
  assert.ok(has(run('validate_question',{question}),'CHOICE_COUNT_INSTRUCTION_MISMATCH'));
  question.options.forEach(o=>o.isCorrect=true); assert.equal(run('validate_question',{question}).status,'FAIL');
  question=q('TRUE_FALSE_NOT_GIVEN'); question.options[0].contentMd='TRUE'; assert.equal(run('validate_question',{question}).status,'FAIL');
  assert.equal(run('validate_question',{question:q('YES_NO_NOT_GIVEN')}).status,'UNVERIFIED');
});

test('completion exact marker identities independent of question ordinal and Int64 limits', () => {
  let question=q('SENTENCE_COMPLETION'); question.idx=7; question.promptMd='NO MORE THAN TWO WORDS. The river is [23].'; question.blankAcceptTexts={'23':['wide']}; delete question.blankAcceptRegex;
  let r=run('validate_question',{question}); assert.notEqual(r.status,'FAIL');
  question.promptMd+=' Again [23].'; assert.ok(has(run('validate_question',{question}),'BLANK_MARKER_DUPLICATE'));
  question.promptMd='The river is [24].'; r=run('validate_question',{question}); assert.ok(has(r,'BLANK_MARKER_KEY_MISMATCH')); assert.ok(has(r,'WORD_LIMIT_MISSING'));
  question.blankAcceptRegex={'25':['(']}; r=run('validate_question',{question}); assert.ok(has(r,'REGEX_KEY_WITHOUT_TEXT')); assert.ok(has(r,'DOTNET_REGEX_PARITY_UNVERIFIED'));
  question.blankAcceptTexts={'9223372036854775808':['wide']}; assert.ok(has(run('validate_question',{question}),'BLANK_KEY_OVERFLOW'));
  question.blankAcceptTexts={'23':['very wide river']}; question.promptMd='ONE WORD ONLY. River [23].';
  assert.ok(has(run('validate_question',{question}),'WORD_LIMIT_PROFILE_UNVERIFIED'));
});

test('matching key/bank/display parity, no reindexing and permitted reuse is not mandatory', () => {
  let question=q('CLASSIFICATION');
  question.promptMd='Classify each statement.\n23. River transport'; question.matchPairs={'23':['A','River transport']};
  question.options=[{id:'a',idx:1,contentMd:'A. Natural',isCorrect:false},{id:'b',idx:2,contentMd:'B. Artificial',isCorrect:false}];
  let r=run('validate_question',{question}); assert.notEqual(r.status,'FAIL');
  const projected=run('inspect_delivery_projection',{question}); assert.ok(projected.data.studentQuestion.promptMd.includes('23.'));
  question.matchPairs={'22':['Z','Wrong']}; r=run('validate_question',{question});
  assert.ok(has(r,'MATCH_TARGET_KEY_MISMATCH')); assert.ok(has(r,'MATCH_BANK_KEY_UNKNOWN'));
  question=q('MATCHING_INFORMATION'); question.wordList=['river']; assert.ok(has(run('validate_question',{question}),'WORD_BANK_UNSUPPORTED'));
  question=q('MATCHING_FEATURES'); question.promptMd+=' You may use each letter more than once.';
  assert.ok(!has(run('validate_question',{question}),'FEATURE_REUSE_INSTRUCTION_MISMATCH'));
});

test('group membership, bounds, ordering, duplicates and mixed sizes without 13Q assumption', () => {
  let g=group(); let r=run('validate_group',{group:g}); assert.notEqual(r.status,'FAIL'); assert.equal(r.data.questionCount,1);
  g.questions[0].sectionId='other'; g.sectionId='s1'; g.questions[0].groupId='wrong'; g.startIdx=3; g.endIdx=4;
  r=run('validate_group',{group:g}); assert.ok(has(r,'MEMBERSHIP_INVALID')); assert.ok(has(r,'GROUP_BOUNDS_MISMATCH'));
  g=group(); g.questions.push({...q('SHORT_ANSWER'),idx:1,id:g.questions[0].id});
  r=run('validate_group',{group:g}); assert.ok(has(r,'IDENTITY_DUPLICATE')); assert.ok(has(r,'QUESTION_INDEX_COVERAGE'));
});

test('exam draft/complete counts, relationships and scoring units distinct from answer slots', () => {
  let e=exam(); let r=run('validate_exam',{exam:e}); assert.notEqual(r.status,'FAIL'); assert.equal(r.data.scoringUnits,1);
  e.sections[0].questionGroups[0].questions[0].idx=5;
  assert.equal(run('validate_exam',{exam:e}).status,'UNVERIFIED');
  e.complete=true; assert.ok(has(run('validate_exam',{exam:e}),'QUESTION_INDEX_COVERAGE'));
  e=exam(); e.complete=true; e.expectedQuestionCount=40; assert.ok(has(run('validate_exam',{exam:e}),'EXAM_QUESTION_COUNT'));
  e=exam(); e.sections[0].questions=[q('SHORT_ANSWER')]; assert.ok(has(run('validate_exam',{exam:e}),'SECTION_MEMBERSHIP_CONFLICT'));
  e=exam(); e.sections[0].questionGroups[0].questions=[{...q('SENTENCE_COMPLETION'),idx:1}];
  r=run('validate_exam',{exam:e}); assert.equal(r.data.scoringUnits,1); assert.ok(r.data.answerSlots>=1);
  e.sections.push({...clone(e.sections[0]),idx:2}); assert.ok(has(run('validate_exam',{exam:e}),'IDENTITY_DUPLICATE'));
});

test('evidence validates exact UTF-16 spans and references but cannot prove semantics', () => {
  const question=q('TRUE_FALSE_NOT_GIVEN'); const passage={id:'p1',text:'A river flows north.'}; const evidence={sourceId:'p1',questionId:question.id,start:2,end:7,quote:'river'};
  let r=run('verify_evidence',{question,passage,evidence}); assert.equal(r.status,'UNVERIFIED'); assert.equal(check(r,'EVIDENCE_SPAN'),'PASS');
  r=run('verify_evidence',{question,passage,evidence:{...evidence,sourceId:'other',quote:'forest'}});
  assert.ok(has(r,'EVIDENCE_SOURCE_MISMATCH')); assert.ok(has(r,'EVIDENCE_SPAN_MISMATCH'));
  r=run('verify_evidence',{question,passage,evidence:{...evidence,start:-1}}); assert.equal(r.status,'FAIL');
});

test('grading distinguishes serialization, unknown identity, partial/final/clear and actual .NET', () => {
  const question=q('MULTIPLE_CHOICE_SINGLE'); question.sectionId='11111111-1111-1111-1111-111111111111';
  const answer={...wire(question),selectedOptionIds:[question.options[0].id]};
  let r=run('check_grading_parity',{question,submission:answer}); assert.equal(r.status,'UNVERIFIED'); assert.equal(check(r,'ACTUAL_DOTNET'),'UNVERIFIED');
  assert.equal(run('check_grading_parity',{question,submission:{...answer,questionId:'bad'}}).status,'FAIL');
  assert.ok(has(run('check_grading_parity',{question,submission:{...answer,selectedOptionIds:['22222222-2222-2222-2222-222222222222']}}),'SUBMISSION_KEY_MISMATCH'));
  const clear={...wire(question),textAnswer:''}; assert.notEqual(run('check_grading_parity',{question,submission:clear}).status,'FAIL');
  assert.equal(run('check_grading_parity',{question,submission:{state:'final',answer:wire(question)}}).status,'FAIL');
  assert.notEqual(run('check_grading_parity',{question,submission:{state:'autosave',answer:wire(question)}}).status,'FAIL');
});

test('text submission exact keys, malformed JSON, wrong families and restoration identity', () => {
  const question=q('SENTENCE_COMPLETION'); question.sectionId='11111111-1111-1111-1111-111111111111'; question.blankAcceptTexts={'23':['river'],'25':['forest']}; delete question.blankAcceptRegex;
  question.promptMd='TWO WORDS. [23] and [25].';
  const answer={...wire(question),textAnswer:'{"23":"river"}'};
  assert.notEqual(run('check_grading_parity',{question,submission:{state:'autosave',answer}}).status,'FAIL');
  assert.equal(run('check_grading_parity',{question,submission:{state:'final',answer}}).status,'FAIL');
  for(const textAnswer of ['{','{"24":"river"}','["river"]','{"23":null}']) assert.equal(run('check_grading_parity',{question,submission:{...answer,textAnswer}}).status,'FAIL');
  const r=run('check_grading_parity',{question,submission:{state:'restored',answer:{...answer,textAnswer:'{"23":"river","25":"forest"}'}}});
  assert.notEqual(r.status,'FAIL'); assert.ok(has(r,'ROUNDTRIP_UNVERIFIED'));
});

test('public projection preserves media/banks/identities without leaking private data', () => {
  for(const question of vectors.filter(q=>q.type!=='FLOW_CHART')) {
    question.explanationMd='PRIVATE_SENTINEL';
    const r=run('inspect_delivery_projection',{question});
    assert.ok(r.data?.studentQuestion,question.type);
    const student=r.data.studentQuestion;
    assert.equal(student.id,question.id); assert.equal(student.promptMd,question.promptMd);
    assert.equal(student.imageUrl,question.imageUrl);
    assert.ok(!JSON.stringify(r).includes('PRIVATE_SENTINEL'));
    for(const o of student.options) assert.equal(o.isCorrect,undefined);
    assert.equal(check(r,'STUDENT_STRUCTURE'),'PASS',question.type);
  }
  const question=q('MULTIPLE_CHOICE_SINGLE_IMAGE'); question.options[0].altText='PRIVATE_SENTINEL'; delete question.options[0].imageUrl;
  assert.equal(run('inspect_delivery_projection',{question}).status,'FAIL');
});

test('flow never exposes correct order and fails explicitly when public labels unavailable', () => {
  const question=q('FLOW_CHART'); const r=run('inspect_delivery_projection',{question});
  assert.ok(!has(r,'FLOW_COMPLETION_UNSUPPORTED'));
  assert.equal(r.status,'UNVERIFIED');
  if(r.data?.studentQuestion) {
    assert.equal(r.data.studentQuestion.orderCorrects,undefined);
    assert.deepEqual(r.data.studentQuestion.flowChartNodes.map(n=>n.key),[...question.orderCorrects].sort());
  } else assert.ok(has(r,'FLOW_PUBLIC_NODES_UNAVAILABLE'));
});

test('determinism and no mutation across repeated tools', () => {
  for(const question of vectors) {
    const before=clone(question); const a=run('validate_question',{question}); const b=run('validate_question',{question});
    assert.deepEqual(a,b); assert.deepEqual(question,before);
  }
});
