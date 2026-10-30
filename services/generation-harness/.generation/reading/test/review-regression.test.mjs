import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { callTool } from '../domain.ts';
import { createReport } from '../support.ts';
import { runChoiceRule } from '../rules/choice.ts';
import { runCompletionRule } from '../rules/completion.ts';
import { runMatchingRule } from '../rules/matching.ts';
import { validateQuestion } from '../question.ts';
import { verifyEvidence } from '../evidence.ts';
import { createNativeFixture } from './native-helpers.mjs';
import { q,group,exam,wire,hasCode,check,initialize } from './helpers.mjs';
const c=await initialize();
const persisted=()=>({...q('MULTIPLE_CHOICE_SINGLE'),sectionId:'11111111-1111-1111-1111-111111111111'});
test('R1 invalid qualifiers never echo private values in any native result channel',async t=>{
 const f=await createNativeFixture(t),x=persisted();
 for(const [name,args] of [['check_grading_parity',{question:x,submission:{state:{secret:'PRIVATE_SENTINEL'},answer:wire(x)}}],['validate_exam',{exam:{...exam(),expectedQuestionCount:{secret:'PRIVATE_SENTINEL'}}}]]){
  const r=await f.invoke(name,args);assert.equal(JSON.parse(r.content[0].text).status,'FAIL');assert.equal(JSON.stringify(r).includes('PRIVATE_SENTINEL'),false);
 }
});
test('R2 diagnostic truncation cannot hide invalid serialization or final completeness',()=>{
 const x=persisted();x.options=Array.from({length:130},(_,i)=>({id:`o-${i}`,idx:i+1,contentMd:'same',isCorrect:i===0}));
 const r=callTool('check_grading_parity',{question:x,submission:{state:'final',answer:wire(x,{questionId:'invalid',selectedOptionIds:['22222222-2222-2222-2222-222222222222']})}});
 assert.equal(r.diagnostics.length,251);assert.equal(r.data.serializationStatus,'FAIL');assert.equal(r.data.completenessStatus,'FAIL');
});
test('R2 component checks stay FAIL after the detail cap and sibling claims remain local',()=>{
 for(const [handler,id,type,mutate] of [[runChoiceRule,'MULTIPLE_SELECTION_COUNT','MULTIPLE_CHOICE_MULTIPLE',x=>x.promptMd='Choose THREE answers.'],[runCompletionRule,'BLANKS','SENTENCE_COMPLETION',x=>x.promptMd='ONE WORD ONLY. [2].'],[runMatchingRule,'MATCHING_TARGETS','MATCHING_FEATURES',x=>x.promptMd='1. Wrong']]){
 const r=createReport(c);for(let i=0;i<260;i++)r.pending('CAP','/','unverified');const x=q(type);mutate(x);handler(id,c,r,x,'/question');assert.equal(check(r.finish(),id+'.shape'),'FAIL');}
 const r=createReport(c);for(let i=0;i<260;i++)r.pending('CAP','/','unverified');const evidence=verifyEvidence(c,r,q('SHORT_ANSWER'),{id:'p',text:'river'},{sourceId:'p',start:0,end:5,quote:'wrong'});assert.equal(evidence.mechanicalStatus,'FAIL');assert.equal(check(r.finish(),'EVIDENCE_SPAN'),'FAIL');
 const shared=createReport(c),bad=q('MULTIPLE_CHOICE_MULTIPLE');bad.promptMd='Choose THREE answers.';validateQuestion(c,shared,bad);const valid=validateQuestion(c,shared,q('MULTIPLE_CHOICE_MULTIPLE'));assert.notEqual(valid.claims.semanticShape,'FAIL');
});
test('R3 requested image spec preserves selected composition and reference constraints',()=>{
 const r=callTool('get_question_spec',{type:'MULTIPLE_CHOICE_SINGLE_IMAGE'});assert.deepEqual(r.data.constraints.anyOf,[{required:['imageUrl']},{properties:{options:{items:{required:['imageUrl','altText']}}}}]);
});
test('R4 unresolved mechanical selection counts are not semantic-shape PASS',()=>{
 const x=q('MULTIPLE_CHOICE_MULTIPLE');x.promptMd='Select whichever answers apply';const r=callTool('validate_question',{question:x});assert.equal(check(r,'MULTIPLE_SELECTION_COUNT.shape'),'UNVERIFIED');assert.equal(r.data.claims.semanticShape,'UNVERIFIED');
});
test('R5 invalid cross-field key identities make slot counts unavailable',()=>{
 const x=q('SENTENCE_COMPLETION');x.promptMd='ONE WORD ONLY. [23].';x.blankAcceptTexts={'23':['river']};x.blankAcceptRegex={'25':['forest']};const r=callTool('validate_question',{question:x});assert.equal(r.data.answerSlots,null);assert.equal(callTool('validate_exam',{exam:exam([group([{...x,idx:1}])])}).data.answerSlots,null);
});
test('R6 matching serialization reuses the exact accepted bank-label parser',()=>{
 const x={...q('CLASSIFICATION'),sectionId:'11111111-1111-1111-1111-111111111111'};x.options[0].contentMd='A.\tWater';const r=callTool('check_grading_parity',{question:x,submission:{state:'final',answer:wire(x,{textAnswer:'{"1":"A","2":"B"}'})}});assert.equal(r.data.serializationStatus,'PASS');
});
test('R7 malformed ordering primitives produce domain diagnostics without coercion',()=>{
 const e=exam();e.sections.push({id:'s2',idx:{toString:null},questions:[]});const r=callTool('validate_exam',{exam:e});assert.equal(r.status,'FAIL');assert.ok(r.diagnostics.some(d=>d.path==='/exam/sections/1/idx'));assert.equal(hasCode(r,'INTERNAL_ERROR'),false);
 const g=group();g.questions.push({...q('SHORT_ANSWER'),idx:{toString:null},id:'second'});assert.equal(callTool('validate_group',{group:g}).status,'FAIL');
});
test('R8 nonstandard array prototypes are rejected before inherited accessors run',()=>{
 let calls=0;const array=[];Object.setPrototypeOf(array,{get forEach(){calls++;throw Error('PRIVATE_SENTINEL');}});const r=callTool('validate_group',{group:{id:'g',idx:1,questions:array}});assert.equal(r.status,'FAIL');assert.equal(calls,0);assert.equal(hasCode(r,'INPUT_NON_JSON'),true);
 class CustomArray extends Array{};assert.equal(callTool('validate_question',{question:{...q('SHORT_ANSWER'),options:new CustomArray()}}).status,'FAIL');
});
test('R9 container nullability is source-field-specific',()=>{
 const e=exam();e.durationMin=null;const r=callTool('validate_exam',{exam:e});assert.ok(r.diagnostics.some(d=>d.code==='FIELD_TYPE'&&d.path==='/exam/durationMin'));
 e.durationMin=10;e.descriptionMd=null;assert.notEqual(callTool('validate_exam',{exam:e}).status,'FAIL');
});
test('R10 cross-container duplicate diagnostics retain original nested JSON paths',()=>{
 const a=q('MULTIPLE_CHOICE_SINGLE'),b={...q('MULTIPLE_CHOICE_SINGLE'),id:'b',idx:2};const g=group([a,b]);const r=callTool('validate_group',{group:g});assert.ok(r.diagnostics.some(d=>d.code==='IDENTITY_DUPLICATE'&&d.path==='/group/questions/1/options/0/id'));
 const e=exam();e.sections.push({id:'s2',idx:2,questionGroups:[{id:'g1',idx:1,questions:[]}]});const x=callTool('validate_exam',{exam:e});assert.ok(x.diagnostics.some(d=>d.code==='IDENTITY_DUPLICATE'&&d.path==='/exam/sections/1/questionGroups/0/id'));
});
test('R11 explicit complete bounds cannot be fulfilled by another group',()=>{
 const e=exam([{id:'empty',idx:1,startIdx:1,endIdx:1,questions:[]},{...group(),idx:2}]);assert.equal(callTool('validate_exam',{exam:e}).status,'UNVERIFIED');e.complete=true;assert.ok(hasCode(callTool('validate_exam',{exam:e}),'GROUP_BOUNDS_MISMATCH'));
});
test('R12 unsupported table presentation stays unverified instead of falsely invalid',()=>{
 for(const [type,promptMd] of [['TABLE_COMPLETION','ONE WORD ONLY. <table><tr><td>Source</td><td>[1]</td></tr></table>'],['NOTE_COMPLETION','ONE WORD ONLY.\n1) Source → [1]'],['FORM_COMPLETION','ONE WORD ONLY.\nSource → [1]']]){const x=q(type);x.promptMd=promptMd;const r=callTool('validate_question',{question:x});assert.notEqual(r.status,'FAIL');assert.equal(check(r,'COMPLETION_LAYOUT.shape'),'UNVERIFIED');}
});
test('R13 ordinary choose-the-correct-answer instructions do not leak answer keys',()=>{
 const x=q('MULTIPLE_CHOICE_SINGLE');x.promptMd='Choose the correct answer: What does the passage describe?';const r=callTool('inspect_delivery_projection',{question:x});assert.ok(r.data.studentQuestion);assert.equal(hasCode(r,'STUDENT_ANSWER_HINT'),false);
});
