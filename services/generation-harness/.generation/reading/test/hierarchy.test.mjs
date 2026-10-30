import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { validateGroup,validateExam } from '../hierarchy.ts';
import { validateQuestion } from '../question.ts';
import { initialize,inspect,q,group,exam,hasCode } from './helpers.mjs';
await initialize();
test('draft completeness and scoring counts never assume forty Questions',()=>{
 const x=q('SENTENCE_COMPLETION');x.idx=1;x.promptMd='ONE WORD ONLY. [23] and [25].';x.blankAcceptTexts={'23':['river'],'25':['forest']};
 const e=exam([group([x])]);let r=inspect(validateExam,e);assert.equal(r.data.questionCount,1);assert.equal(r.data.answerSlots,2);assert.equal(r.data.scoringUnits,1);
 x.idx=5;assert.equal(inspect(validateExam,e).status,'UNVERIFIED');e.complete=true;assert.ok(hasCode(inspect(validateExam,e),'QUESTION_INDEX_COVERAGE'));
 e.expectedQuestionCount=2;assert.ok(hasCode(inspect(validateExam,e),'EXAM_QUESTION_COUNT'));
});
test('standalone group preserves first index 23 and cannot prove parent existence',()=>{
 const g=group([{...q('SHORT_ANSWER'),idx:23}]);let r=inspect(validateGroup,g);assert.notEqual(r.status,'FAIL');assert.equal(r.data.parentMembership,'UNVERIFIED');
 g.sectionId='other';g.questions[0].groupId='wrong';g.startIdx=24;g.endIdx=25;r=inspect(validateGroup,g);assert.ok(hasCode(r,'MEMBERSHIP_INVALID'));assert.ok(hasCode(r,'GROUP_BOUNDS_MISMATCH'));
});
test('duplicate ownership identities indices and invalid container fields are explicit',()=>{
 const e=exam();e.sections.push({...structuredClone(e.sections[0]),idx:2});const r=inspect(validateExam,e);assert.ok(hasCode(r,'IDENTITY_DUPLICATE'));assert.equal(r.data.scoringUnits,null);
 const g=group();g.questions.push({...q('SHORT_ANSWER'),idx:1,id:g.questions[0].id});assert.ok(hasCode(inspect(validateGroup,g),'QUESTION_INDEX_COVERAGE'));
 for(const bad of [null,{}, {id:'e',sections:null},{id:'e',sections:[],extra:1},{id:'e',sections:[],complete:'true'},{id:'e',sections:[{id:'s',idx:1}]}])assert.equal(inspect(validateExam,bad).status,'FAIL');
});
test('legacy ungrouped Questions are accepted without silently dropping competing content',()=>{
 const x={...q('SHORT_ANSWER'),idx:1};delete x.groupId;
 const e={id:'e',sections:[{id:'s1',idx:1,questions:[x]}]};assert.notEqual(inspect(validateExam,e).status,'FAIL');
 e.sections[0].questionGroups=[group()];assert.ok(hasCode(inspect(validateExam,e),'SECTION_MEMBERSHIP_CONFLICT'));
});
test('word limits account for supplied Section and Group instructions without inferring missing ancestry',()=>{
 const completion=q('DIAGRAM_LABEL');completion.idx=1;completion.promptMd='Label the diagram. [1].';
 const standalone=inspect(validateQuestion,completion);assert.equal(standalone.status,'UNVERIFIED');assert.ok(!hasCode(standalone,'WORD_LIMIT_MISSING'));
 const missingGroup=group([completion]);const missingGroupResult=inspect(validateGroup,missingGroup);assert.equal(missingGroupResult.status,'UNVERIFIED');assert.ok(!hasCode(missingGroupResult,'WORD_LIMIT_MISSING'));
 const g=group([completion]);g.instructionMd='Write NO MORE THAN TWO WORDS.';assert.ok(!hasCode(inspect(validateGroup,g),'WORD_LIMIT_MISSING'));
 const e=exam([g]);e.sections[0].instructionsMd='Write NO MORE THAN TWO WORDS.';assert.ok(!hasCode(inspect(validateExam,e),'WORD_LIMIT_MISSING'));
 const legacy={id:'e1',complete:true,sections:[{id:'s1',idx:1,instructionsMd:'ONE WORD ONLY.',questions:[completion]}]};assert.ok(!hasCode(inspect(validateExam,legacy),'WORD_LIMIT_MISSING'));
 const noLimit=exam([group([completion])]);noLimit.complete=true;assert.ok(hasCode(inspect(validateExam,noLimit),'WORD_LIMIT_MISSING'));
 const conflict=exam([Object.assign(group([completion]),{instructionMd:'ONE WORD ONLY.'})]);conflict.sections[0].instructionsMd='NO MORE THAN TWO WORDS.';const r=inspect(validateExam,conflict);assert.equal(r.status,'UNVERIFIED');assert.ok(!hasCode(r,'WORD_LIMIT_MISSING'));
});
test('unsorted arrays are not silently mutated and Section index policy is not invented',()=>{
 const a={...q('SHORT_ANSWER'),idx:1,id:'a'},b={...q('SHORT_ANSWER'),idx:2,id:'b'};const e=exam([group([b,a])]);e.complete=true;const before=structuredClone(e);
 assert.notEqual(inspect(validateExam,e).status,'FAIL');assert.deepEqual(e,before);
 e.sections[0].idx=-5;assert.ok(hasCode(inspect(validateExam,e),'SECTION_INDEX_POLICY_UNVERIFIED'));
});
test('empty and partial drafts respect only explicitly requested counts',()=>{
 const e={id:'e',sections:[]};assert.equal(inspect(validateExam,e).status,'UNVERIFIED');e.complete=true;assert.equal(inspect(validateExam,e).status,'UNVERIFIED');
 e.expectedQuestionCount=2;assert.equal(inspect(validateExam,e).status,'FAIL');
 const one=exam();one.expectedQuestionCount=2;assert.equal(inspect(validateExam,one).status,'UNVERIFIED');one.expectedQuestionCount=1;assert.notEqual(inspect(validateExam,one).status,'FAIL');
 one.expectedQuestionCount=0;assert.equal(inspect(validateExam,one).status,'FAIL');
});
