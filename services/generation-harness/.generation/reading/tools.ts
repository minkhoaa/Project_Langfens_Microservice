import type { ToolDefinition } from 'generation-harness-core';
import type { JsonValue } from 'generation-harness-core/ai';
import type { TSchema } from 'typebox';
import type { Domain, ReadingResult } from './types.ts';
import { checkArguments,createReport } from './support.ts';
const declarations: [string,string[],string][]=[
 ['get_question_spec',['type'],'Get canonical fields, rules, answer family and a valid example for one exact question type.'],
 ['validate_question',['question'],'Check a private Question against canonical structure and applicable semantic rules.'],
 ['validate_group',['group'],'Check a QuestionGroup’s membership, identities, ordering and bounds.'],
 ['validate_exam',['exam'],'Check Exam hierarchy, scoring units and explicitly requested completeness.'],
 ['verify_evidence',['question','passage','evidence'],'Check exact passage/source spans; does not establish entailment or NOT GIVEN correctness.'],
 ['check_grading_parity',['question','submission'],'Check answer serialization and source-derived compatibility; actual .NET parity remains unverified.'],
 ['inspect_delivery_projection',['question'],'Build an allowlisted public Question, preserving inputs/media and diagnosing privacy risks.'],
];
const outputSchema: TSchema={type:'object',required:['status','contractVersion','checks','diagnostics'],properties:{status:{enum:['PASS','FAIL','UNVERIFIED','ERROR']},contractVersion:{type:'string'},checks:{type:'array'},diagnostics:{type:'array'}},additionalProperties:true};
const adapt=(result: ReadingResult)=>({content:[{type:'text' as const,text:JSON.stringify(result)}],details:result,structuredContent:result as unknown as JsonValue,isError:result.status==='FAIL'||result.status==='ERROR'});
export function createReadingTools(): ToolDefinition<TSchema,ReadingResult>[] {
 let pending: Promise<Domain> | undefined;
 const getDomain=()=>{
  if(!pending){
   const request=import('./domain.ts').then(m=>m.createDomain());pending=request;
   request.catch(()=>{if(pending===request)pending=undefined;});
  }
  return pending;
 };
 return declarations.map(([name,names,description])=>({
  name,label:name,description,
  parameters:{type:'object',properties:Object.fromEntries(names.map(k=>[k,{}])),required:[...names],additionalProperties:false},
  outputSchema,
  prepareArguments(args: unknown){const invalid=checkArguments(args,names);if(invalid)throw new Error(JSON.stringify(invalid));return args;},
  async execute(_id: string,args: unknown,signal?: AbortSignal){
   const aborted=()=>{const r=createReport();r.diagnostic('EXECUTION_ABORTED','/','Reading execution was cancelled.','Retry only when the operator intends to continue.',undefined,'ERROR');return adapt(r.finish());};
   try{
    if(signal?.aborted)return aborted();
    const invalid=checkArguments(args,names);if(invalid)return adapt(invalid);
    const domain=await getDomain();if(signal?.aborted)return aborted();return adapt(domain.call(name,args));
   }catch{const r=createReport();r.diagnostic('INTERNAL_ERROR','/','Reading tool dependency or execution failed.','Check the local extension installation.',undefined,'ERROR');return adapt(r.finish());}
  },
 }));
}
