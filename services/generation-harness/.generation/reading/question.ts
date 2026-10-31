import type { CanonicalContext, CanonicalRecord, Report, QuestionSummary, Status } from './types.ts';
import { object,own,structural,identities,at,keysEqual } from './support.ts';
import { runChoiceRule } from './rules/choice.ts';
import { runCompletionRule } from './rules/completion.ts';
import { runMatchingRule } from './rules/matching.ts';

export function validateQuestion(c: CanonicalContext,r: Report,q: unknown,path='/question',instructionContext?: {texts: string[]; complete: boolean}): QuestionSummary {
 const empty={structuralValid:false,answerSlots:null,scoringUnits:null};
 if(!object(q)){r.diagnostic('OBJECT_REQUIRED',path,'Question must be an object.');return empty;}
 if(typeof q.type!=='string'||!own(c.meta.registry,q.type)){
  r.diagnostic(own(q,'type')?'TYPE_UNSUPPORTED':'FIELD_REQUIRED',at(path,'type'),'An exact canonical question type is required.','Use get_question_spec with a canonical literal.',c.schema.$defs.QuestionType.enum);return empty;
 }
 const entry=c.meta.registry[q.type],valid=structural(c,r,q,entry.schema,path);
 const summary: QuestionSummary={structuralValid:valid,type:q.type,family:entry.family,answerSlots:null,scoringUnits:valid?1:null};
 if(valid){
  summary.answerSlots=entry.family==='multiple'?q.options.filter((o: CanonicalRecord)=>o.isCorrect).length:entry.family==='completion'?new Set([...Object.keys(q.blankAcceptTexts),...Object.keys(q.blankAcceptRegex??{})]).size:entry.family==='matching'?Object.keys(q.matchPairs).length:entry.family==='flow'?q.orderCorrects.length:1;
 }
 if(summary.answerSlots!==null && summary.answerSlots>1)r.pending('IELTS_SCORING_CONFLICT',path,'This Question has multiple answer slots but only one all-or-nothing backend scoring unit; separate IELTS marks are not supported.','COMPATIBILITY','Reconcile the requested IELTS marks with supported Question scoring before claiming readiness.');
 const shapes: Status[]=[];
 for(const id of entry.rules){
  let ruleShape: Status | undefined;
  const provenance=`${c.schema.$id}#/x-langfens/semanticRules/${id}`;
  if(id==='COMMON'){
   const before=r.mark();
   if(Array.isArray(q.options)){
    identities(r,q.options,at(path,'options'),'id',true);
    const indices=q.options.map((o: unknown)=>object(o)?o.idx:null);
    if(!keysEqual(indices,q.options.map((_: unknown,i: number)=>i+1)))r.diagnostic('OPTION_INDEX_COVERAGE',at(path,'options'),'Option indices must uniquely cover 1..N.','Correct option indices without changing identities.',undefined,'FAIL',id);
   }
   ruleShape=r.statusSince(before);
   r.check('COMMON.shape',ruleShape,provenance,path);
   r.pending('PARENT_CONTEXT_UNVERIFIED',path,'Parent membership and paper-wide identity scope require a containing artifact.',id);
   r.check('COMMON','UNVERIFIED',provenance,path);
  }else if(['CHOICE','MULTIPLE_SELECTION_COUNT','TRUTH_EVIDENCE'].includes(id)){
   if(valid)ruleShape=runChoiceRule(id,c,r,q,path);
   else {r.check(id,'UNVERIFIED',provenance,path);r.pending('CHECK_BLOCKED_BY_INVALID_INPUT',path,'Rule prerequisites are structurally invalid.',id);}
  }else if(['BLANKS','COMPLETION_LAYOUT','REGEX','SHORT_INPUT','MEDIA','LABEL_ALIGNMENT'].includes(id)){
   if(valid)ruleShape=runCompletionRule(id,c,r,q,path,instructionContext);
   else {r.check(id,'UNVERIFIED',provenance,path);r.pending('CHECK_BLOCKED_BY_INVALID_INPUT',path,'Rule prerequisites are structurally invalid.',id);}
  }else if(['MATCHING_TARGETS','MATCHING_BANK','HEADING','INFORMATION','FEATURES','ENDINGS','CLASSIFICATION_KEYS','FLOW_ORDERING'].includes(id)){
   if(valid)ruleShape=runMatchingRule(id,c,r,q,path);
   else {r.check(id,'UNVERIFIED',provenance,path);r.pending('CHECK_BLOCKED_BY_INVALID_INPUT',path,'Rule prerequisites are structurally invalid.',id);}
  }else if(['PROJECTION','SUBMISSION','COMPATIBILITY'].includes(id)){
   r.check(id,'UNVERIFIED',provenance,path);
   r.pending(id==='COMPATIBILITY'?'SCHEMA_VALIDITY_ONLY':`${id}_CONTEXT_UNVERIFIED`,path,`${id} requires its separate capability check and independent consumer evidence.`,id);
  }else{
   r.check(id,'UNVERIFIED',provenance,path);
   r.pending('RULE_UNIMPLEMENTED',path,'This applicable rule has not been mechanically established.',id);
  }
  if(ruleShape){
   shapes.push(ruleShape);
   if((ruleShape==='FAIL'||ruleShape==='ERROR')&&['COMMON','BLANKS','MATCHING_TARGETS','MATCHING_BANK','FLOW_ORDERING'].includes(id))summary.answerSlots=null;
  }
 }
 const semanticShape=shapes.includes('ERROR')?'ERROR':shapes.includes('FAIL')?'FAIL':!valid||shapes.includes('UNVERIFIED')?'UNVERIFIED':'PASS';
 return {...summary,type:q.type,answerFamily:entry.family,questionCount:1,claims:{structure:valid?'PASS':'FAIL',semanticShape,ieltsSemantics:'UNVERIFIED',consumerCompatibility:'UNVERIFIED'}};
}
