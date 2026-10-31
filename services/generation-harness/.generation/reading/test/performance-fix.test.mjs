import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { writeFileSync,readFileSync } from 'node:fs';
import { join } from 'node:path';
import { createNativeFixture } from './native-helpers.mjs';
import { q,group,exam } from './helpers.mjs';
import { summarize } from '../bench/native-trace.mjs';

test('canonical truth labels stay strings; boolean labels are rejected before native coercion',async t=>{
 const f=await createNativeFixture(t),question=q('TRUE_FALSE_NOT_GIVEN');
 const fixed=await f.invoke('validate_question',{question});assert.equal(fixed.isError,false);assert.equal(fixed.details.data.structuralValid,true);
 assert.deepEqual(question.options.map(o=>o.contentMd),['True','False','Not Given']);
 const broken=structuredClone(question);broken.options[0].contentMd=true;broken.options[1].contentMd=false;
 const rejected=await f.invoke('validate_question',{question:broken});assert.equal(rejected.isError,true);assert.equal(rejected.details.contractHash,null);assert.equal(rejected.details.diagnostics[0].code,'NATIVE_ARGUMENT_INVALID');
});

// Reproduces the trace's saved-good-JSON / retyped-bad-arguments split without any provider.
test('all seven existing tools accept exact saved inputs through the native loop; references never repair or cache artifacts',async t=>{
 const f=await createNativeFixture(t),question=q('MULTIPLE_CHOICE_SINGLE'),paper=exam();
 question.sectionId='11111111-1111-1111-1111-111111111111';
 paper.sections[0].passageMd='😀 river flows north.';
 const inputs={type:question.type,question:structuredClone(question),group:group(),exam:paper,passage:{id:'p',text:paper.sections[0].passageMd},evidence:{sourceId:'p',start:3,end:8,quote:'river'},submission:{questionId:question.id,sectionId:question.sectionId,selectedOptionIds:[question.options[0].id]}};
 const path=join(f.cwd,'inputs.json');writeFileSync(path,JSON.stringify(inputs));
 writeFileSync(join(f.cwd,'passage.md'),inputs.passage.text);
 const cases=[['get_question_spec',['type']],['validate_question',['question']],['validate_group',['group']],['validate_exam',['exam']],['verify_evidence',['question','passage','evidence']],['check_grading_parity',['question','submission']],['inspect_delivery_projection',['question']]];
 for(const [name,keys] of cases){
  const direct=await f.invoke(name,Object.fromEntries(keys.map(k=>[k,inputs[k]])));
  const saved=await f.invoke(name,Object.fromEntries(keys.map(k=>[k,k==='type'?inputs[k]:{file:'inputs.json',pointer:`/${k}`}])));
  assert.equal(saved.isError,false,name);assert.deepEqual(saved.details,direct.details,name);
 }
 const text=await f.invoke('verify_evidence',{question:{file:'inputs.json',pointer:'/question'},passage:{file:'passage.md'},evidence:{file:'inputs.json',pointer:'/evidence'}});
 assert.equal(text.details.data.mechanicalStatus,'UNVERIFIED'); // exact span PASS; source id deliberately unavailable
 assert.equal(text.details.data.verifiedSpanCount,1);
 inputs.question.idx='1';writeFileSync(path,JSON.stringify(inputs));
 const changed=await f.invoke('validate_question',{question:{file:'inputs.json',pointer:'/question'}});
 assert.equal(changed.isError,true);assert.ok(changed.details.diagnostics.some(d=>d.code==='SCHEMA_TYPE'));
 for(const reference of [{file:'absent.json'},{file:'inputs.json',pointer:'/absent'},{file:'inputs.json',pointer:'/__proto__'}]){
  const result=await f.invoke('validate_question',{question:reference});assert.equal(result.details.status,'ERROR');assert.equal(result.details.diagnostics[0].code,'ARTIFACT_INPUT_INVALID');
 }
 writeFileSync(path,JSON.stringify({'a/b':{'~':question}}));
 const escaped=await f.invoke('validate_question',{question:{file:'inputs.json',pointer:'/a~1b/~0'}});assert.equal(escaped.isError,false);
 writeFileSync(path,'x'.repeat(2_000_001));
 assert.equal((await f.invoke('validate_exam',{exam:{file:'inputs.json'}})).details.status,'ERROR');
 assert.equal(readFileSync(join(f.cwd,'passage.md'),'utf8'),inputs.passage.text);
});

test('Reading profiles retain independent reviews but prohibit trace-reproduced repetition and explanation history',()=>{
 const profile=readFileSync(new URL('../SYSTEM.md',import.meta.url),'utf8');
 for(const pattern of [/once per type/,/sections\[\]\.passageMd/,/explanationMd.*never review history/,/Collect both reports before revising/,/only affected independent reviews/,/not status polling/])assert.match(profile,pattern);
 for(const role of ['semantic-checker','ielts-examiner']){
  const text=readFileSync(new URL(`../agents/${role}.md`,import.meta.url),'utf8');
  assert.match(text,/defaultContext: fresh/);assert.match(text,/tools: read, bash,/);assert.match(text,/\{file,pointer\}/);assert.match(text,/never explanationMd/);
 }
});

test('trace metrics count cached tokens, exact repeats and first attempts without conflating semantic PASS',()=>{
 const rows=[{type:'message',timestamp:'2026-01-01T00:00:00Z',message:{role:'user',content:[]}},
 {type:'message',timestamp:'2026-01-01T00:00:01Z',message:{role:'assistant',durationMs:1000,usage:{input:2,output:3,cacheRead:5,totalTokens:10},content:[{type:'toolCall',id:'a',name:'validate_exam',arguments:{exam:{id:'e',sections:[]}}}]}},
 {type:'message',timestamp:'2026-01-01T00:00:01Z',message:{role:'toolResult',toolCallId:'a',toolName:'validate_exam',durationMs:2,isError:false,content:[{type:'text',text:'{"status":"UNVERIFIED"}'}]}},
 {type:'message',timestamp:'2026-01-01T00:00:02Z',message:{role:'assistant',content:[{type:'toolCall',id:'b',name:'validate_exam',arguments:{exam:{sections:[],id:'e'}}}]}},
 {type:'message',timestamp:'2026-01-01T00:00:03Z',message:{role:'toolResult',toolCallId:'b',toolName:'validate_exam',isError:true,content:[{type:'text',text:'{"diagnostics":[{"code":"FIELD_TYPE","status":"FAIL"}]}'}]}}];
 const result=summarize(rows);assert.equal(result.wallMs,3000);assert.equal(result.modelMs,1000);assert.equal(result.usage.totalTokens,10);assert.equal(result.usage.cacheRead,5);
 assert.equal(result.toolCalls,2);assert.equal(result.failedCalls,1);assert.equal(result.exactRepeatedCalls,1);assert.equal(result.firstAttempts,1);assert.equal(result.firstAttemptSuccesses,1);assert.equal(result.diagnostics.FIELD_TYPE,1);assert.equal(result.toolDurationMs.validate_exam,2);
});
