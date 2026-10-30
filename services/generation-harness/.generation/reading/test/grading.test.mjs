import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { checkGradingParity } from '../grading.ts';
import { parseAnswerJson } from '../json-answer.ts';
import { createReport } from '../support.ts';
import { initialize,inspect,q,wire,hasCode,check,gradingCases } from './helpers.mjs';
await initialize();
const persisted=type=>({...q(type),sectionId:'11111111-1111-1111-1111-111111111111'});
test('partial final empty clear and wrong-but-valid answers remain distinct',()=>{
 const x=persisted('MULTIPLE_CHOICE_SINGLE'),empty=wire(x);
 const partial=inspect(checkGradingParity,x,{state:'autosave',answer:empty});assert.equal(partial.data.serializationStatus,'PASS');assert.equal(partial.data.operation,'empty');
 assert.equal(inspect(checkGradingParity,x,{state:'final',answer:empty}).data.completenessStatus,'FAIL');
 assert.equal(inspect(checkGradingParity,x,{...empty,textAnswer:''}).data.operation,'clear');
 const wrong=wire(x,{selectedOptionIds:[x.options[1].id]});const r=inspect(checkGradingParity,x,wrong);assert.equal(r.data.serializationStatus,'PASS');assert.equal(r.data.actualDotnet.status,'UNVERIFIED');
});
test('duplicate escaped-equivalent JSON keys and bounded malformed documents fail safely',()=>{
 for(const text of ['{"23":"a","\\u0032\\u0033":"b"}','{"x":{"a":1,"a":2}}']){const r=createReport();assert.equal(parseAnswerJson(r,text,'/submission/textAnswer').valid,false);assert.ok(hasCode(r.finish(),'SUBMISSION_JSON_DUPLICATE_KEY'));}
 for(const text of ['{','[1,]','["bad\\q"]','['.repeat(34)+'0'+']'.repeat(34),'[1e999]']){const r=createReport();assert.equal(parseAnswerJson(r,text,'/submission/textAnswer').valid,false);}
});
test('exact blank keys partial snapshots final completeness and restoration are preserved',()=>{
 const x=persisted('SENTENCE_COMPLETION');x.blankAcceptTexts={'23':['river'],'25':['forest']};x.promptMd='TWO WORDS. [23] and [25].';
 const answer=wire(x,{textAnswer:'{"23":"river"}'});
 assert.equal(inspect(checkGradingParity,x,{state:'autosave',answer}).data.serializationStatus,'PASS');
 assert.equal(inspect(checkGradingParity,x,{state:'final',answer}).data.completenessStatus,'FAIL');
 for(const textAnswer of ['{','{"24":"river"}','["river"]','{"23":null}'])assert.equal(inspect(checkGradingParity,x,{...answer,textAnswer}).status,'FAIL');
 assert.equal(inspect(checkGradingParity,x,{state:'restored',answer:{...answer,textAnswer:'{"23":"river","25":"forest"}'}}).data.serializationStatus,'PASS');
});
test('submission UUIDs unknown fields mappings and family identities fail explicitly',()=>{
 const x=persisted('MULTIPLE_CHOICE_SINGLE');
 for(const fields of [{questionId:'bad'},{selectedOptionIds:['22222222-2222-2222-2222-222222222222']},{textAnswer:null},{extra:1},{selectedOptionIds:[x.options[0].id,x.options[0].id.toUpperCase()]}])assert.equal(inspect(checkGradingParity,x,wire(x,fields)).status,'FAIL');
 const local={...x,id:'local'};assert.ok(hasCode(inspect(checkGradingParity,local,wire(x)),'SUBMISSION_ID_UNMAPPED'));
});
test('matching answers use canonical bank keys and flow sequences never get sorted',()=>{
 const x=persisted('CLASSIFICATION');const answer=wire(x,{textAnswer:'{"1":"A","2":"B"}'});assert.equal(inspect(checkGradingParity,x,{state:'final',answer}).data.serializationStatus,'PASS');
 answer.textAnswer='{"1":"Target one","2":"B"}';assert.equal(inspect(checkGradingParity,x,answer).status,'FAIL');
 const f=persisted('FLOW_CHART'),a=wire(f,{textAnswer:'["heat-water","collect-water"]'}),before=structuredClone(a);assert.equal(inspect(checkGradingParity,f,{state:'restored',answer:a}).data.serializationStatus,'PASS');assert.deepEqual(a,before);
});
test('all 82 authoritative grading vectors are classified without claiming executed grades',()=>{
 assert.equal(gradingCases.length,82);
 for(const fixture of gradingCases){const x={...structuredClone(fixture.question),sectionId:'11111111-1111-1111-1111-111111111111'};
  // Explicit synthetic test adapter supplies missing wire envelope fields; fixture remains unchanged.
  const answer=wire(x,{...fixture.answer,selectedOptionIds:fixture.answer.selectedOptionIds??[]});
  const r=inspect(checkGradingParity,x,answer);assert.notEqual(r.status,'ERROR',fixture.id);assert.equal(check(r,'ACTUAL_DOTNET'),'UNVERIFIED',fixture.id);assert.equal(r.data.sourceModel.verification,'source-only');assert.equal(r.data.grade,undefined);
 }
});
