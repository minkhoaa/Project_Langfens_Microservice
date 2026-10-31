import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { existsSync,mkdirSync,mkdtempSync,readFileSync,writeFileSync,rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { harnessRoot,runtimeLaunch } from '../../../scripts/runtime.mjs';
import { createNativeFixture } from './native-helpers.mjs';
import { q,group,exam } from './helpers.mjs';
import { createDomain } from '../domain.ts';

// Argument defects recorded in 2026-10-30T10-11-53-593Z, not speculative inputs.
test('recorded repeated failures are actionable through the native model loop',async t=>{
 const f=await createNativeFixture(t);
 const failures=[['get_question_spec',{type:'TrueFalseNotGiven'},'TYPE_UNSUPPORTED'],
  ['get_question_spec',{type:'ielts-reading-multiple-choice'},'TYPE_UNSUPPORTED'],
  ['get_question_spec',{type:'multiple_choice'},'TYPE_UNSUPPORTED'],
  ['validate_exam',{exam:''},'NATIVE_ARGUMENT_INVALID'],
  ['validate_exam',{exam:{id:'exam1',sections:{item:{id:'s1'}}}},'NATIVE_ARGUMENT_INVALID'],
  ['validate_group',{group:{id:'g1',idx:'1',questions:{item:'q1'}}},'NATIVE_ARGUMENT_INVALID'],
  ['validate_group',{group:'{"id":"g1","idx":1,"questions":[]}'},'NATIVE_ARGUMENT_INVALID'],
  ['validate_question',{question:{id:'q1',sectionId:'s1',idx:'1',type:'TRUE_FALSE_NOT_GIVEN',skill:'READING',difficulty:'2',promptMd:'Test statement.',options:{item:[{id:'o1',idx:'1',contentMd:'True',isCorrect:'true'}]}}},'NATIVE_ARGUMENT_INVALID']];
 for(const [name,args,code] of failures){
  const result=await f.invoke(name,args),report=JSON.parse(result.content[0].text);
  assert.equal(result.isError,true);assert.equal(report.status,'FAIL');
  assert.ok(report.diagnostics.some(d=>d.code===code),JSON.stringify(report));
  assert.ok(report.diagnostics.every(d=>d.suggestedCorrection));
  const transcript=f.session.messages.filter(m=>m.role==='toolResult'&&m.toolName===name).at(-1);
  assert.deepEqual(JSON.parse(transcript.content[0].text),report);
  assert.equal(report.contractHash===null,code==='NATIVE_ARGUMENT_INVALID');
 }
 for(const [name,args] of [['get_question_spec',{type:'TRUE_FALSE_NOT_GIVEN'}],['validate_question',{question:q('TRUE_FALSE_NOT_GIVEN')}],['validate_group',{group:group()}],['validate_exam',{exam:exam()}]]){
  const result=await f.invoke(name,args);assert.equal(result.isError,false,name);
  assert.ok(['PASS','UNVERIFIED'].includes(result.details.status));
 }
 const spans=await f.invoke('verify_evidence',{question:q('TRUE_FALSE_NOT_GIVEN'),passage:{id:'p',text:'river'},evidence:[{sourceId:'p',start:0,end:5,quote:'river'}]});assert.equal(spans.isError,false);
 const ready=exam();ready.publicationReady=true;
 const rejected=await f.invoke('validate_exam',{exam:ready});assert.equal(rejected.isError,true);assert.ok(rejected.details.diagnostics.some(d=>d.code==='FIELD_UNKNOWN'));
 const infra=createDomain({contractUrl:join(f.cwd,'absent-contract')}).call('validate_question',{question:q('SHORT_ANSWER')});
 assert.equal(infra.status,'ERROR');assert.equal(infra.diagnostics[0].code,'CONTRACT_UNAVAILABLE');
 const multi=q('SUMMARY_COMPLETION');multi.blankAcceptTexts={'1':['river'],'2':['forest']};delete multi.blankAcceptRegex;multi.promptMd='ONE WORD ONLY. [1] and [2].';
 const conflict=await f.invoke('validate_question',{question:multi});
 assert.ok(conflict.details.diagnostics.some(d=>d.code==='IELTS_SCORING_CONFLICT'));
 assert.equal(conflict.details.data.answerSlots,2);assert.equal(conflict.details.data.scoringUnits,1);
 const ambiguous=q('MULTIPLE_CHOICE_MULTIPLE');ambiguous.promptMd='Choose TWO answers. Which THREE features are mentioned?';
 const uncertainty=await f.invoke('validate_question',{question:ambiguous});
 assert.equal(uncertainty.details.status,'UNVERIFIED');
 assert.ok(uncertainty.details.diagnostics.some(d=>d.code==='CHOICE_COUNT_INSTRUCTION_UNVERIFIED'));
 const unsupported=await f.invoke('validate_question',{question:{...multi,pointsPerBlank:1}});
 assert.equal(unsupported.isError,true);assert.equal(unsupported.details.data.claims.structure,'FAIL');
});

test('a Reading dependency failure reaches the native calling transcript as ERROR without retries',()=>{
 const script=`import {registerHooks} from 'node:module';import assert from 'node:assert/strict';
 registerHooks({resolve(s,c,next){if(s==='./domain.ts'&&c.parentURL?.endsWith('/.generation/reading/tools.ts'))throw Error('injected offline dependency failure');return next(s,c);}});
 const {createNativeFixture}=await import('./.generation/reading/test/native-helpers.mjs'),cleanup=[];
 const f=await createNativeFixture({after:fn=>cleanup.push(fn)});
 try{const result=await f.invoke('get_question_spec',{type:'SHORT_ANSWER'}),r=JSON.parse(result.content[0].text);
 assert.equal(r.status,'ERROR');assert.equal(r.diagnostics[0].code,'INTERNAL_ERROR');assert.match(r.diagnostics[0].suggestedCorrection,/domain.ts/);
 assert.equal(result.isError,true);assert.equal(f.faux.state.callCount,2);
 assert.deepEqual(JSON.parse(f.session.messages.find(m=>m.role==='toolResult').content[0].text),r);
 }finally{for(const fn of cleanup.reverse())await fn();}`;
 const run=spawnSync(process.execPath,['--import','./test/offline.mjs','--input-type=module','-e',script],{cwd:harnessRoot,env:{...process.env,GENERATION_HARNESS_OFFLINE:'1'},encoding:'utf8',timeout:15000});
 assert.equal(run.status,0,run.stderr);
});

// Finite faux-provider simulation of real CLI + default native Subagents discovery
// and foreground execution. This is NOT an LLM/IELTS-quality evaluation.
test('Reading CLI authors 13Q and calls both native specialists; coding CLI is unchanged',{timeout:60000},t=>{
 const root=mkdtempSync(join(tmpdir(),'reading-profile-'));t.after(()=>rmSync(root,{recursive:true,force:true}));
 const env={...process.env,GENERATION_HARNESS_RUNTIME_DIR:join(root,'runtime')};
 const reading=runtimeLaunch(['--reading'],env),coding=runtimeLaunch([],env);
 assert.notEqual(reading.cwd,coding.cwd);assert.notEqual(reading.env.GENERATION_HARNESS_AGENT_DIR,coding.env.GENERATION_HARNESS_AGENT_DIR);
 // Even a reused workspace must not discover coding instructions/agents/extensions.
 writeFileSync(join(reading.cwd,'AGENTS.md'),'CODING_CONTEXT_CANARY: act as a software engineer.');
 mkdirSync(join(reading.cwd,'.generation/agents'),{recursive:true});
 writeFileSync(join(reading.cwd,'.generation/agents/swe-specialist.md'),'---\nname: swe-specialist\nadvertise: true\n---\nCODING_CONTEXT_CANARY');
 mkdirSync(join(reading.cwd,'.generation/extensions'),{recursive:true});
 writeFileSync(join(reading.cwd,'.generation/extensions/ambient.mjs'),'throw Error("ambient coding extension loaded");');
 const paper={id:'e1',complete:true,expectedQuestionCount:13,sections:[{id:'s1',idx:1,passageMd:'A river flows north. A forest lies east of the river.',questionGroups:[{id:'g1',idx:1,questions:Array.from({length:13},(_,i)=>{
  const x=q('MULTIPLE_CHOICE_SINGLE');return {...x,id:`q${i+1}`,sectionId:'s1',groupId:'g1',idx:i+1,promptMd:'In which direction does the river flow?',explanationMd:'The passage states that the river flows north.',options:x.options.map((o,j)=>({...o,id:`o${i+1}-${j}`,contentMd:['North','South','East','West'][j]}))};
 })}]}]};
 const provider=join(root,'offline-provider.mjs'),receipt=join(root,'receipt.json');
 writeFileSync(provider,`
import ${JSON.stringify(new URL('../../../test/offline.mjs',import.meta.url).href)};
import assert from 'node:assert/strict';
import {writeFileSync} from 'node:fs';
import {fauxProvider,fauxAssistantMessage,fauxToolCall,getSystemMessageText} from ${JSON.stringify(import.meta.resolve('generation-ai'))};
const paper=${JSON.stringify(paper)},receipt=${JSON.stringify(receipt)};
export default api=>{
 const fake=fauxProvider({models:[{id:'parent'}]}),steps={},metrics={roles:{},calls:[],reviews:{}};
 const call=(name,args)=>fauxAssistantMessage(fauxToolCall(name,args),{stopReason:'toolUse'});
 const report=(ctx,name)=>JSON.parse(ctx.messages.filter(m=>m.role==='toolResult'&&m.toolName===name).at(-1).content[0].text);
 const respond=ctx=>{
  const prompt=ctx.messages.filter(m=>m.role==='system').map(getSystemMessageText).join(String.fromCharCode(10));
  const user=ctx.messages.filter(m=>m.role==='user').map(m=>JSON.stringify(m.content)).join(String.fromCharCode(10));
  const role=user.includes('semantic-review')?'semantic':user.includes('examiner-review')?'examiner':user.includes('coding probe')?'coding':'author';
  const tools=new Map();for(const m of ctx.messages.filter(m=>m.role==='system')){for(const n of m.toolsRemoved??[])tools.delete(n);for(const d of m.toolsAdded??[])tools.set(d.name,d);}
  const names=[...tools.keys()],n=steps[role]??0;steps[role]=n+1;
  metrics.roles[role]??={promptBytes:Buffer.byteLength(prompt),declarationBytes:Buffer.byteLength(JSON.stringify([...tools.values()])),tools:names};
  const last=ctx.messages.filter(m=>m.role==='toolResult').at(-1);
  if(last){
   assert.equal(last.isError,false,JSON.stringify(last));
   const domain=last.toolName==='get_question_spec'||last.toolName.startsWith('create_')||last.toolName.startsWith('validate_')||['verify_evidence','check_grading_parity','inspect_delivery_projection'].includes(last.toolName)?JSON.parse(last.content[0].text):null;
   if(domain){
    assert.equal(domain.contractHash,'6345070a86b3271bc2ae348a0afcb33c928b42a1b55346809cb566a21c6478c5');
    assert.ok(['PASS','UNVERIFIED'].includes(domain.status));
    if(last.toolName.startsWith('validate_'))assert.ok(domain.checks.some(c=>c.id==='STRUCTURE'&&c.status==='PASS'));
   }
   metrics.calls.push({role,tool:last.toolName,isError:!!last.isError,...(domain?{status:domain.status}:{})});
  }
  if(role==='coding'){
   assert.match(prompt,/expert coding assistant/);assert.ok(names.includes('bash'));assert.ok(!names.includes('validate_exam'));
   if(n===0)return call('subagent',{action:'list'});
   assert.match(JSON.stringify(last),/worker/);assert.doesNotMatch(JSON.stringify(last),/semantic-checker|ielts-examiner/);
   writeFileSync(receipt,JSON.stringify(metrics));return fauxAssistantMessage('CODING-OK');
  }
  assert.doesNotMatch(prompt,/expert coding assistant|Langfens Generation Harness Rules|CODING_CONTEXT_CANARY|swe-specialist/);
  if(role!=='author'){
   assert.equal(ctx.messages.filter(m=>m.role==='user').length,1);assert.ok(!user.includes('AUTHOR_PRIVATE_HISTORY'));
   assert.ok(!names.includes('write')&&names.includes('bash')&&!names.includes('subagent'));
   assert.match(prompt,role==='semantic'?/answerability|answer.s support/:/authentic|scoring/);
   if(n===0)return call('read',{path:'exam.json'});
   if(n===1)return call('validate_exam',{exam:{file:'exam.json'}});
   if(n===2){assert.equal(report(ctx,'validate_exam').data.questionCount,13);
    return role==='semantic'?call('verify_evidence',{question:paper.sections[0].questionGroups[0].questions[0],passage:{id:'s1',text:paper.sections[0].passageMd},evidence:{sourceId:'s1',start:0,end:20,quote:'A river flows north.'}}):call('inspect_delivery_projection',{question:paper.sections[0].questionGroups[0].questions[0]});}
   if(role==='examiner'&&n===3)return call('check_grading_parity',{question:paper.sections[0].questionGroups[0].questions[0],submission:{questionId:'11111111-1111-1111-1111-111111111111',sectionId:'22222222-2222-2222-2222-222222222222',selectedOptionIds:['33333333-3333-3333-3333-333333333333']}});
   const finding=role==='semantic'?'UNVERIFIED semantic: independently establish all answer evidence.':'UNVERIFIED examiner: duplicate items and tiny passage are not authentic IELTS; .NET parity absent. NOT READY.';
   metrics.reviews[role]=finding;return fauxAssistantMessage(finding);
  }
  assert.match(prompt,/IELTS Academic Reading author/);assert.ok(names.includes('bash'));
  for(const tool of ['create_single_choice','create_multiple_choice','create_completion','create_matching','create_short_answer','create_flow_chart'])assert.ok(names.includes(tool),tool);
  assert.match(prompt,/semantic-checker/);assert.match(prompt,/ielts-examiner/);
  if(names.includes('subagents_enable')&&!names.includes('subagent'))return call('subagents_enable',{});
  const offset=ctx.messages.some(m=>m.role==='toolResult'&&m.toolName==='subagents_enable')?1:0,turn=n-offset;
  if(turn===0)return call('subagent',{action:'list'});
  if(turn===1){const listing=JSON.stringify(last);assert.match(listing,/semantic-checker/);assert.match(listing,/ielts-examiner/);assert.doesNotMatch(listing,/swe-specialist|\\b(worker|scout|reviewer|delegate|oracle|researcher)\\b/);return call('write',{path:'exam.json',content:JSON.stringify(paper)});}
  if(turn===2)return call('get_question_spec',{type:'MULTIPLE_CHOICE_SINGLE'});
  if(turn===3){const {skill,options,...input}=paper.sections[0].questionGroups[0].questions[0];return call('create_single_choice',{...input,options:options.map(({idx,...o})=>o)});}
  if(turn===4)return call('validate_exam',{exam:{file:'exam.json'}});
  if(turn===5){assert.equal(report(ctx,'validate_exam').data.questionCount,13);return call('inspect_delivery_projection',{question:{file:'exam.json',pointer:'/sections/0/questionGroups/0/questions/0'}});}
  if(turn===6)return call('subagent',{agent:'semantic-checker',task:'semantic-review: independently review exam.json revision r1',async:false,options:{context:'fresh'}});
  if(turn===7){assert.match(JSON.stringify(last),/UNVERIFIED semantic/);return call('subagent',{agent:'ielts-examiner',task:'examiner-review: independently review exam.json revision r1',async:false,options:{context:'fresh'}});}
  assert.match(JSON.stringify(last),/UNVERIFIED examiner/);assert.ok(metrics.reviews.semantic&&metrics.reviews.examiner);
  metrics.providerRequests=fake.state.callCount;writeFileSync(receipt,JSON.stringify(metrics));
  return fauxAssistantMessage('NOT READY. '+metrics.reviews.semantic+' '+metrics.reviews.examiner);
 };
 fake.setResponses(Array(100).fill(respond));api.registerProvider(fake.provider);
};`);
 for(const [mode,alias] of [['reading','start:reading'],['coding','start']]){
  const result=spawnSync('npm',['run',alias,'--','--extension',provider,'--provider','faux','--model','parent','--mode','json','--no-session','--offline','-p',mode==='reading'?'AUTHOR_PRIVATE_HISTORY: offline 13Q authoring probe':'coding probe'],{cwd:harnessRoot,env,encoding:'utf8',timeout:45000,maxBuffer:10_000_000});
  assert.equal(result.status,0,result.stderr+'\n'+result.stdout.slice(-12000));
  assert.ok(existsSync(receipt),result.stderr+'\n'+result.stdout.slice(-14000));
  const metrics=JSON.parse(readFileSync(receipt,'utf8'));
  if(mode==='reading'){
   const artifact=JSON.parse(readFileSync(join(reading.cwd,'exam.json'),'utf8'));
   assert.equal(artifact.expectedQuestionCount,13);assert.ok(artifact.sections[0].passageMd.trim());
   const questions=artifact.sections[0].questionGroups[0].questions;assert.equal(questions.length,13);
   for(const question of questions){assert.equal(question.options.filter(o=>o.isCorrect).length,1);assert.doesNotMatch(question.explanationMd,/review|revision|re-rated|rewritten/i);}
   assert.deepEqual(Object.keys(metrics.reviews).sort(),['examiner','semantic']);
   for(const name of ['get_question_spec','create_single_choice','validate_exam','verify_evidence','check_grading_parity','inspect_delivery_projection'])assert.ok(metrics.calls.some(c=>c.tool===name),name);
   assert.equal(metrics.calls.filter(c=>['validate_question','validate_group'].includes(c.tool)).length,0);
   assert.equal(metrics.calls.filter(c=>c.tool==='subagent').length,3); // discovery plus two independent reviews
   const domainCalls=metrics.calls.filter(c=>c.status);
   assert.equal(domainCalls.length,9);assert.equal(domainCalls.filter(c=>c.status==='PASS').length,1);
   assert.equal(domainCalls.filter(c=>c.status==='UNVERIFIED').length,8);
   assert.ok(!metrics.calls.some(c=>c.isError));assert.match(result.stdout,/NOT READY/);
   t.diagnostic(JSON.stringify(metrics));
  }else assert.match(result.stdout,/CODING-OK/);
 }
});
