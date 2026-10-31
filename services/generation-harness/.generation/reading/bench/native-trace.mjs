// Read-only analysis of native session.jsonl files, never provider calls or transcript copies.
import '../../../test/offline.mjs';
import { readFileSync,readdirSync } from 'node:fs';
import { basename,dirname,join } from 'node:path';
import { pathToFileURL } from 'node:url';
const canonical=v=>Array.isArray(v)?v.map(canonical):v&&typeof v==='object'?Object.fromEntries(Object.keys(v).sort().map(k=>[k,canonical(v[k])])):v;
const bump=(o,k,n=1)=>o[k]=(o[k]??0)+n;
export function summarize(rows){
 const messages=rows.filter(r=>r.type==='message').map(r=>({...r.message,recordTime:r.timestamp}));
 const calls=new Map(),seen=new Set(),first=new Set();
 const result={start:messages.find(m=>m.role==='user')?.recordTime,end:messages.at(-1)?.recordTime,modelResponses:0,modelMs:0,modelDurations:[],usage:{input:0,output:0,cacheRead:0,cacheWrite:0,totalTokens:0},tools:{},toolDurationMs:{},argumentBytesByTool:{},resultTextBytesByTool:{},failures:{},diagnostics:{},exactRepeatedCalls:0,firstAttempts:0,firstAttemptSuccesses:0,subagentLaunches:0,specTypes:{},argumentBytes:0,resultTextBytes:0,compactions:rows.filter(r=>r.type==='compaction').length};
 for(const m of messages){
  if(m.role==='assistant'){
   result.modelResponses++;if(Number.isFinite(m.durationMs)){result.modelMs+=m.durationMs;result.modelDurations.push(m.durationMs);}
   for(const k of Object.keys(result.usage))result.usage[k]+=m.usage?.[k]??0;
   for(const c of m.content??[])if(c.type==='toolCall'){
    const key=JSON.stringify([c.name,canonical(c.arguments)]),isFirst=!first.has(c.name);first.add(c.name);
    calls.set(c.id,{...c,isFirst});bump(result.tools,c.name);const bytes=Buffer.byteLength(JSON.stringify(c.arguments));result.argumentBytes+=bytes;bump(result.argumentBytesByTool,c.name,bytes);
    if(seen.has(key))result.exactRepeatedCalls++;seen.add(key);
    if(c.name==='get_question_spec')bump(result.specTypes,c.arguments.type);
    if(c.name==='subagent'&&c.arguments.agent&&c.arguments.task&&!c.arguments.action)result.subagentLaunches++;
   }
  }
  if(m.role==='toolResult'){
   const call=calls.get(m.toolCallId);if(call?.isFirst){result.firstAttempts++;if(!m.isError)result.firstAttemptSuccesses++;}
   const text=(m.content??[]).filter(c=>c.type==='text').map(c=>c.text).join('\n');const bytes=Buffer.byteLength(text);result.resultTextBytes+=bytes;bump(result.resultTextBytesByTool,m.toolName,bytes);bump(result.toolDurationMs,m.toolName,m.durationMs??0);
   if(m.isError){bump(result.failures,m.toolName);let report;try{report=JSON.parse(text);}catch{}
    const codes=new Set(report?.diagnostics?.filter(d=>['FAIL','ERROR'].includes(d.status)).map(d=>d.code)??['NATIVE_OR_NON_DOMAIN_ERROR']);for(const code of codes)bump(result.diagnostics,code);
   }
  }
 }
 const sorted=result.modelDurations.sort((a,b)=>a-b);result.modelLatencyMs={count:sorted.length,median:sorted[Math.floor(sorted.length/2)]??null,p95:sorted[Math.ceil(sorted.length*.95)-1]??null,max:sorted.at(-1)??null};delete result.modelDurations;
 result.wallMs=Date.parse(result.end)-Date.parse(result.start);
 result.toolCalls=Object.values(result.tools).reduce((a,b)=>a+b,0);result.failedCalls=Object.values(result.failures).reduce((a,b)=>a+b,0);
 result.firstAttemptDefinition='First invocation of each tool name per session; success means !isError, includes UNVERIFIED, not semantic PASS.';
 return result;
}
export function analyzeSession(path){
 const parent=summarize(readFileSync(path,'utf8').trim().split('\n').map(JSON.parse));
 const childRoot=join(dirname(path),basename(path,'.jsonl'));let children=[];
 try{children=readdirSync(childRoot).sort().flatMap(id=>{
  const root=join(childRoot,id);return readdirSync(root).sort().map(run=>({id,run,...summarize(readFileSync(join(root,run,'session.jsonl'),'utf8').trim().split('\n').map(JSON.parse))}));
 });}catch(error){if(error.code!=='ENOENT')throw error;}
 return {source:basename(path),parent,children,methodology:'Native message records only, children from the matching parent session directory (not duplicate transcript mirrors). Model durationMs is observed request duration, not pure inference. Usage summed as recorded, including cached input per request, not unique context. Concurrent child durations must not be added to wall time. Exact repeats compare sorted JSON arguments within each session. Human follow-ups and idle time are included in full wallMs; see report for phase boundaries. No after-model-run estimate.'};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href)console.log(JSON.stringify(analyzeSession(process.argv[2]),null,2));
