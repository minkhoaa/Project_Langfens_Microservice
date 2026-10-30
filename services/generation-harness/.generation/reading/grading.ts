import type { CanonicalContext, CanonicalRecord, Report } from './types.ts';
import { object,own,fields,uuid,identity,structural,at } from './support.ts';
import { validateQuestion } from './question.ts';
import { parseAnswerJson } from './json-answer.ts';
import { readMatchingPresentation } from './rules/matching.ts';

export function checkGradingParity(c: CanonicalContext,r: Report,question: CanonicalRecord,submission: unknown): CanonicalRecord {
 const summary=validateQuestion(c,r,question),family=summary.family;
 r.check('ACTUAL_DOTNET','UNVERIFIED',['sources.v1.json#grader','sources.v1.json#normalization'],'/submission','grading');
 r.pending('ACTUAL_DOTNET_UNVERIFIED','/submission','No actual .NET execution, normalization or regex evidence is available.','COMPATIBILITY');
 r.pending('ROUNDTRIP_UNVERIFIED','/submission','Actual consumer autosave, final submit, clear and restore round trips are unverified.','COMPATIBILITY');
 const base: CanonicalRecord={answerFamily:family??null,lifecycle:'unspecified',operation:'empty',serializationStatus:'UNVERIFIED',completenessStatus:'UNVERIFIED',sourceModel:{verification:'source-only',provenance:['sources.v1.json#grader','sources.v1.json#autosave']},actualDotnet:{status:'UNVERIFIED'},consumerRoundTrip:{status:'UNVERIFIED'}};
 const start=r.mark();let answer=submission,path='/submission',state='unspecified';
 if(object(submission)&&(own(submission,'state')||own(submission,'answer'))){
  fields(r,submission,['state','answer'],['state','answer'],path);
  if(typeof submission.state==='string'&&['autosave','final','restored'].includes(submission.state))state=submission.state;
  else r.diagnostic('SUBMISSION_LIFECYCLE_INVALID','/submission/state','Unsupported explicit submission lifecycle.','Use autosave, final or restored.');
  answer=submission.answer;path+='/answer';
 }
 base.lifecycle=state;
 if(!fields(r,answer,['questionId','sectionId','selectedOptionIds','textAnswer'],['questionId','sectionId','selectedOptionIds'],path))return {...base,serializationStatus:'FAIL'};
 // Canonical primitive schemas are reused; completed cardinality is checked separately.
 structural(c,r,answer,'#/$defs/SubmissionBase',path,'SUBMISSION_PRIMITIVES');
 if(own(answer,'textAnswer')&&typeof answer.textAnswer!=='string')r.diagnostic('SCHEMA_TYPE',at(path,'textAnswer'),'Text answer must be a string; null is not a clear.');
 for(const k of ['questionId','sectionId']){
  if(!uuid(answer[k]))continue;
  if(!uuid(question?.[k==='questionId'?'id':k]))r.pending('SUBMISSION_ID_UNMAPPED',at(path,k),'Authoring identity has no verified persisted UUID mapping.','SUBMISSION');
  else if(identity(answer[k])!==identity(question[k==='questionId'?'id':k]))r.diagnostic('SUBMISSION_KEY_MISMATCH',at(path,k),'Submission references a different Question or Section.');
 }
 const selected=Array.isArray(answer.selectedOptionIds)?answer.selectedOptionIds:[],text=answer.textAnswer;
 const clear=selected.length===0&&own(answer,'textAnswer')&&text==='';
 let filled=0,required=summary.answerSlots??null,decoded: unknown;
 const bankLabels=family==='matching'&&summary.structuralValid?new Set(readMatchingPresentation(c,question).bank.map(b=>b.label)):new Set<string>();
 if(clear){base.operation='clear';structural(c,r,answer,c.meta.submissionPolicy.clearSubmissionSchema,path,'CLEAR_SERIALIZATION');}
 else if(family==='single'||family==='multiple'){
  if(own(answer,'textAnswer'))r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'textAnswer'),'Canonical choice answers use selected option UUIDs, not text fallback.');
  const ids=selected.filter(uuid).map(identity);
  if(new Set(ids).size!==ids.length)r.diagnostic('IDENTITY_DUPLICATE',at(path,'selectedOptionIds'),'Selected UUID identities are duplicated.');
  if(summary.structuralValid){
   const options=question.options,known=new Set(options.filter((o: CanonicalRecord)=>uuid(o.id)).map((o: CanonicalRecord)=>identity(o.id)));
   for(const [i,id] of selected.entries())if(uuid(id)&&!known.has(identity(id))){
    if(options.some((o: CanonicalRecord)=>!uuid(o.id)))r.pending('SUBMISSION_ID_UNMAPPED',at(at(path,'selectedOptionIds'),i),'A local option identity prevents verified persisted membership.','SUBMISSION');
    else r.diagnostic('SUBMISSION_KEY_MISMATCH',at(at(path,'selectedOptionIds'),i),'Selected option does not belong to this Question.');
   }
   const maximum=family==='single'?1:required;
   if(selected.length>maximum!)r.diagnostic('ANSWER_COUNT_INVALID',at(path,'selectedOptionIds'),'Too many selections for this Question.');
  }
  filled=selected.length;base.operation=filled?'answer':'empty';
 }else if(family){
  if(selected.length)r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'selectedOptionIds'),'Text-family submissions require empty selections.');
  if(typeof text==='string'&&text!==''){
   base.operation='answer';
   if(family==='short'){filled=text.trim()?1:0;structural(c,r,text,c.meta.answerFamilies[family].decodedAnswerSchema,at(path,'textAnswer'),'DECODED_STRUCTURE');}
   else{
    const parsed=parseAnswerJson(r,text,at(path,'textAnswer'));
    if(parsed.valid){decoded=parsed.value;
     if(family==='flow'){
      if(!Array.isArray(decoded))r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'textAnswer'),'Flow answers must decode to a node-key array.');
      else{const itemSchema=c.schema.$defs.FlowAnswerValue.items;
       decoded.forEach((v,i)=>{if(!c.validator(itemSchema.$ref).Check(v))r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'textAnswer'),'Flow answer contains an invalid node identity.',undefined,undefined,'FAIL','SUBMISSION',{decodedPath:`/${i}`});
        else if(summary.structuralValid&&!question.orderCorrects.includes(v))r.diagnostic('SUBMISSION_KEY_MISMATCH',at(path,'textAnswer'),'Flow answer contains a foreign node key.',undefined,undefined,'FAIL','SUBMISSION',{decodedPath:`/${i}`});});
       if(new Set(decoded).size!==decoded.length)r.diagnostic('FLOW_PERMUTATION_INVALID',at(path,'textAnswer'),'Flow sequence contains duplicate nodes.');filled=decoded.length;
      }
     }else if(!object(decoded))r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'textAnswer'),'Answer must decode to an exact keyed object.');
     else{
      const schema=c.schema.$defs[c.meta.answerFamilies[family].decodedAnswerSchema.slice(8)];
      Object.entries(decoded).forEach(([k,v],i)=>{
       if(!new RegExp(schema.propertyNames.pattern).test(k)||typeof v!==schema.additionalProperties.type)r.diagnostic('SUBMISSION_FAMILY_INVALID',at(path,'textAnswer'),'Decoded answer has an invalid key or primitive value.',undefined,undefined,'FAIL','SUBMISSION',{propertyIndex:i});
       else if(summary.structuralValid){
        const keys=family==='matching'?question.matchPairs:question.blankAcceptTexts;
        if(!own(keys,k))r.diagnostic('SUBMISSION_KEY_MISMATCH',at(path,'textAnswer'),'Decoded answer contains a foreign slot identity.',undefined,undefined,'FAIL','SUBMISSION',{decodedPath:`/${k}`});
        else if(family==='matching'&&v!==''&&!bankLabels.has(v))r.diagnostic('SUBMISSION_KEY_MISMATCH',at(path,'textAnswer'),'Matching value is not a canonical bank grading key.',undefined,undefined,'FAIL','SUBMISSION',{decodedPath:`/${k}`});
       }
      });filled=Object.values(decoded).filter(v=>typeof v==='string'&&v.trim()).length;
     }
    }
   }
  }
 }
 const outcome=r.statusSince(start),invalid=outcome==='FAIL'||outcome==='ERROR';
 base.serializationStatus=invalid?'FAIL':summary.structuralValid?'PASS':'UNVERIFIED';
 r.check('SUBMISSION_SERIALIZATION',base.serializationStatus,`${c.schema.$id}#/x-langfens/semanticRules/SUBMISSION`,path,'serialization');
 const complete=summary.structuralValid&&required!==null&&filled===required&&!clear&&!invalid;
 if(state==='final'){
  base.completenessStatus=complete?'PASS':'FAIL';
  if(!complete)r.diagnostic('ANSWER_INCOMPLETE',path,'The explicitly requested final answer is incomplete or invalid.','Fill every required slot/selection, preserving identities.');
  else if(family==='single'||family==='multiple')structural(c,r,answer,c.meta.answerFamilies[family].submissionSchema,path,'FINAL_WIRE_STRUCTURE');
  else if(family){structural(c,r,answer,c.meta.answerFamilies[family].submissionSchema,path,'FINAL_WIRE_STRUCTURE');if(decoded!==undefined)structural(c,r,decoded,c.meta.answerFamilies[family].decodedAnswerSchema,at(path,'textAnswer'),'FINAL_DECODED_STRUCTURE');}
 }else if(state==='unspecified')r.pending('SUBMISSION_LIFECYCLE_UNSPECIFIED',path,'No final-answer completeness request was supplied.','SUBMISSION');
 else base.completenessStatus=invalid?'FAIL':'PASS';
 r.check('SUBMISSION_COMPLETENESS',base.completenessStatus,[],path,'serialization');return base;
}
