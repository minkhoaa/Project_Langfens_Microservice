import '../../../test/offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync,writeFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join } from 'node:path';
import { createNativeFixture } from './native-helpers.mjs';
import { replayEvidence } from '../bench/artifact-replay.mjs';
import { q } from './helpers.mjs';

function pilotPaper(type='MULTIPLE_CHOICE_SINGLE') {
 const questions=Array.from({length:13},(_,i)=>{
  const question=q(type);
  return {...question,id:`q${i+1}`,idx:i+1,sectionId:'s1',groupId:'g1',options:question.options.map((o,j)=>({...o,id:`q${i+1}:o${j+1}`}))};
 });
 return {id:'e1',complete:true,expectedQuestionCount:13,sections:[{id:'s1',idx:1,passageMd:'A river flows north.',questionGroups:[{id:'g1',idx:1,questions}]}]};
}

test('13-mark pilot blocks multi-slot structures without removing canonical practice support',async t=>{
 const f=await createNativeFixture(t);
 for(const type of ['MULTIPLE_CHOICE_MULTIPLE','SUMMARY_COMPLETION','MATCHING_INFORMATION','FLOW_CHART']){
  const paper=pilotPaper();const first=paper.sections[0].questionGroups[0].questions[0];
  const multi=q(type);
  if(type==='SUMMARY_COMPLETION'){multi.promptMd='ONE WORD ONLY. The [1] crosses the [2].';multi.blankAcceptTexts={'1':['river'],'2':['forest']};delete multi.blankAcceptRegex;}
  Object.assign(first,multi,{id:first.id,sectionId:'s1',groupId:'g1',idx:1,options:multi.options.map((o,i)=>({...o,id:`multi:o${i+1}`}))});
  const ordinary=await f.invoke('validate_exam',{exam:paper});
  assert.equal(ordinary.isError,false,type); // canonical practice structures remain available
  const result=await f.invoke('validate_exam',{exam:paper,pilot:true});
  assert.equal(result.isError,true,type);
  assert.equal(result.details.data.claims.structure,'PASS'); // policy rejection is not a canonical schema defect
  assert.ok(result.details.diagnostics.some(d=>d.code==='PILOT_UNSUPPORTED_SCORING_STRUCTURE'),JSON.stringify(result.details));
 }
});

test('13-mark pilot requires a complete passage-bearing canonical artifact and exact counts',async t=>{
 const f=await createNativeFixture(t);
 const cases=[
  [e=>{delete e.sections[0].passageMd;},'PILOT_PASSAGE_REQUIRED'],
  [e=>{e.sections[0].passageMd='  ';},'PILOT_PASSAGE_REQUIRED'],
  [e=>{e.complete=false;},'PILOT_COMPLETENESS_REQUIRED'],
  [e=>{e.sections[0].questionGroups[0].questions.pop();},'PILOT_MARK_COUNT'],
 ];
 for(const [mutate,code] of cases){const paper=pilotPaper();mutate(paper);
  const result=await f.invoke('validate_exam',{exam:paper,pilot:true});
  assert.equal(result.isError,true);assert.ok(result.details.diagnostics.some(d=>d.code===code),JSON.stringify(result.details));
 }
 const paper=pilotPaper();writeFileSync(join(f.cwd,'pilot.json'),JSON.stringify(paper));
 const result=await f.invoke('validate_exam',{exam:{file:'pilot.json'},pilot:true});
 assert.equal(result.isError,false);assert.equal(result.details.data.pilot.status,'PASS');
 assert.equal(result.details.data.questionCount,13);assert.equal(result.details.data.answerSlots,13);assert.equal(result.details.data.scoringUnits,13);
 assert.equal(result.details.status,'UNVERIFIED'); // mechanical pilot PASS is NOT quality PASS
 assert.equal(result.details.data.claims.ieltsSemantics,'UNVERIFIED');
 assert.equal((await f.invoke('validate_exam',{exam:paper,pilot:'true'})).isError,true);
 assert.equal((await f.invoke('validate_exam',{exam:paper,pilot:false})).details.data.pilot,undefined);
 const unsupported=pilotPaper();unsupported.sections[0].questionGroups[0].questions[0].type='MATCHING_EXERCISE';
 assert.equal((await f.invoke('validate_exam',{exam:unsupported,pilot:true})).isError,true);
});

