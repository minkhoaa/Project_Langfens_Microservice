import '../../../test/offline.mjs';
import { readFileSync,writeFileSync } from 'node:fs';
import { performance } from 'node:perf_hooks';
import { resolve } from 'node:path';
import { pathToFileURL } from 'node:url';
import { createNativeFixture } from '../test/native-helpers.mjs';

// A finite, deterministic native-tool replay, NOT a new generation loop or an LLM benchmark.
export async function replayArtifact(sessionPath,examPath){
 const rows=readFileSync(sessionPath,'utf8').trim().split('\n').map(JSON.parse),paper=JSON.parse(readFileSync(examPath,'utf8'));
 const ids=new Set(paper.sections.flatMap(s=>(s.questions??[]).concat((s.questionGroups??[]).flatMap(g=>g.questions))).map(q=>q.id));
 const failed=new Set(rows.filter(r=>r.message?.role==='toolResult'&&r.message.isError).map(r=>r.message.toolCallId));
 const calls=rows.flatMap(r=>r.message?.role==='assistant'?r.message.content.filter(c=>c.type==='toolCall'&&failed.has(c.id)&&['validate_exam','validate_group','validate_question'].includes(c.name)):[])
  .filter(c=>c.name!=='validate_question'||ids.has(c.arguments.question?.id));
 if(!calls.length)throw Error('No matching recorded structural failures');
 const cleanup=[],fixture=await createNativeFixture({after:fn=>cleanup.push(fn)});
 const measure=async invocations=>{
  let failedCalls=0,argumentBytes=0,resultTextBytes=0;const start=performance.now();
  for(const [name,args] of invocations){argumentBytes+=Buffer.byteLength(JSON.stringify(args));const result=await fixture.invoke(name,args);if(result.isError)failedCalls++;resultTextBytes+=Buffer.byteLength(result.content[0].text);}
  return {wallMs:performance.now()-start,toolCalls:invocations.length,failedCalls,successes:invocations.length-failedCalls,argumentBytes,resultTextBytes};
 };
 try{
  const before=await measure(calls.map(c=>[c.name,c.arguments]));
  const args={exam:{file:resolve(examPath)}};const after=await measure([['validate_exam',args]]);
  const result=await fixture.invoke('validate_exam',args);
  return {recordedSession:sessionPath.split('/').at(-1),before,after,quality:{...result.details.data,passageEmbedded:paper.sections.every(s=>typeof s.passageMd==='string'&&s.passageMd.trim().length>0),reviewHistoryInExplanations:paper.sections.flatMap(s=>(s.questions??[]).concat((s.questionGroups??[]).flatMap(g=>g.questions))).filter(q=>/review|re-rated|re-typed|rewritten after/i.test(q.explanationMd??'')).length},providerTokens:{input:0,output:0,cacheRead:0},subagentLaunches:0,methodology:'Same saved export, unmodified, through the actual native agent tool path with an in-memory faux provider. Before replays recorded malformed structural calls; after one file-backed validate_exam covers all contained Questions/Groups. Times include faux model turns, not real model latency. No semantic/IELTS review or live end-to-end speedup is measured. Byte counts are exact, NOT token counts. No readiness claim.'};
 }finally{for(const fn of cleanup.reverse())await fn();}
}
// Replays recorded rejected evidence calls and checks independently serialized,
// numeric saved spans on the same final paper. No semantic/independence verdict.
export async function replayEvidence(sessionPath,examPath,evidencePath){
 const rows=readFileSync(sessionPath,'utf8').trim().split('\n').map(JSON.parse);
 const failed=new Set(rows.filter(r=>r.message?.role==='toolResult'&&r.message.isError&&r.message.toolName==='verify_evidence').map(r=>r.message.toolCallId));
 const calls=rows.flatMap(r=>Array.isArray(r.message?.content)?r.message.content:[]).filter(c=>c.type==='toolCall'&&c.name==='verify_evidence'&&failed.has(c.id));
 if(!calls.length)throw Error('No recorded evidence failures');
 const paper=JSON.parse(readFileSync(examPath,'utf8')),notes=JSON.parse(readFileSync(evidencePath,'utf8'));
 const cleanup=[],f=await createNativeFixture({after:fn=>cleanup.push(fn)});
 const invoke=async args=>{
  let failedCalls=0,argumentBytes=0,resultTextBytes=0,spanPasses=0;const start=performance.now();
  for(const input of args){const result=await f.invoke('verify_evidence',input);failedCalls+=Number(!!result.isError);argumentBytes+=Buffer.byteLength(JSON.stringify(input));resultTextBytes+=Buffer.byteLength(result.content[0].text);spanPasses+=result.details?.checks?.filter(c=>c.id==='EVIDENCE_SPAN'&&c.status==='PASS').length??0;}
  return {toolCalls:args.length,failedCalls,spanPasses,argumentBytes,resultTextBytes,wallMs:performance.now()-start};
 };
 try{
  const spans={},after=[];
  paper.sections.forEach((s,si)=>s.questionGroups.forEach((g,gi)=>g.questions.forEach((q,qi)=>{
   const note=notes[q.id];if(!note)throw Error('Missing saved span');
   spans[q.id]=[note,...(note.additionalSpans??[])].map(({start,end,quote})=>({start,end,quote}));
   for(const span of spans[q.id])if(!Number.isInteger(span.start)||!Number.isInteger(span.end)||s.passageMd.slice(span.start,span.end)!==span.quote)throw Error('Saved numeric UTF-16 span mismatch');
   after.push({question:{file:resolve(examPath),pointer:`/sections/${si}/questionGroups/${gi}/questions/${qi}`},passage:{file:resolve(examPath),pointer:`/sections/${si}/passageMd`},evidence:{file:resolve(f.cwd,'spans.json'),pointer:`/${q.id.replaceAll('~','~0').replaceAll('/','~1')}`}});
  })));
  writeFileSync(resolve(f.cwd,'spans.json'),JSON.stringify(spans));
  return {before:await invoke(calls.map(c=>c.arguments)),after:await invoke(after),providerTokens:0,subagentLaunches:0,quality:'UNVERIFIED: span mechanics only, not independent semantic review or IELTS quality; no live latency comparison.'};
 }finally{for(const fn of cleanup.reverse())await fn();}
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href)console.log(JSON.stringify(process.argv[2]==='--evidence'?await replayEvidence(...process.argv.slice(3)):await replayArtifact(process.argv[2],process.argv[3]),null,2));
