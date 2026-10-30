import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { inspectProjection } from '../projection.ts';
import { initialize,inspect,q,vectors,hasCode,check } from './helpers.mjs';
await initialize();
test('allowlisted public projection preserves all necessary media banks and identities',()=>{
 for(const original of vectors){const x=structuredClone(original);x.explanationMd='PRIVATE_SENTINEL';if(x.type==='FLOW_CHART')x.promptMd+='\n- collect-water: Collect water\n- heat-water: Heat water';
 const r=inspect(inspectProjection,x),student=r.data?.studentQuestion;assert.ok(student,x.type);assert.equal(check(r,'STUDENT_STRUCTURE'),'PASS',x.type);assert.equal(student.id,x.id);assert.equal(student.promptMd,x.promptMd);assert.equal(student.sectionId,x.sectionId);assert.equal(student.groupId,x.groupId);assert.equal(student.imageUrl,x.imageUrl);assert.equal(student.explanationMd,undefined);assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
 for(let i=0;i<x.options.length;i++){assert.equal(student.options[i].id,x.options[i].id);assert.equal(student.options[i].imageUrl,x.options[i].imageUrl);assert.equal(student.options[i].altText,x.options[i].altText);assert.equal(student.options[i].isCorrect,undefined);}
 }
});
test('unknown private and nested fields are diagnosed without exposing their payloads',()=>{
 for(const mutate of [x=>x.review='PRIVATE_SENTINEL',x=>x.PRIVATE_SENTINEL=null,x=>x.options[0].private={key:'PRIVATE_SENTINEL'},x=>x.promptMd='Correct answer: PRIVATE_SENTINEL',x=>x.promptMd='{"blankAcceptTexts":{"1":["PRIVATE_SENTINEL"]}}']){
 const x=q('MULTIPLE_CHOICE_SINGLE');mutate(x);const r=inspect(inspectProjection,x);assert.equal(r.status,'FAIL');assert.equal(r.data?.studentQuestion,undefined);assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
 }
});
test('public input identities preserve independent blank and classification IDs',()=>{
 const x=q('SENTENCE_COMPLETION');x.idx=7;x.promptMd='ONE WORD ONLY. [23] and [25].';x.blankAcceptTexts={'23':['river'],'25':['forest']};assert.deepEqual(inspect(inspectProjection,x).data.inputIdentities,[{kind:'blank',id:'23'},{kind:'blank',id:'25'}]);
 const s=q('SHORT_ANSWER');assert.deepEqual(inspect(inspectProjection,s).data.inputIdentities,[{kind:'short',id:s.id}]);
 const y=q('CLASSIFICATION');y.promptMd='23. River transport';y.matchPairs={'23':['A','River transport']};assert.deepEqual(inspect(inspectProjection,y).data.inputIdentities,[{kind:'target',id:'23'}]);
});
test('flow withholds missing public labels and is independent of private solution order',()=>{
 const x=q('FLOW_CHART');let r=inspect(inspectProjection,x);assert.equal(r.data?.studentQuestion,undefined);assert.ok(hasCode(r,'FLOW_PUBLIC_NODES_UNAVAILABLE'));
 x.promptMd+='\n- collect-water: Collect water\n- heat-water: Heat water';const a=inspect(inspectProjection,x).data.studentQuestion;x.orderCorrects.reverse();const b=inspect(inspectProjection,x).data.studentQuestion;assert.deepEqual(a,b);assert.deepEqual(a.flowChartNodes.map(n=>n.key),['collect-water','heat-water']);assert.equal(a.orderCorrects,undefined);
});
test('natural answer words are not automatically leaks and wordList survives as data',()=>{
 const x=q('MATCHING_INFORMATION');x.wordList=['river'];const r=inspect(inspectProjection,x);assert.deepEqual(r.data.studentQuestion.wordList,['river']);assert.equal(r.data.consumerCompatibility,'UNVERIFIED');
 const y=q('SHORT_ANSWER');y.promptMd='ONE WORD ONLY. Does a river flow here?';assert.ok(inspect(inspectProjection,y).data.studentQuestion);
});
