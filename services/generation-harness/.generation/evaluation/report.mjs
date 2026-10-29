// Offline evaluation only. No native approval calls, inference, or generation orchestration.
import { readFile } from 'node:fs/promises';
import { pathToFileURL } from 'node:url';
import { rubric, record, validate } from './schemas.mjs';
import { auditManifest, manifestProblems } from './evidence.mjs';
import { confidenceMetrics } from './statistics.mjs';
const criteria=rubric.criteria, criticalCriteria=new Set(rubric.criticalCriteria);
const criticalCategories=new Set(['unsupported_key','unanswerable','multiple_answers','wrong_truth_status','leakage','scoring','unsupported_entailment']);
const identity=id=>id.trim().toLowerCase();
const demand=(condition,message)=>{if(!condition) throw new Error(message);};
const unique=xs=>new Set(xs).size===xs.length;
function checkJudgment(j) {
  demand(j.verdict!=='FAIL' || j.severity!=='none','FAIL requires severity');
  demand(j.verdict!=='PASS' || j.severity==='none','PASS requires severity none');
  demand(!(j.verdict==='FAIL' && (criticalCriteria.has(j.criterion) || criticalCategories.has(j.category)) && j.severity!=='critical'),'Critical criterion/category failure requires critical severity');
}
function summarize(rows,id) {
  return {id,questionCount:rows.length,pass:rows.filter(x=>x.verdict==='PASS').length,fail:rows.filter(x=>x.verdict==='FAIL').length,uncertain:rows.filter(x=>x.verdict==='UNCERTAIN').length,unresolved:rows.filter(x=>x.unresolved.length).length,critical:rows.filter(x=>x.critical).length};
}
export function evaluate(input, evidenceAudit={verdict:'UNCERTAIN',problems:['Evidence files not verified']}) {
  validate(record,input);
  const a=input.artifact, ids=a.questions.map(q=>q.id), sectionIds=a.sections.map(s=>s.id);
  const groups=a.sections.flatMap(s=>s.groups.map(g=>({id:g.id,sectionId:s.id})));
  demand(unique(ids) && unique(sectionIds) && unique(groups.map(g=>g.id)) && a.questions.every(q=>groups.some(g=>g.id===q.groupId && g.sectionId===q.sectionId)), 'Invalid hierarchy');
  demand(input.solverAnswers.length===ids.length && unique(input.solverAnswers.map(x=>x.questionId)) && input.solverAnswers.every(x=>ids.includes(x.questionId)), 'Solver coverage invalid');
  demand(input.reviews.length===2*ids.length && input.reviews.every(r=>ids.includes(r.questionId)), 'Two reviews per question required');
  const generatorId=input.generator.sessionId, solverIds=input.solverAnswers.map(s=>s.sessionId).filter(Boolean), reviewerIds=input.reviews.map(r=>r.sessionId);
  demand(!generatorId || ![...solverIds,...reviewerIds].some(id=>identity(id)===identity(generatorId)),'Generator session independence invalid');
  demand(!reviewerIds.some(id=>solverIds.some(s=>identity(s)===identity(id))),'Solver/reviewer session independence invalid');
  for(const id of ids) {
    const rr=input.reviews.filter(r=>r.questionId===id);
    demand(rr.length===2 && unique(rr.map(r=>identity(r.sessionId))), 'Reviewer session independence invalid');
    for(const r of rr) {
      demand(unique(r.judgments.map(j=>j.criterion)) && criteria.every(c=>r.judgments.some(j=>j.criterion===c)), 'Review criteria coverage invalid');
      r.judgments.forEach(checkJudgment);
    }
  }
  const adj=input.adjudications, solverAdj=input.solverAdjudications??[];
  const independent=id=>![generatorId,...solverIds,...reviewerIds].filter(Boolean).some(x=>identity(x)===identity(id));
  demand(unique(adj.map(x=>`${x.questionId}\0${x.criterion}`)) && unique(solverAdj.map(x=>x.questionId)), 'Duplicate adjudications');
  for(const x of [...adj,...solverAdj]) demand(ids.includes(x.questionId) && independent(x.adjudicatorId),'Invalid independent human adjudication');
  adj.forEach(checkJudgment);
  if(input.protocolAudit) demand(independent(input.protocolAudit.adjudicatorId),'Invalid independent protocol auditor');
  const spanValid=(span,sectionId)=> {
    const section=a.sections.find(s=>s.id===sectionId);
    return span.sectionId===sectionId && span.start<span.end && span.end<=section.passage.length && section.passage.slice(span.start,span.end)===span.quote;
  };
  const invalidSpans=[], missingEvidence=[];
  for(const q of a.questions) {
    if(!q.evidence?.length || !q.acceptedAnswers?.length) missingEvidence.push(q.id);
    const spans=[...(q.evidence??[]),...input.solverAnswers.find(s=>s.questionId===q.id).spans,...input.reviews.filter(r=>r.questionId===q.id).flatMap(r=>r.judgments.flatMap(j=>j.spans??[])),...adj.filter(x=>x.questionId===q.id).flatMap(x=>x.spans??[]),...solverAdj.filter(x=>x.questionId===q.id).flatMap(x=>x.spans)];
    if(spans.some(s=>!spanValid(s,q.sectionId))) invalidSpans.push(q.id);
  }
  const questions=ids.map(id=>{
    const q=a.questions.find(q=>q.id===id), rr=input.reviews.filter(r=>r.questionId===id), disagreements=[], unresolved=[], results=[];
    for(const c of criteria) {
      const pair=rr.map(r=>r.judgments.find(j=>j.criterion===c));
      const conflict=pair[0].verdict!==pair[1].verdict || pair[0].severity!==pair[1].severity || pair[0].category!==pair[1].category;
      if(conflict) disagreements.push(c);
      const needs=conflict || pair.some(j=>j.verdict==='UNCERTAIN' || (j.verdict==='FAIL' && j.severity==='critical'));
      const human=adj.find(x=>x.questionId===id && x.criterion===c);
      if((needs && !human) || human?.verdict==='UNCERTAIN') unresolved.push(c);
      const final=human && human.verdict!=='UNCERTAIN' ? human : pair.find(j=>j.verdict==='FAIL') ?? (needs || human?.verdict==='UNCERTAIN' ? {criterion:c,verdict:'UNCERTAIN',severity:'none',category:'unresolved',reason:'Human adjudication required'} : pair[0]);
      results.push(final);
    }
    const solver=input.solverAnswers.find(s=>s.questionId===id);
    const comparison=!q.acceptedAnswers ? 'UNCERTAIN' : q.acceptedAnswers.includes(solver.answer) ? 'PASS':'FAIL';
    const human=solverAdj.find(x=>x.questionId===id);
    if((comparison!=='PASS' && !human) || human?.verdict==='UNCERTAIN') unresolved.push('solver_key');
    if(missingEvidence.includes(id)) unresolved.push('evidence_record');
    const critical=results.some(j=>j.verdict==='FAIL' && j.severity==='critical') || human?.verdict==='FAIL' || invalidSpans.includes(id);
    const answerable=criticalCriteria.size===results.filter(j=>criticalCriteria.has(j.criterion) && j.verdict==='PASS').length && !critical && !unresolved.some(c=>criticalCriteria.has(c) || c==='solver_key' || c==='evidence_record');
    const noncriticalPass=results.filter(j=>!criticalCriteria.has(j.criterion)).every(j=>j.verdict==='PASS');
    const verdict=critical || results.some(j=>j.verdict==='FAIL') ? 'FAIL':unresolved.length?'UNCERTAIN':'PASS';
    return {id,groupId:q.groupId,sectionId:q.sectionId,verdict,critical,answerable,noncriticalPass,solverKeyComparison:comparison,solverResolution:human??null,disagreements,unresolved,judgments:results,originalReviews:rr};
  });
  const validMeta=m=>m && m.usage!==null && m.latencyMs!==null && m.cost!==null;
  const provenance=!!generatorId && validMeta(input.generator.metadata) && input.solverAnswers.every(s=>s.sessionId && validMeta(s.metadata)) && input.reviews.every(r=>r.raw && (r.source==='human' || validMeta(r.metadata)));
  const real=input.evidenceClass==='REAL_MODEL' && input.reviews.every(r=>r.source!=='synthetic');
  const audit=input.protocolAudit, ds=Object.values(input.deterministic), issues=manifestProblems(input);
  const protocolPass=audit?.verdict==='PASS' && Object.values(audit.checks).every(x=>x==='PASS');
  const reasons=[];
  if(ds.includes('FAIL')) reasons.push('Deterministic validation failed');
  if(questions.some(q=>q.critical)) reasons.push('Critical semantic defect');
  if(invalidSpans.length) reasons.push('Invalid evidence spans');
  if(evidenceAudit.verdict==='FAIL') reasons.push('Evidence integrity failed');
  if(audit && (audit.verdict==='FAIL' || Object.values(audit.checks).includes('FAIL'))) reasons.push('Human protocol audit failed');
  const failure=reasons.length>0;
  if(!real) reasons.push('Synthetic records are not quality evidence');
  if(!provenance) reasons.push('Missing raw responses, sessions or known per-call usage/latency/cost');
  if(missingEvidence.length) reasons.push('Missing key/evidence coverage');
  if(!protocolPass) reasons.push('Independent human protocol audit incomplete');
  if(issues.length || evidenceAudit.verdict!=='PASS') reasons.push('Manifest incomplete or files not verified');
  if(ds.some(x=>x==='UNCERTAIN')) reasons.push('Deterministic uncertainty');
  if(questions.some(q=>q.unresolved.length)) reasons.push('Unresolved semantic or solver/key adjudication');
  if(questions.length!==rubric.pilot.questions || a.sections.length!==rubric.pilot.sections) reasons.push('Not a single 13-question Section');
  const incomplete=reasons.length>0;
  const answerable=questions.filter(q=>q.answerable).length, qualityPass=questions.filter(q=>q.noncriticalPass).length;
  if(qualityPass<rubric.pilot.minimumQualityPass) reasons.push('Fewer than 12/13 noncritical quality passes');
  const pilotDecision=failure?'NO-GO':incomplete?'INSUFFICIENT_EVIDENCE':answerable===13 && qualityPass>=12?'GO':'NO-GO';
  const totalJudgments=input.reviews.length*criteria.length;
  return {version:rubric.version,evidenceClass:real?'MODEL_JUDGMENTS_NOT_GROUND_TRUTH':'SYNTHETIC_NOT_QUALITY_EVIDENCE',pilotDecision,reasons,
    authorizesLivePilot:false,advancementDecision:'INSUFFICIENT_EVIDENCE',
    limitations:['Supplied judgments and human identities are not authenticated semantic truth.','Hash integrity does not prove isolation or entailment; independent human audit is mandatory.','No single pilot approves expansion, publication or student delivery.'],
    targets:{answerable,requiredAnswerable:13,qualityPass,requiredQualityPass:12},
    metrics:{originalUncertainJudgments:input.reviews.flatMap(r=>r.judgments).filter(j=>j.verdict==='UNCERTAIN').length,totalOriginalJudgments:totalJudgments,agreementPairs:ids.length*criteria.length-questions.reduce((n,q)=>n+q.disagreements.length,0),totalPairs:ids.length*criteria.length,solverKeyDisagreements:questions.filter(q=>q.solverKeyComparison==='FAIL').length,...confidenceMetrics(questions)},
    evidenceAudit,manifestProblems:issues,invalidSpans,missingEvidence,questions,adjudications:adj,solverAdjudications:solverAdj,
    groups:groups.map(g=>summarize(questions.filter(q=>q.groupId===g.id),g.id)),sections:sectionIds.map(id=>summarize(questions.filter(q=>q.sectionId===id),id)),paper:summarize(questions,a.id)};
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href) {
  try {
    const [file,flag,root]=process.argv.slice(2);
    demand(file && (!flag || flag==='--evidence-root' && root),'Usage: node report.mjs records.json [--evidence-root restricted-run-directory]');
    const data=JSON.parse(await readFile(file,'utf8')); validate(record,data);
    const result=evaluate(data,await auditManifest(data,root)); console.log(JSON.stringify(result,null,2));
    process.exitCode=result.pilotDecision==='NO-GO'?2:result.pilotDecision==='INSUFFICIENT_EVIDENCE'?3:0;
  } catch(e) {console.error(e.message);process.exitCode=1;}
}
