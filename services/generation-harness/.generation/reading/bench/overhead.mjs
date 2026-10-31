import '../../../test/offline.mjs';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import fs from 'node:fs';
import { registerHooks,syncBuiltinESMExports } from 'node:module';
import { fileURLToPath } from 'node:url';
import { performance } from 'node:perf_hooks';
import os from 'node:os';
const file=fileURLToPath(import.meta.url);
export async function measureOverhead({warmups=5,iterations=20}={}) {
 if(!Number.isInteger(warmups)||warmups<0||warmups>20||!Number.isInteger(iterations)||iterations<1||iterations>100)throw Error('Invalid finite measurement count');
 const {stdout}=await promisify(execFile)(process.execPath,[file,'--sample',String(warmups),String(iterations)],{env:{...process.env,GENERATION_HARNESS_OFFLINE:'1'},maxBuffer:1_000_000});return JSON.parse(stdout);
}
function stats(samples){const ordered=[...samples].sort((a,b)=>a-b);return {samples,median:ordered[Math.floor(ordered.length/2)],p95:ordered[Math.ceil(ordered.length*.95)-1]};}
async function sample(warmups,iterations) {
 // Instrument only this disposable process; no counters/hooks are shipped in domain code.
 const schemaText=fs.readFileSync(new URL('../../contracts/question-types.v1.schema.json',import.meta.url),'utf8');
 const fixture=JSON.parse(fs.readFileSync(new URL('../../contracts/test-vectors/canonical-questions.v1.json',import.meta.url),'utf8'))[0];
 let counts={contractReads:0,contractModuleLoads:0,vectorReads:0,sourceReads:0,schemaCompiles:0,contractParses:0};
 globalThis.__readingBenchCompile=()=>counts.schemaCompiles++;
 const hook=registerHooks({load(url,context,nextLoad){const result=nextLoad(url,context);if(url===new URL('../../contracts/question-types.v1.schema.json',import.meta.url).href)counts.contractModuleLoads++;if(url===new URL('../contract.ts',import.meta.url).href){
  const source=String(result.source).replace("import { Compile } from 'typebox/compile';","import { Compile as actualCompile } from 'typebox/compile';\nconst Compile=(...args: Parameters<typeof actualCompile>)=>{globalThis.__readingBenchCompile();return actualCompile(...args);};");
  if(source===String(result.source))throw Error('Compile observation seam changed');return {...result,source};}return result;}});
 const originalOpen=fs.openSync,originalParse=JSON.parse;
 fs.openSync=function(path,...args){const name=String(path);if(name.endsWith('question-types.v1.schema.json'))counts.contractReads++;if(name.endsWith('canonical-questions.v1.json'))counts.vectorReads++;if(name.endsWith('sources.v1.json'))counts.sourceReads++;return originalOpen.call(this,path,...args);};
 JSON.parse=function(text,...args){if(text===schemaText)counts.contractParses++;return originalParse.call(this,text,...args);};syncBuiltinESMExports();
 try{
  const coldStart=performance.now(),{default:reading}=await import('../../extensions/reading.ts');let definitions=[];
  reading({registerTool:d=>definitions.push(d)});const coldRegistrationMs=performance.now()-coldStart;
  const registration={contractReads:counts.contractReads,contractModuleLoads:counts.contractModuleLoads,vectorReads:counts.vectorReads,sourceReads:counts.sourceReads,schemaCompiles:counts.schemaCompiles};
  const declarationBytes=Buffer.byteLength(JSON.stringify(definitions));
  const existingDeclarationBytes=Buffer.byteLength(JSON.stringify(definitions.filter(d=>!d.name.startsWith('create_'))));
  const creationDeclarationBytes=Buffer.byteLength(JSON.stringify(definitions.filter(d=>d.name.startsWith('create_'))));
  const perToolDeclarationBytes=Object.fromEntries(definitions.map(d=>[d.name,Buffer.byteLength(JSON.stringify(d))]));
  const q=definitions.find(d=>d.name==='validate_question'),e=definitions.find(d=>d.name==='validate_exam');
  counts={contractReads:0,contractModuleLoads:0,vectorReads:0,sourceReads:0,schemaCompiles:0,contractParses:0};
  const firstStart=performance.now();await q.execute('first',{question:fixture});const firstCallMs=performance.now()-firstStart,firstUse={...counts};
  definitions=[];reading({registerTool:d=>definitions.push(d)});counts={contractReads:0,contractModuleLoads:0,vectorReads:0,sourceReads:0,schemaCompiles:0,contractParses:0};
  const concurrent=definitions.find(d=>d.name==='validate_question');await Promise.all([concurrent.execute('a',{question:fixture}),concurrent.execute('b',{question:fixture})]);const concurrentFirstUse={...counts};
  const paper={id:'exam',complete:true,sections:[{id:'s1',idx:1,questionGroups:[{id:'g1',idx:1,questions:Array.from({length:100},(_,i)=>({...structuredClone(fixture),id:`q${i}`,idx:i+1,options:fixture.options.map((o,j)=>({...o,id:`o${i}-${j}`}))}))}]}]};
  const timings={registrationDelta:[],warmQuestion:[],warmExam100:[]};
  for(let i=-warmups;i<iterations;i++){
   const baseStart=performance.now();const noop=()=>{};noop();const base=performance.now()-baseStart;
   const a=performance.now();reading({registerTool:noop});const registrationDelta=performance.now()-a-base;
   const b=performance.now();await q.execute('warm',{question:fixture});const warmQuestion=performance.now()-b;
   const c=performance.now();await e.execute('exam',{exam:paper});const warmExam100=performance.now()-c;
   if(i>=0){timings.registrationDelta.push(registrationDelta);timings.warmQuestion.push(warmQuestion);timings.warmExam100.push(warmExam100);}
  }
  return {node:process.version,os:`${os.platform()} ${os.release()} ${os.arch()}`,warmups,iterations,fixtureQuestionCount:100,toolCount:definitions.length,declarationBytes,existingDeclarationBytes,creationDeclarationBytes,perToolDeclarationBytes,registration,firstUse,concurrentFirstUse,coldRegistrationMs,firstCallMs,timings:Object.fromEntries(Object.entries(timings).map(([k,v])=>[k,stats(v)])),methodology:'Fresh offline subprocess observes bounded opens, exact canonical JSON parsing and actual Compile calls via temporary module instrumentation. Cold registration includes extension imports, including the canonical JSON module used to derive builder input declarations (observed separately from bounded validation reads). Byte counts are serialized declarations, not tokenizer measurements. Twenty warm factory deltas against a no-op plus warmed Question/100-Question calls follow five warmups. Not native host startup or live-model quality; instrumentation exists only in this finite benchmark process.'};
 }finally{hook.deregister();fs.openSync=originalOpen;JSON.parse=originalParse;delete globalThis.__readingBenchCompile;syncBuiltinESMExports();}
}
if(process.argv[1]===file){const result=process.argv[2]==='--sample'?await sample(Number(process.argv[3]),Number(process.argv[4])):await measureOverhead();console.log(JSON.stringify(result,null,2));}
