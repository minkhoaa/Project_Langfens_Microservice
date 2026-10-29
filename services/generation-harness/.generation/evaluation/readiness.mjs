// Offline preparation readiness is distinct from semantic pilot quality.
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { rubric } from './schemas.mjs';
export const readinessRequirements=['deterministicStructureScoringDelivery','leakageAndUnauthorizedAccess','pilotCompatibility','reproducibleSchemasFixturesEvidence','threeWayJudgments','independentReviewAndHumanAdjudication','frozenBackendBoundary'];
export function evaluateReadiness(receipt) {
  if(receipt?.version!==rubric.version || receipt.evidenceClass!=='OFFLINE_TESTS' || !Array.isArray(receipt.requirements) || !Array.isArray(receipt.commands)) throw new Error('Invalid readiness receipt');
  const commandIds=receipt.commands.map(c=>c.id);
  if(new Set(commandIds).size!==commandIds.length || new Set(receipt.requirements.map(r=>r.id)).size!==receipt.requirements.length || receipt.requirements.some(r=>!readinessRequirements.includes(r.id) || !rubric.verdicts.includes(r.verdict))) throw new Error('Invalid readiness coverage');
  const missing=readinessRequirements.filter(id=>!receipt.requirements.some(r=>r.id===id));
  const fail=receipt.requirements.some(r=>r.verdict==='FAIL') || receipt.commands.some(c=>c.exitCode!==null && c.exitCode!==0);
  const incomplete=missing.length>0 || receipt.commands.length===0 || receipt.requirements.some(r=>r.verdict!=='PASS' || !r.reason || !r.commandIds?.length || r.commandIds.some(id=>!commandIds.includes(id))) || receipt.commands.some(c=>c.exitCode!==0 || !c.command || !/^[a-f0-9]{64}$/.test(c.logSha256??''));
  return {version:rubric.version,readinessDecision:fail?'NO-GO':incomplete?'INSUFFICIENT_EVIDENCE':'GO',semanticPilotDecision:'INSUFFICIENT_EVIDENCE',authorizesLivePilot:false,authorizesExpansion:false,missing,requirements:receipt.requirements,limitations:['Offline fixture coverage is not proof of real-model semantic quality or arbitrary-hint detection.','GO is preparation readiness only, never authorization for inference, publication or student delivery.']};
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href) {
  try {const result=evaluateReadiness(JSON.parse(await readFile(process.argv[2],'utf8')));console.log(JSON.stringify(result,null,2));process.exitCode=result.readinessDecision==='GO'?0:result.readinessDecision==='NO-GO'?2:3;}
  catch(e) {console.error(e.message);process.exitCode=1;}
}
