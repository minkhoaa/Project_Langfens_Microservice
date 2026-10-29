import './offline.mjs';
import test from 'node:test';
import assert from 'node:assert/strict';
import { evaluateReadiness, readinessRequirements } from '../.generation/evaluation/readiness.mjs';
const receipt=()=>({version:'vs4.1',evidenceClass:'OFFLINE_TESTS',commands:[{id:'tests',command:'synthetic test command',exitCode:0,logSha256:'a'.repeat(64)}],requirements:readinessRequirements.map(id=>({id,verdict:'PASS',reason:'Synthetic branch coverage only.',commandIds:['tests']}))});
test('readiness GO never authorizes pilot or implies real semantic evidence',()=>{
  const r=evaluateReadiness(receipt());assert.equal(r.readinessDecision,'GO');assert.equal(r.authorizesLivePilot,false);assert.equal(r.authorizesExpansion,false);assert.equal(r.semanticPilotDecision,'INSUFFICIENT_EVIDENCE');
});
test('offline FAIL and UNCERTAIN remain distinct',()=>{
  const f=receipt();f.requirements[0].verdict='UNCERTAIN';assert.equal(evaluateReadiness(f).readinessDecision,'INSUFFICIENT_EVIDENCE');
  f.requirements[0].verdict='FAIL';assert.equal(evaluateReadiness(f).readinessDecision,'NO-GO');
});
test('missing requirements or evidence cannot silently count as PASS',()=>{
  for(const mutate of [f=>f.requirements.pop(),f=>f.commands.splice(0),f=>f.requirements[0].commandIds.push('missing'),f=>delete f.commands[0].logSha256]) {
    const f=receipt();mutate(f);assert.equal(evaluateReadiness(f).readinessDecision,'INSUFFICIENT_EVIDENCE');
  }
  const f=receipt();f.requirements.push(f.requirements[0]);assert.throws(()=>evaluateReadiness(f),/coverage/);
});
