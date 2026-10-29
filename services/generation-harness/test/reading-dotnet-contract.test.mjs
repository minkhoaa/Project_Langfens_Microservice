import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { resolve, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { canonicalQuestion, canonicalPilot } from '../.generation/fixtures/canonical-v1.mjs';
import { families } from '../.generation/reading/contracts.ts';
import { grade } from '../.generation/reading/grading.ts';

const root = resolve(fileURLToPath(new URL('..', import.meta.url)));
const project = join(root, 'test/dotnet-contract/GraderFixture.csproj');
const env = { ...process.env, DOTNET_CLI_TELEMETRY_OPTOUT:'1', DOTNET_SKIP_FIRST_TIME_EXPERIENCE:'1' };
function run(args, input) {
  const r = spawnSync('dotnet', args, { cwd:root, env, input, encoding:'utf8', timeout:120000, maxBuffer:16*1024*1024 });
  assert.equal(r.status, 0, `${r.error ?? ''}\n${r.stdout}\n${r.stderr}`);
  return r.stdout;
}
const correct = q => {
  if (['single','multiple'].includes(families[q.type])) return {selectedOptionIds:q.options.filter(o=>o.isCorrect).map(o=>o.id)};
  if (q.blankAcceptTexts) return {textAnswer:JSON.stringify(Object.fromEntries(Object.entries(q.blankAcceptTexts).map(([k,v])=>[k,v[0]])))};
  if (q.matchPairs) return {textAnswer:JSON.stringify(Object.fromEntries(Object.entries(q.matchPairs).map(([k,v])=>[k,v[0]])))};
  if (q.orderCorrects) return {textAnswer:JSON.stringify(q.orderCorrects)};
  return {textAnswer:q.shortAnswerAcceptTexts[0]};
};

test('actual .NET AnswerValidator and graders: all 19 types plus immutable 13-item pilot fixture adapter', t => {
  // No remote/host-configured NuGet feeds. Unavailable cache is a failing prerequisite, not a skip.
  run(['restore',project,'--configfile',join(root,'test/dotnet-contract/NuGet.Config'),'-p:NuGetAudit=false']);
  run(['build',project,'--no-restore']);
  const cases = [];
  for (const [scope, qs] of [['all19',Object.keys(families).map((type,i)=>canonicalQuestion(type,i+1))], ['pilot13',canonicalPilot().sections.flatMap(s=>s.questionGroups.flatMap(g=>g.questions))]]) {
    for (const q of qs) {
      const add = (name,answer,expected) => cases.push({id:`${scope}/${q.type}/${q.idx}/${name}`,question:q,answer,expected});
      add('correct',correct(q),true);
      add('incorrect',{textAnswer:'definitely incorrect'},false);
      add('empty',{},false);
      add('cleared',{selectedOptionIds:[],textAnswer:''},false);
      if (families[q.type] === 'multiple') add('partial',{selectedOptionIds:[q.options.find(o=>o.isCorrect).id]},false);
      if (q.matchPairs) add('partial',{textAnswer:JSON.stringify({'1':q.matchPairs['1'][0]})},false);
    }
  }
  const dll = join(root,'test/dotnet-contract/bin/Debug/net10.0/GraderFixture.dll');
  const actual = JSON.parse(run([dll],JSON.stringify(cases)));
  assert.equal(actual.length,cases.length);
  actual.forEach((r,i)=>{
    assert.equal(r.id,cases[i].id);
    assert.equal(r.validation,null,r.id);
    assert.equal(r.isCorrect,cases[i].expected,r.id);
    assert.equal(r.awardedPoints,cases[i].expected?1:0,r.id);
    assert.equal(r.isCorrect,grade(cases[i].question,cases[i].answer).isCorrect,r.id);
  });
  // Explicitly expose the pre-existing dirty consumer divergence rather than call JS parity verified.
  const flow = canonicalQuestion('FLOW_CHART');
  const casing = {id:'flow/lowercase-object',question:flow,answer:{textAnswer:JSON.stringify({steps:flow.orderCorrects})}};
  const [observed] = JSON.parse(run([dll],JSON.stringify([casing])));
  const simulated = grade(flow,casing.answer);
  assert.equal(observed.isCorrect,true,'Existing dirty .NET patch accepts lowercase steps');
  assert.equal(simulated.isCorrect,false,'Frozen legacy JS oracle still models committed casing');
  const privacy = JSON.parse(run([dll,'--privacy-probe']));
  assert.deepEqual(privacy,{explanationLeaked:true,acceptedValuesRemoved:true,originalUnchanged:true});
  t.diagnostic(JSON.stringify({knownProductionBlocker:{privacy,classification:'CONFIRMED_EXISTING_STUDENT_EXPLANATION_LEAK'},cases:cases.length,pilotQuestions:13,pilotIntendedMarks:13,consumerSource:'actual .NET referenced assembly',knownDivergences:[{id:casing.id,dotnet:observed.isCorrect,legacyJs:simulated.isCorrect,classification:'PRE_EXISTING_DIRTY_CONSUMER_DIFF'}],frontendRoundtrip:'UNVERIFIED'}));
});
