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
test('legacy explicit answer-key and sentence-boundary annotations remain detected',async t=>{
 for(const text of ['Answer key: SENTINEL','Answer keys: SENTINEL','Prompt sentence. Correct answer: SENTINEL','Question stem. Solution: SENTINEL','Question stem? Correct answer: SENTINEL','Question stem! Answer key: SENTINEL','## Answer: SENTINEL','- Teacher note: SENTINEL'])await t.test(text,()=>{
  const x=q('SHORT_ANSWER');x.promptMd=text;const r=inspect(inspectProjection,x);assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'),text);assert.equal(r.data.studentQuestion,undefined,text);assert.equal(JSON.stringify(r).includes('SENTINEL'),false,text);
 });
});
test('blockquotes, indentation, ordered lists, and header emphasis do not hide explicit disclosures',async t=>{
 for(const text of ['> Answer key: SENTINEL','> - Answer key: SENTINEL','>   Answer key: SENTINEL','> 1. Correct answer: SENTINEL','> 1) Correct answer: SENTINEL','    Correct answer: SENTINEL','**Correct answer:** SENTINEL','> - **Answer key:** SENTINEL'])await t.test(text,()=>{
  const x=q('SHORT_ANSWER');x.promptMd=text;const before=structuredClone(x),r=inspect(inspectProjection,x);assert.equal(check(r,'STUDENT_STRUCTURE'),'PASS');assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'),text);assert.ok(r.diagnostics.some(d=>d.code==='STUDENT_ANSWER_HINT'&&d.path==='/question/promptMd'),text);assert.equal(r.data.studentQuestion,undefined,text);assert.equal(JSON.stringify(r).includes('SENTINEL'),false,text);assert.deepEqual(x,before,text);
 });
 const ordinary=q('SHORT_ANSWER');ordinary.promptMd='> Quoted discussion about an answer in the passage.';const control=inspect(inspectProjection,ordinary);assert.ok(control.data.studentQuestion);assert.equal(hasCode(control,'STUDENT_ANSWER_HINT'),false);
});
test('generic Answer use-limit instruction is benign only in the generic answer header',()=>{
 const x=q('SHORT_ANSWER');x.promptMd='Answer: Use no more than two words.';const r=inspect(inspectProjection,x);assert.ok(r.data.studentQuestion);assert.equal(hasCode(r,'STUDENT_ANSWER_HINT'),false);
});
test('explicit private header classes cannot inherit generic Answer direction exemptions',()=>{
 for(const text of ['Answer key: Write no more than two words.','Teacher note: Respond in one sentence.','Solution: Complete the sentences using the passage.']){
  const x=q('SHORT_ANSWER');x.promptMd=text;const r=inspect(inspectProjection,x);assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'),text);assert.equal(r.data.studentQuestion,undefined,text);
 }
});
test('clearly operational Answer(s) directions are not mistaken for disclosures, but adversarial key values remain blocked',()=>{
 const x=q('SHORT_ANSWER');
 for(const direction of ['Answer: Write no more than two words.','Answers: Use ONE WORD ONLY for each answer.','Answers: Use no more than two words.','Answers: Respond in one sentence.','## Answers: Complete the sentences using the passage.']){
  x.promptMd=direction;const r=inspect(inspectProjection,x);assert.ok(r.data.studentQuestion,direction);assert.equal(hasCode(r,'STUDENT_ANSWER_HINT'),false,direction);
 }
 for(const disclosure of ['Answers: A','Answers: Use B','Answers: Choose A','Answers: Use ONE WORD ONLY for each answer. Correct answer: A','Answer: Write no more than two words.\nCorrect answer: A']){
  x.promptMd=disclosure;const r=inspect(inspectProjection,x);assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'),disclosure);assert.equal(r.data.studentQuestion,undefined,disclosure);
 }
 assert.ok(inspect(inspectProjection,Object.assign(q('SHORT_ANSWER'),{promptMd:'Choose the correct answer from the passage.'})).data.studentQuestion);
});
test('nested flow labels are scanned independently and withheld without leaking annotation values',()=>{
 const f=q('FLOW_CHART');f.promptMd+='\n- collect-water: Teacher note: SENTINEL\n- heat-water: Finish step';const r=inspect(inspectProjection,f);
 assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'));assert.equal(r.data.studentQuestion,undefined);assert.equal(JSON.stringify(r).includes('SENTINEL'),false);
 assert.ok(r.diagnostics.some(d=>d.path==='/question/flowChartNodes/0/label'));
});
test('valid option media text is scanned while preserving required image and alt-text structure',()=>{
 const image=q('MULTIPLE_CHOICE_SINGLE_IMAGE');image.options[0].altText='Teacher note: SENTINEL';
 const r=inspect(inspectProjection,image);assert.equal(check(r,'STUDENT_STRUCTURE'),'PASS');assert.ok(hasCode(r,'STUDENT_ANSWER_HINT'));assert.equal(r.data.studentQuestion,undefined);assert.equal(JSON.stringify(r).includes('SENTINEL'),false);
 const matching=q('MATCHING_INFORMATION');matching.wordList=['Key: A'];const bank=inspect(inspectProjection,matching);assert.equal(check(bank,'STUDENT_STRUCTURE'),'PASS');assert.ok(hasCode(bank,'STUDENT_ANSWER_HINT'));assert.equal(bank.data.studentQuestion,undefined);
});
test('natural answer words are not automatically leaks and wordList survives as data',()=>{
 const x=q('MATCHING_INFORMATION');x.wordList=['river'];const r=inspect(inspectProjection,x);assert.deepEqual(r.data.studentQuestion.wordList,['river']);assert.equal(r.data.consumerCompatibility,'UNVERIFIED');
 const y=q('SHORT_ANSWER');y.promptMd='ONE WORD ONLY. Does a river flow here?';assert.ok(inspect(inspectProjection,y).data.studentQuestion);
});
