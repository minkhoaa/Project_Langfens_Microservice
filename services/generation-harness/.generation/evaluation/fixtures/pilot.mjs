// Complete SYNTHETIC gate fixture, never quality evidence or a generation example.
import { readFileSync } from 'node:fs';
import base from './records.mjs';
import { manifestDigest, sha256 } from '../evidence.mjs';
import { protocolChecks, rubric } from '../schemas.mjs';
export function completeFixture() {
  const f=structuredClone(base), template=f.artifact.questions[0];
  const passage=f.artifact.sections[0].passage;
  const span={sectionId:template.sectionId,start:0,end:passage.length,quote:passage};
  const meta={provider:'synthetic',model:'fixture-only',version:'1',prompt:'Synthetic schema test, not a model prompt.',temperature:0,usage:{inputTokens:1,outputTokens:1},latencyMs:0,cost:0,currency:'USD',costBasis:'Synthetic zero, not an incurred cost.'};
  f.artifact.questions=Array.from({length:13},(_,i)=>({...template,id:`fixture-q${i+1}`,acceptedAnswers:['fixture answer'],evidence:[span]}));
  f.generator={sessionId:'synthetic-generator',raw:'SYNTHETIC generator response',metadata:meta};
  f.solverAnswers=f.artifact.questions.map(q=>({questionId:q.id,answer:'fixture answer',confidence:0.5,spans:[span],raw:'SYNTHETIC solver response',sessionId:'synthetic-solver',metadata:meta}));
  f.reviews=f.artifact.questions.flatMap(q=>[0,1].map(i=>({questionId:q.id,sessionId:`synthetic-reviewer-${i}`,source:'synthetic',raw:`SYNTHETIC review response ${i}`,metadata:meta,reasoning:'Fixture only, not a real semantic judgment.',judgments:rubric.criteria.map(criterion=>({criterion,verdict:'PASS',severity:'none',reason:'Synthetic branch coverage only.',category:'none',spans:[span]}))})));
  f.solverAdjudications=[];
  const files=new Map();
  const add=(role,path,body,sessionId)=>{files.set(path,body);return {role,path,sha256:sha256(body),...(sessionId?{sessionId}:{})};};
  f.manifest=['assignment','prompt','canonical','projection','native_results','lifecycle','human_review'].map(role=>add(role,`${role}.txt`,`SYNTHETIC ${role}; not a real receipt.`));
  f.manifest.push(add('rubric','rubric.json',readFileSync(new URL('../rubric.json',import.meta.url),'utf8')));
  f.manifest.push(add('generator_raw','generator.txt',f.generator.raw,f.generator.sessionId));
  f.manifest.push(add('solver_raw','solver.txt',f.solverAnswers[0].raw,f.solverAnswers[0].sessionId));
  for(let i=0;i<2;i++) f.manifest.push(add('reviewer_raw',`reviewer-${i}.txt`,f.reviews[i].raw,f.reviews[i].sessionId));
  f.protocolAudit={source:'human',adjudicatorId:'synthetic-human',verdict:'PASS',reasoning:'Synthetic attestation, not an actual human audit.',manifestDigest:manifestDigest(f.manifest),checks:Object.fromEntries(protocolChecks.map(k=>[k,'PASS']))};
  return {record:f,files};
}
