import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, writeFile, rm, symlink } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { evaluate } from '../.generation/evaluation/report.mjs';
import { auditManifest, manifestDigest } from '../.generation/evaluation/evidence.mjs';
import { completeFixture } from '../.generation/evaluation/fixtures/pilot.mjs';
import { exactInterval } from '../.generation/evaluation/statistics.mjs';
import { modelOutputSchemas, validate } from '../.generation/evaluation/schemas.mjs';
const verified={verdict:'PASS',problems:[]};
// REAL_MODEL below is deliberate label spoofing for branch tests, NOT live evidence.
function spoofed() {const {record:f}=completeFixture();f.evidenceClass='REAL_MODEL';f.reviews.forEach(r=>r.source='model');return f;}
function change(f,i,criterion,verdict,severity='none') {
  for(const r of f.reviews.filter(r=>r.questionId===f.artifact.questions[i].id)) Object.assign(r.judgments.find(j=>j.criterion===criterion),{verdict,severity,category:verdict==='PASS'?'none':'test_defect'});
}
function adjudicate(f,i,criterion,verdict,severity='none') {
  f.adjudications.push({questionId:f.artifact.questions[i].id,criterion,source:'human',adjudicatorId:'synthetic-adjudicator',reasoning:'Synthetic human reasoning.',verdict,severity,reason:'Synthetic resolution.',category:verdict==='PASS'?'none':'test_defect',spans:f.artifact.questions[i].evidence});
}
test('complete synthetic 13-item fixture never grants quality approval',()=>{
  assert.equal(evaluate(completeFixture().record,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
});
test('all-pass label-spoofed branch requires verified evidence and human protocol audit',()=>{
  const f=spoofed();
  assert.equal(evaluate(f).pilotDecision,'INSUFFICIENT_EVIDENCE');
  const r=evaluate(f,verified);
  assert.equal(r.pilotDecision,'GO');assert.equal(r.authorizesLivePilot,false);
  assert.equal(r.advancementDecision,'INSUFFICIENT_EVIDENCE');assert.equal(r.targets.answerable,13);
  delete f.protocolAudit;
  assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
});
test('12/13 quality is allowed, 11/13 fails; all 13 must remain answerable',()=>{
  const f=spoofed();change(f,0,'style','FAIL','minor');
  assert.equal(evaluate(f,verified).pilotDecision,'GO');
  change(f,1,'distractors','FAIL','minor');
  assert.equal(evaluate(f,verified).pilotDecision,'NO-GO');
  change(f,0,'answerability','FAIL','critical');
  assert.equal(evaluate(f,verified).targets.answerable,12);
});
test('agreed critical defects still require human adjudication and remain NO-GO',()=>{
  const f=spoofed();change(f,0,'evidence','FAIL','critical');
  let r=evaluate(f,verified);assert.equal(r.pilotDecision,'NO-GO');assert.ok(r.questions[0].unresolved.includes('evidence'));
  adjudicate(f,0,'evidence','PASS');r=evaluate(f,verified);
  assert.equal(r.pilotDecision,'GO');assert.equal(r.questions[0].originalReviews[0].judgments[1].verdict,'FAIL');
});
test('UNCERTAIN stays unresolved even with human UNCERTAIN, never becomes native approval',()=>{
  const f=spoofed();change(f,0,'difficulty','UNCERTAIN');adjudicate(f,0,'difficulty','UNCERTAIN');
  const r=evaluate(f,verified);assert.equal(r.pilotDecision,'INSUFFICIENT_EVIDENCE');
  assert.equal(r.questions[0].judgments.find(j=>j.criterion==='difficulty').verdict,'UNCERTAIN');
  assert.equal(r.metrics.originalUncertainJudgments,2);
});
test('severity and category disagreements require adjudication',()=>{
  const f=spoofed();change(f,0,'style','FAIL','minor');f.reviews[1].judgments.find(j=>j.criterion==='style').severity='major';
  assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
  adjudicate(f,0,'style','FAIL','minor');assert.equal(evaluate(f,verified).pilotDecision,'GO');
});
test('blind mismatch is not critical truth by itself but requires human resolution',()=>{
  const f=spoofed();f.solverAnswers[0].answer='different';
  assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
  f.solverAdjudications.push({questionId:f.artifact.questions[0].id,source:'human',adjudicatorId:'synthetic-adjudicator',verdict:'PASS',reasoning:'Solver erred; key is unique and supported.',spans:f.artifact.questions[0].evidence});
  assert.equal(evaluate(f,verified).pilotDecision,'GO');
  f.solverAdjudications[0].verdict='FAIL';assert.equal(evaluate(f,verified).pilotDecision,'NO-GO');
});
for(const field of ['usage','latencyMs','cost']) test(`unknown ${field} is not zero or PASS`,()=>{
  const f=spoofed();f.reviews[0].metadata[field]=null;assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
});
test('unverified manifest, missing raw records, evidence and audit checks fail closed',()=>{
  for(const mutate of [f=>f.manifest.pop(),f=>delete f.reviews[0].raw,f=>delete f.artifact.questions[0].evidence,f=>f.protocolAudit.checks.independence='UNCERTAIN']) {
    const f=spoofed();mutate(f);assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
  }
  const f=spoofed();f.protocolAudit.checks.noLeakage='FAIL';assert.equal(evaluate(f,verified).pilotDecision,'NO-GO');
});
test('bad offsets, wrong section and Unicode code-point offsets are rejected',()=>{
  const f=spoofed();f.artifact.questions[0].evidence=[{sectionId:'foreign',start:0,end:1,quote:'A'}];
  assert.equal(evaluate(f,verified).pilotDecision,'NO-GO');
  const u=spoofed(), s=u.artifact.sections[0];s.passage='😀text';
  // All original spans now mismatch; UTF-16 end=2, not code-point end=1.
  u.artifact.questions[0].evidence=[{sectionId:s.id,start:0,end:1,quote:'😀'}];
  assert.ok(evaluate(u,verified).invalidSpans.includes(u.artifact.questions[0].id));
});
test('sessions cannot be shared across roles and adjudicators cannot be model participants',()=>{
  const f=spoofed();f.reviews[0].sessionId=f.solverAnswers[0].sessionId;assert.throws(()=>evaluate(f),/independence/);
  const g=spoofed();adjudicate(g,0,'style','PASS');g.adjudications[0].adjudicatorId=g.generator.sessionId;assert.throws(()=>evaluate(g),/independent human/);
});
test('deterministic FAIL/UNCERTAIN stay distinct; unknown fields and malformed judgments rejected',()=>{
  const f=spoofed();f.deterministic.scoring='UNCERTAIN';assert.equal(evaluate(f,verified).pilotDecision,'INSUFFICIENT_EVIDENCE');
  f.deterministic.scoring='FAIL';assert.equal(evaluate(f,verified).pilotDecision,'NO-GO');
  f.deterministic.scoring='PASS';f.deterministic.extra='PASS';assert.throws(()=>evaluate(f),/schema/);
  const g=spoofed();change(g,0,'answerability','FAIL','minor');assert.throws(()=>evaluate(g),/critical severity/);
});
test('executable reviewer and solver model-output schemas validate raw shapes',()=>{
  const f=spoofed(), review=f.reviews[0], solver=f.solverAnswers[0];
  validate(modelOutputSchemas.reviewer,{questionId:review.questionId,reasoning:review.reasoning,judgments:review.judgments});
  validate(modelOutputSchemas.solver,{questionId:solver.questionId,answer:solver.answer,confidence:solver.confidence,spans:solver.spans});
  assert.throws(()=>validate(modelOutputSchemas.solver,{...solver,confidence:2}),/schema/);
});
test('manifest verifies bytes, detects tampering/missing files and root escapes',async t=>{
  const root=await mkdtemp(join(tmpdir(),'vs4-evidence-'));t.after(()=>rm(root,{recursive:true,force:true}));
  const {record:f,files}=completeFixture();for(const [path,body] of files) await writeFile(join(root,path),body);
  assert.equal((await auditManifest(f,root)).verdict,'PASS');
  await writeFile(join(root,'canonical.txt'),'tampered');assert.equal((await auditManifest(f,root)).verdict,'FAIL');
  await rm(join(root,'canonical.txt'));assert.equal((await auditManifest(f,root)).verdict,'UNCERTAIN');
  const entry=f.manifest.find(x=>x.role==='canonical');entry.path='../outside';f.protocolAudit.manifestDigest=manifestDigest(f.manifest);
  assert.equal((await auditManifest(f,root)).verdict,'FAIL');
  entry.path='canonical.txt';f.protocolAudit.manifestDigest=manifestDigest(f.manifest);
  await symlink(join(root,'..'),join(root,'canonical.txt'));assert.equal((await auditManifest(f,root)).verdict,'FAIL');
});
test('CLI exit codes distinguish GO, NO-GO, malformed and insufficient records',async t=>{
  const root=await mkdtemp(join(tmpdir(),'vs4-cli-'));t.after(()=>rm(root,{recursive:true,force:true}));
  const {record:f,files}=completeFixture();for(const [path,body] of files) await writeFile(join(root,path),body);
  const path=join(root,'record.json'), script=fileURLToPath(new URL('../.generation/evaluation/report.mjs',import.meta.url));
  const run=(withRoot=true)=>spawnSync(process.execPath,[script,path,...(withRoot?['--evidence-root',root]:[])],{encoding:'utf8',env:{...process.env,GENERATION_HARNESS_OFFLINE:'1'}});
  await writeFile(path,JSON.stringify(f));assert.equal(run().status,3);
  f.evidenceClass='REAL_MODEL';f.reviews.forEach(r=>r.source='model');await writeFile(path,JSON.stringify(f));
  assert.equal(run(false).status,3);
  const passed=run();assert.equal(passed.status,0,passed.stderr);assert.equal(JSON.parse(passed.stdout).authorizesLivePilot,false);
  f.deterministic.delivery='FAIL';await writeFile(path,JSON.stringify(f));assert.equal(run().status,2);
  await writeFile(path,'{}');assert.equal(run().status,1);
});
test('reports reproduce without mutating original judgments',()=>{
  const f=spoofed(), before=JSON.stringify(f);
  assert.deepEqual(evaluate(f,verified),evaluate(f,verified));assert.equal(JSON.stringify(f),before);
});
test('exact confidence bounds show why one Section cannot support expansion',()=>{
  assert.ok(Math.abs(exactInterval(0,13).upper-(1-Math.pow(0.025,1/13)))<1e-10);
  assert.ok(exactInterval(0,13).upper>0.24);
  assert.ok(exactInterval(0,390).upper<0.01);
  assert.ok(exactInterval(0,30).upper>0.10); // 30 sections alone misses proposed 10% upper bound.
  assert.ok(exactInterval(0,36).upper<0.10);
  assert.ok(Math.abs(exactInterval(5,10).lower-(1-exactInterval(5,10).upper))<1e-10);
  assert.throws(()=>exactInterval(2,1));
});