test('saved historical exports replay offline: missing passage and 18-slot paper block; r5 passes mechanics only',async t=>{
 const f=await createNativeFixture(t);
 for(const [file,hash,slots,code] of [
  ['export-without-passage.json','4dcfb571fc0364ac96753e30864890170316bd6f47de62a3149036110b4491e9',13,'PILOT_PASSAGE_REQUIRED'],
  ['pilot-r2-scoring-reconstruction.json',null,18,'PILOT_UNSUPPORTED_SCORING_STRUCTURE'],
  ['pilot-r5.json','a5b092d9219a5a43d922b087bb0cca8036f4ad4c2278d54cbd17d2d1bd94e5f3',13,null],
 ]){
  const path=new URL(`./fixtures/${file}`,import.meta.url),bytes=readFileSync(path);
  if(hash)assert.equal(createHash('sha256').update(bytes).digest('hex'),hash);
  const ordinary=await f.invoke('validate_exam',{exam:{file:path.pathname}});
  assert.equal(ordinary.isError,false,file);assert.equal(ordinary.details.data.questionCount,13);
  assert.equal(ordinary.details.data.answerSlots,slots);assert.equal(ordinary.details.data.scoringUnits,13);
  const pilot=await f.invoke('validate_exam',{exam:{file:path.pathname},pilot:true});
  assert.equal(pilot.isError,!!code,file);
  if(code)assert.ok(pilot.details.diagnostics.some(d=>d.code===code));
  else {
   assert.equal(pilot.details.data.pilot.status,'PASS');
   assert.equal(pilot.details.checks.filter(c=>c.id==='STRUCTURE'&&c.status==='PASS').length,13);
   assert.equal(pilot.details.data.groupCount,4);
   assert.equal(pilot.details.data.claims.hierarchy,'PASS');
  }
  assert.equal(pilot.details.data.claims.ieltsSemantics,'UNVERIFIED');
  assert.equal(pilot.details.data.claims.consumerCompatibility,'UNVERIFIED');
  t.diagnostic(JSON.stringify({file,canonical:ordinary.details.status,pilot:pilot.details.data.pilot.status,questions:13,answerSlots:slots,scoringUnits:ordinary.details.data.scoringUnits}));
 }
});

test('native replay rejects the recorded r5 call and accepts saved numeric spans for all 13 items',async()=>{
 const fixture=name=>new URL(`./fixtures/${name}`,import.meta.url).pathname;
 const result=await replayEvidence(fixture('rejected-evidence.jsonl'),fixture('pilot-r5.json'),fixture('pilot-spans.json'));
 assert.equal(result.before.toolCalls,1);assert.equal(result.before.failedCalls,1);assert.equal(result.before.spanPasses,0);
 assert.equal(result.after.toolCalls,13);assert.equal(result.after.failedCalls,0);assert.equal(result.after.spanPasses,16);
 assert.equal(result.providerTokens,0);assert.equal(result.subagentLaunches,0);
 assert.match(result.quality,/UNVERIFIED/);
});

test('recorded string offsets identify the wrong field without coercion or a diagnostic sweep',async t=>{
 const f=await createNativeFixture(t);
 const args={question:q('TRUE_FALSE_NOT_GIVEN'),passage:'river',evidence:{start:'0',end:'5',quote:'river'}};
 const result=await f.invoke('verify_evidence',args);
 assert.equal(result.isError,true);assert.equal(result.details.contractHash,null);
 assert.ok(result.details.diagnostics.some(d=>d.code==='NATIVE_ARGUMENT_INVALID'&&d.path==='/evidence/start'),JSON.stringify(result.details));
 assert.ok(result.details.diagnostics.some(d=>d.path==='/evidence/end'));
 assert.equal(args.evidence.start,'0');
 writeFileSync(join(f.cwd,'spans.json'),JSON.stringify({start:0,end:5,quote:'river'}));
 const saved=await f.invoke('verify_evidence',{...args,evidence:{file:'spans.json'}});
 assert.equal(saved.isError,false);assert.ok(saved.details.checks.some(c=>c.id==='EVIDENCE_SPAN'&&c.status==='PASS'));
});
