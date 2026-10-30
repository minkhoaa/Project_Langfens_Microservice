import type { CanonicalContext, CanonicalRecord, Domain, Report } from './types.ts';
import { checkArguments,createReport } from './support.ts';
import { loadCanonical,getQuestionSpec,canonicalUrl } from './contract.ts';
import { validateQuestion } from './question.ts';
import { validateGroup,validateExam } from './hierarchy.ts';
import { verifyEvidence } from './evidence.ts';
import { checkGradingParity } from './grading.ts';
import { inspectProjection } from './projection.ts';
const handlers: Record<string,{names: string[]; run(c: CanonicalContext,r: Report,a: CanonicalRecord): CanonicalRecord | undefined}>={
 get_question_spec:{names:['type'],run:(c,r,a)=>getQuestionSpec(c,r,a.type)},
 validate_question:{names:['question'],run:(c,r,a)=>validateQuestion(c,r,a.question)},
 validate_group:{names:['group'],run:(c,r,a)=>validateGroup(c,r,a.group)},
 validate_exam:{names:['exam'],run:(c,r,a)=>validateExam(c,r,a.exam)},
 verify_evidence:{names:['question','passage','evidence'],run:(c,r,a)=>verifyEvidence(c,r,a.question,a.passage,a.evidence)},
 check_grading_parity:{names:['question','submission'],run:(c,r,a)=>checkGradingParity(c,r,a.question,a.submission)},
 inspect_delivery_projection:{names:['question'],run:(c,r,a)=>inspectProjection(c,r,a.question)},
};
const infraCodes=new Set(['CONTRACT_UNAVAILABLE','CONTRACT_INVALID','CONTRACT_VERSION_UNSUPPORTED','CONTRACT_RESOURCE_LIMIT','VALIDATOR_CAPABILITY_UNAVAILABLE','EXAMPLE_UNAVAILABLE']);
export function createDomain({contractUrl=canonicalUrl}: {contractUrl?: URL | string}={}): Domain {
 let context: CanonicalContext | undefined;
 return {call(name,args){
  let r=createReport();
  try{
   const h=Object.hasOwn(handlers,name)?handlers[name]:null;
   if(!h){r.diagnostic('TOOL_UNSUPPORTED','/','Unsupported domain capability.','Call one of the seven registered Reading tools.');return r.finish();}
   const invalid=checkArguments(args,h.names);if(invalid)return invalid;
   if(!context)context=loadCanonical(contractUrl);
   r=createReport(context);return r.finish(h.run(context,r,args as CanonicalRecord));
  }catch(error){const e=error as {code?: string};const code=infraCodes.has(e?.code??'')?e.code!:'INTERNAL_ERROR';r.diagnostic(code,'/','Reading capability could not execute safely.','Check the pinned contract and local installation; no input was modified.',undefined,'ERROR');return r.finish();}
 }};
}
let domain: Domain | undefined;
export function callTool(name: string,args: unknown){domain??=createDomain();return domain.call(name,args);}
