import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { validateQuestion } from '../question.ts';
import { getQuestionSpec } from '../contract.ts';
import { initialize,inspect,q,vectors,check,hasCode } from './helpers.mjs';
await initialize();
test('all 19 types resolve a focused canonical spec and independently valid example',()=>{
 for(const question of vectors){
  const r=inspect(getQuestionSpec,question.type);assert.equal(r.status,'PASS',question.type);
  assert.equal(r.data.type,question.type);assert.ok(r.data.requiredFields.includes('sectionId'));
  assert.deepEqual(r.data.example,question);assert.equal(r.data.exampleValidity.semantic,'UNVERIFIED');
  assert.equal(r.data.registry,undefined);assert.ok(r.data.fields.options);assert.ok(r.data.semanticConstraints.length);
  assert.equal(check(inspect(validateQuestion,question),'STRUCTURE'),'PASS');
 }
 const r=inspect(getQuestionSpec,'ALIEN');assert.equal(r.status,'FAIL');assert.equal(r.data.availableTypes.length,19);
});
test('every type rejects required unknown null enum and foreign-family mutations',()=>{
 for(const question of vectors) for(const mutate of [x=>delete x.id,x=>x.PRIVATE_SENTINEL='PRIVATE_SENTINEL',x=>x.options=null,x=>x.difficulty=0,x=>x.type='ALIEN',x=>x.skill='WRITING',x=>x.blankAcceptTexts=null]){
  const bad=structuredClone(question);mutate(bad);const result=inspect(validateQuestion,bad);
  assert.equal(result.status,'FAIL',question.type);assert.equal(JSON.stringify(result).includes('PRIVATE_SENTINEL'),false);
 }
 for(const value of [null,[],3,{}, {type:null}]) assert.equal(inspect(validateQuestion,value).status,'FAIL');
});
test('COMMON catches duplicate option identities and contiguous option ordinals',()=>{
 const question=q('MULTIPLE_CHOICE_SINGLE');question.options[1].id=question.options[0].id.toUpperCase();question.options[1].idx=4;
 const r=inspect(validateQuestion,question);assert.ok(hasCode(r,'IDENTITY_DUPLICATE'));assert.ok(hasCode(r,'OPTION_INDEX_COVERAGE'));
 assert.equal(inspect(validateQuestion,q('SHORT_ANSWER')).status,'UNVERIFIED');
});
test('results are deterministic and inputs are never normalized or mutated',()=>{
 for(const question of vectors){const before=structuredClone(question);assert.deepEqual(inspect(validateQuestion,question),inspect(validateQuestion,question));assert.deepEqual(question,before);}
 const wrong=q('MULTIPLE_CHOICE_SINGLE');wrong.idx='1';const r=inspect(validateQuestion,wrong);assert.equal(r.status,'FAIL');assert.equal(wrong.idx,'1');
});
