import type { ToolDefinition } from 'generation-harness-core';
import type { JsonValue } from 'generation-harness-core/ai';
import type { TSchema } from 'typebox';
import { Compile } from 'typebox/compile';
import canonical from '../contracts/question-types.v1.schema.json' with { type: 'json' };
import type { CanonicalContext, CanonicalRecord, ReadingResult } from './types.ts';
import { loadCanonical } from './contract.ts';
import { at,createReport,fields,inputProblem,object,own } from './support.ts';
import { validateQuestion } from './question.ts';
import { createReadingTools } from './tools.ts';

const contract: CanonicalRecord=canonical,defs=contract.$defs;
// Builder inputs are projections of the sole canonical contract, not another Question schema.
function inline(node: CanonicalRecord): CanonicalRecord {
 if(node.$ref)return inline(defs[node.$ref.slice(8)]);
 return Object.fromEntries(Object.entries(node).filter(([k])=>k!=='description').map(([k,v])=>[k,
  Array.isArray(v)?v.map(x=>object(x)?inline(x):x):object(v)?inline(v):v]));
}
const builders=[
 ['create_single_choice','single',[], 'Create one single-choice, truth or image Question from supplied content and explicit correctness flags.'],
 ['create_multiple_choice','multiple',[], 'Create a multiple-choice Question; supply at least two correct choices, a distractor and an explicit selection count in promptMd.'],
 ['create_completion','completion',['blankAcceptTexts','blankAcceptRegex'], 'Create completion or diagram/map labels; supply each [N] marker, accepted texts, word-limit instructions and required media.'],
 ['create_matching','matching',['matchPairs','wordList'], 'Create matching/classification; supply numbered targets, labeled option bank and exact [gradingKey, displayLabel] pairs. Heading prompts also need List of Headings.'],
 ['create_short_answer','short',['shortAnswerAcceptTexts','shortAnswerAcceptRegex'], 'Create one short-answer Question from a supplied prompt and accepted alternatives.'],
 ['create_flow_chart','flow',['orderCorrects'], 'Create process ordering, not blank completion. Supply public - key: label lines independent of private orderCorrects; never expose solution order.'],
] as const;
const outputSchema=createReadingTools()[0]!.outputSchema;
const adapt=(result: ReadingResult)=>({content:[{type:'text' as const,text:JSON.stringify(result)}],details:result,structuredContent:result as unknown as JsonValue,isError:result.status==='FAIL'||result.status==='ERROR'});

function parameters(family: string,types: string[],answerFields: readonly string[]): CanonicalRecord {
 const properties: CanonicalRecord={};
 for(const key of ['id','sectionId','groupId','idx','difficulty','promptMd','explanationMd','imageUrl'])properties[key]=inline(defs.QuestionBase.properties[key]);
 if(types.length>1)properties.type={type:'string',enum:types};
 const required=defs.QuestionBase.required.filter((k: string)=>own(properties,k));
 if(['single','multiple','matching'].includes(family)){
  const option=inline(defs.PrivateOption);delete option.properties.idx;
  option.required=option.required.filter((k: string)=>k!=='id'&&k!=='idx'&&(family!=='matching'||k!=='isCorrect'));
  if(family==='matching')delete option.properties.isCorrect;
  const base=defs[family==='single'?'SingleChoiceQuestion':family==='multiple'?'MultipleChoiceQuestion':'MatchingQuestion'];
  properties.options={type:'array',minItems:base.properties.options.minItems,items:option,
   description:'Supplied content in display order. idx is assigned 1..N; omitted IDs become <questionId>:option:<idx> (local only, not persisted UUIDs).'};
  required.push('options');
 }
 for(const key of answerFields){
  const source=types.map(type=>defs[type].properties[key]).find(Boolean)??defs.CompletionQuestion.properties[key]??defs.MatchingQuestion.properties[key];
  properties[key]=inline(source);
  if(types.some(type=>defs[type].required?.includes(key))||key==='blankAcceptTexts'||key==='matchPairs')required.push(key);
 }
 return {type:'object',properties,required,additionalProperties:false};
}

