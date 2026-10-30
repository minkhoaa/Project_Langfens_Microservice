import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { createReadingTools } from '../tools.ts';
import { createNativeFixture } from './native-helpers.mjs';
import { q,group,exam } from './helpers.mjs';
const names=['get_question_spec','validate_question','validate_group','validate_exam','verify_evidence','check_grading_parity','inspect_delivery_projection'];
test('seven first-attempt native calls return consistent structured and text channels',async t=>{
 const f=await createNativeFixture(t);assert.deepEqual(f.definitions.map(d=>d.name),names);
 const x=q('MULTIPLE_CHOICE_SINGLE');x.sectionId='11111111-1111-1111-1111-111111111111';
 const args=[{type:x.type},{question:x},{group:group()},{exam:exam()},{question:x,passage:{id:'p',text:'river'},evidence:{start:0,end:5,quote:'river',sourceId:'p'}},{question:x,submission:{questionId:x.id,sectionId:x.sectionId,selectedOptionIds:[x.options[0].id]}},{question:x}];
 for(let i=0;i<names.length;i++){const native=await f.invoke(names[i],args[i]),r=JSON.parse(native.content[0].text);assert.notEqual(r.status,'FAIL',names[i]);assert.notEqual(r.status,'ERROR',names[i]);assert.deepEqual(native.structuredContent,r);assert.deepEqual(native.details,r);assert.equal(native.isError,false);}
 assert.equal(f.faux.state.callCount,14); // one tool turn and one terminal response per call; no retries
});
test('native arguments preserve wrong primitive types nulls and unknown fields',async t=>{
 const f=await createNativeFixture(t);
 for(const mutate of [x=>x.idx='1',x=>x.imageUrl=null,x=>x.options=null,x=>x.PRIVATE_SENTINEL='PRIVATE_SENTINEL']){const x=q('MULTIPLE_CHOICE_SINGLE');mutate(x);const native=await f.invoke('validate_question',{question:x}),r=JSON.parse(native.content[0].text);assert.equal(r.status,'FAIL');assert.equal(native.isError,true);assert.equal(JSON.stringify(native).includes('PRIVATE_SENTINEL'),false);}
 for(const args of [{},null,{question:null},{question:{},PRIVATE_SENTINEL:'PRIVATE_SENTINEL'},{question:'x'.repeat(2_000_001)}]){
 const native=await f.invoke('validate_question',args),r=JSON.parse(native.content[0].text);assert.equal(r.status,'FAIL');assert.equal(JSON.stringify(native).includes('PRIVATE_SENTINEL'),false);
 if(!args||!Object.hasOwn(args,'question')||Object.hasOwn(args,'PRIVATE_SENTINEL')||typeof args.question==='string'){assert.equal(native.structuredContent,undefined);assert.equal(r.contractHash,null);}
 }
});
test('registration is inert and declarations expose only shallow required outer keys',()=>{
 const registered=[],api={registerTool:d=>registered.push(d)}; // factory is also checked by real loader above
 const defs=createReadingTools();assert.equal(defs.length,7);
 for(const d of defs){assert.equal(d.promptSnippet,undefined);assert.equal(d.promptGuidelines,undefined);assert.equal(d.parameters.type,'object');assert.equal(d.parameters.additionalProperties,false);for(const k of d.parameters.required)assert.deepEqual(d.parameters.properties[k],{});}
 assert.ok(Buffer.byteLength(JSON.stringify(defs))<16384);
});
test('concurrent first calls are deterministic and native cancellation returns explicit error',async()=>{
 const defs=createReadingTools(),d=defs.find(d=>d.name==='validate_question'),args={question:q('SHORT_ANSWER')};
 const results=await Promise.all([d.execute('1',args),d.execute('2',args)]);assert.deepEqual(results[0],results[1]);
 const controller=new AbortController();controller.abort();const cancelled=await d.execute('3',args,controller.signal);assert.equal(cancelled.structuredContent.status,'ERROR');assert.equal(cancelled.structuredContent.diagnostics[0].code,'EXECUTION_ABORTED');
});
