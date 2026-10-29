// Sequential offline verification launcher, NOT an agent coordinator/generation pipeline.
import '../../test/offline.mjs';
import { spawnSync } from 'node:child_process';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { resolve, join } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { sha256 } from './evidence.mjs';
import { rubric } from './schemas.mjs';
import { evaluateReadiness, readinessRequirements } from './readiness.mjs';
const root=fileURLToPath(new URL('../..',import.meta.url)), repository=resolve(root,'../..');
const output=process.argv[2];
if(!output || process.argv.length!==3) throw new Error('Usage: node .generation/evaluation/run-offline.mjs NEW-OUTPUT-DIRECTORY');
const out=resolve(output);
await mkdir(out,{mode:0o700}); // Refuse to overwrite a prior evidence run.
const env={...process.env,GENERATION_HARNESS_OFFLINE:'1',NODE_OPTIONS:`--import=${pathToFileURL(join(root,'test/offline.mjs')).href}`};
const commands=[];
const specs=[
  ['typecheck','npm',['run','typecheck'],root],
  ['domain-typecheck',process.execPath,['node_modules/typescript/bin/tsc','--noEmit','--project','.generation/tsconfig.json'],root],
  ['build','npm',['run','build'],root],
  ['tests','npm',['test'],root],
  ['contract-tests',process.execPath,['--test',...[
    'test/reading-canonical-contracts.test.mjs','test/reading-hardened-contracts.test.mjs',
    'test/reading-dotnet-contract.test.mjs','test/reading-contract-replay.test.mjs','test/reading-trace-metrics.test.mjs',
  ]],root],
  ['dotnet-unit','dotnet',['test','services/attempt-service.Tests/attempt-service.Tests.csproj','--no-restore'],repository],
  ['frozen-diff','git',['diff','--exit-code','--','services/generation-harness/packages',':(glob)services/*-service*/**','services/_shared','AppHost','gateway'],repository],
  ['frozen-status','git',['status','--porcelain','--untracked-files=all','--','services/generation-harness/packages',':(glob)services/*-service*/**','services/_shared','AppHost','gateway'],repository],
  ['whitespace','git',['diff','--check'],repository],
];
for(const [id,exe,args,cwd] of specs) {
  console.error(`Offline check: ${id}`);
  const result=spawnSync(exe,args,{cwd,env,encoding:'utf8',timeout:600000,maxBuffer:64*1024*1024});
  const log=`${result.stdout??''}${result.stderr??''}${result.error?`\n${result.error.message}`:''}`;
  await writeFile(join(out,`${id}.log`),log,{mode:0o600});
  const exitCode=id==='frozen-status' && log.trim()?1:result.status;
  commands.push({id,command:[exe,...args].join(' '),exitCode,log:`${id}.log`,logSha256:sha256(log)});
  if(exitCode!==0) break; // Failure is recorded, not retried or bypassed.
}
const explanations={
  deterministicStructureScoringDelivery:'Native VS1–VS3 and all 19 type regressions exercise structure, scoring and delivery; no fixture validation failures permitted.',
  leakageAndUnauthorizedAccess:'Offline native blind-child/tool/context restrictions and known raw/encoded leakage attacks tested; arbitrary natural-language hints remain a human pilot-audit obligation.',
  pilotCompatibility:'Legacy VS fixtures retain their source-derived compatibility checks. Canonical strict pilot scope is TFNG, one-slot summary completion and single choice only; actual frontend round trips remain unverified.',
  reproducibleSchemasFixturesEvidence:'Versioned rubric, native canonical generator schema, solver/reviewer/adjudication schemas, synthetic records, manifest hashing and tamper fixtures exercised.',
  threeWayJudgments:'PASS/FAIL/UNCERTAIN and GO/NO-GO/INSUFFICIENT_EVIDENCE branches tested; verify_evidence remains PASS/FAIL only.',
  independentReviewAndHumanAdjudication:'Two reviews per criterion/item; disagreement, critical defect, uncertainty and solver mismatch adjudication enforced; human identities still require external accountability.',
  frozenBackendBoundary:'Gate requires empty tracked diff and untracked status for frozen packages and backend service sources; pre-existing dirty changes are not an automatic waiver.',
};
const requirements=readinessRequirements.map(id=>{
  const commandIds=id==='frozenBackendBoundary'?['frozen-diff','frozen-status']:['typecheck','domain-typecheck','build','tests','contract-tests','dotnet-unit'];
  const observed=commandIds.map(key=>commands.find(c=>c.id===key));
  const failed=observed.filter(c=>c && c.exitCode!==null && c.exitCode!==0);
  const verdict=failed.length?'FAIL':observed.every(c=>c?.exitCode===0)?'PASS':'UNCERTAIN';
  return {id,verdict,commandIds,reason:`${explanations[id]} Observed: ${failed.length?`failed ${failed.map(c=>c.id).join(', ')}`:verdict==='PASS'?'all scoped checks passed':'some scoped checks were not executed'}. Scope is offline domain instrumentation, not consumer/production approval.`};
});
const sourcePaths=['package.json','README.md','scripts/config.mjs','scripts/configuration.mjs','scripts/configuration-ui.mjs','scripts/configuration-resources.mjs','scripts/configuration-resources-ui.mjs','scripts/configuration-resolver.mjs','scripts/runtime.mjs','test/config.test.mjs','test/config-resources.test.mjs','.generation/settings.json','.generation/README.md','.generation/config/README.md','.generation/config/models.example.json','.generation/evaluation/rubric.json','.generation/evaluation/schemas.mjs','.generation/evaluation/report.mjs','.generation/evaluation/evidence.mjs','.generation/evaluation/statistics.mjs','.generation/evaluation/readiness.mjs','.generation/evaluation/run-offline.mjs','.generation/evaluation/README.md','.generation/evaluation/fixtures/records.mjs','.generation/evaluation/fixtures/pilot.mjs','.generation/evaluation/fixtures/held-out-section.json','.generation/extensions/reading.ts','.generation/reading/contracts.ts','.generation/reading/grading.ts','.generation/reading/validation.ts','.generation/reading/projection.ts','.generation/reading/blind-guard.ts','.generation/agents/semantic-reviewer.md','.generation/agents/blind-solver.md','test/offline.mjs','test/reading.test.mjs','test/reading-vs3.mjs','test/reading-vs4.test.mjs','test/reading-vs4-gate.test.mjs','test/reading-vs4-acceptance.test.mjs','test/reading-vs4-readiness.test.mjs'];
sourcePaths.push('.generation/contracts/IMPLEMENTATION-v1.md', '.generation/agents/reading-generator.md', '.generation/agents/question-validator.md', '.generation/prompts/reading-system.md', '.generation/contracts/question-types.v1.schema.json', '.generation/reading/canonical.ts', '.generation/reading/diagnostics.ts', '.generation/reading/repair-policy.ts', '.generation/fixtures/canonical-v1.mjs', '.generation/evaluation/contract-trace-metrics.mjs', 'test/reading-canonical-contracts.test.mjs', 'test/reading-hardened-contracts.test.mjs', 'test/reading-dotnet-contract.test.mjs', 'test/reading-contract-replay.test.mjs', 'test/reading-trace-metrics.test.mjs', 'test/dotnet-contract/GraderFixture.csproj', 'test/dotnet-contract/Program.cs', 'test/dotnet-contract/NuGet.Config');
sourcePaths.push('.generation/fixtures/reading.mjs', '.generation/fixtures/section-vs2.json', '.generation/fixtures/evidence-vs2.json', '.generation/evaluation/evidence/official-ielts-recheck.json', '.generation/evaluation/evidence/contract-early-traces.json', '.generation/evaluation/evidence/contract-later-traces.json');
sourcePaths.push('../attempt-service/Features/Helpers/Grader.cs', '../attempt-service/Features/Helpers/GraderHelper.cs', '../attempt-service/Features/Helpers/BuildQuestionIdSet.cs', '../attempt-service/Features/Helpers/QuestionGraderRegistration.cs', '../attempt-service/Features/Helpers/ExamGateway.cs', '../attempt-service/Domain/Entities/AttemptAnswer.cs', '../_shared/Shared.PublicContracts/Contracts/Exam/Enums/QuestionType.cs', '../exam-service/Data/ReadingSeeder.cs', '../exam-service/Program.cs', '../../gateway/api-gateway/appsettings.json', '../../gateway/api-gateway/Program.cs');
const sourceHashes=Object.fromEntries(await Promise.all(sourcePaths.map(async path=>[path,sha256(await readFile(join(root,path)))])));
const receipt={version:rubric.version,evidenceClass:'OFFLINE_TESTS',commands,requirements,sourceHashes,scope:'Offline instrument readiness, supported non-regex pilot types only; no semantic-quality claim or live authorization.'};
await writeFile(join(out,'receipt.json'),JSON.stringify(receipt,null,2)+'\n',{mode:0o600});
const report=evaluateReadiness(receipt);
await writeFile(join(out,'readiness.json'),JSON.stringify(report,null,2)+'\n',{mode:0o600});
console.log(JSON.stringify({output:out,...report},null,2));
process.exitCode=report.readinessDecision==='GO'?0:report.readinessDecision==='NO-GO'?2:3;