// Locate errors through declared schema fields only: never echo unknown keys or input values.
function location(schema: CanonicalRecord,instancePath: string): {path: string; node: CanonicalRecord} {
 let node=schema,path='';
 for(const encoded of instancePath.split('/').slice(1)){
  const key=encoded.replaceAll('~1','/').replaceAll('~0','~');
  if(node.type==='array'&&/^(?:0|[1-9][0-9]*)$/.test(key))node=node.prefixItems?.[Number(key)]??node.items??{};
  else if(node.properties&&own(node.properties,key))node=node.properties[key];
  else if(object(node.additionalProperties)&&/^[1-9][0-9]*$/.test(key))node=node.additionalProperties;
  else break;
  path=at(path,key);
 }
 return {path:path||'/',node};
}

export function createCreationTools(): ToolDefinition<TSchema,ReadingResult>[] {
 let context: CanonicalContext | undefined;
 return builders.map(([name,family,answerFields,description])=>{
  const types=Object.entries(contract['x-langfens'].registry).filter(([,entry])=>(entry as CanonicalRecord).family===family).map(([type])=>type);
  const schema=parameters(family,types,answerFields);
  let validator: ReturnType<typeof Compile> | undefined;
  const invalid=(args: unknown): ReadingResult | undefined=>{
   const r=createReport(),problem=inputProblem(args);
   if(problem){r.diagnostic(problem.code,'/','Input is non-JSON or exceeds Reading resource limits.','Supply plain bounded JSON values.');return r.finish();}
   fields(r,args,Object.keys(schema.properties),schema.required,'/');
   if(r.result.status==='FAIL')return r.finish();
   validator??=Compile(schema);
   if(validator.Check(args))return undefined;
   for(const error of validator.Errors(args)){
    const {path,node}=location(schema,error.instancePath??''),keyword=error.keyword??'invalid';
    const missing=error.keyword==='required'?error.params.requiredProperties:[];
    if(missing.length){for(const key of missing)if(own(node.properties??{},key))r.diagnostic('FIELD_REQUIRED',at(path,key),'Required field is absent.','Supply this field.');}
    else r.diagnostic('BUILDER_ARGUMENT_INVALID',path,`Builder ${keyword} constraint violated.`,`Use the declared ${node.type??'JSON'} shape and canonical constraints at this field.`,node[keyword]);
   }
   return r.finish();
  };
  return {name,label:name,description:`${description} Requires id, sectionId, idx, difficulty and promptMd. skill=READING; empty banks are derived. Returns data.question only without FAIL/ERROR; UNVERIFIED is not semantic correctness or readiness.`,parameters:schema,outputSchema,
   prepareArguments(args: unknown){const report=invalid(args);if(report)throw new Error(JSON.stringify(report));return args;},
   formatPreparationError(_error: unknown,args: unknown){const report=invalid(args);return report?adapt(report):undefined;},
   async execute(_id: string,args: unknown,signal?: AbortSignal){
    let r=createReport();
    try{
     if(signal?.aborted){r.diagnostic('EXECUTION_ABORTED','/','Reading creation was cancelled.','Continue only when requested by the operator.',undefined,'ERROR');return adapt(r.finish());}
     const report=invalid(args);if(report)return adapt(report);
     context??=loadCanonical();r=createReport(context);
     const input=structuredClone(args) as CanonicalRecord;
     const question={...input,type:input.type??types[0],skill:'READING',options:(input.options??[]).map((option: CanonicalRecord,i: number)=>({...option,id:option.id??`${input.id}:option:${i+1}`,idx:i+1,...(family==='matching'?{isCorrect:false}:{})}))};
     const validation=validateQuestion(context,r,question);
     return adapt(r.finish(r.result.status==='FAIL'||r.result.status==='ERROR'?{validation}:{question,validation}));
    }catch(error){
     const code=(error as {code?: string})?.code;
     r.diagnostic(code?.startsWith('CONTRACT_')||code==='VALIDATOR_CAPABILITY_UNAVAILABLE'?code:'INTERNAL_ERROR','/','Reading creation could not execute safely.','Check the pinned canonical contract and local installation. No Question was returned.',undefined,'ERROR');
     return adapt(r.finish());
    }
   },
  };
 });
}
