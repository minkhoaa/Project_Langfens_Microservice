import type { ToolDefinition } from 'generation-harness-core';
import type { JsonValue } from 'generation-harness-core/ai';
import type { TSchema } from 'typebox';
import { Value } from 'typebox/value';
import type { CanonicalRecord, Domain, ReadingResult } from './types.ts';
import { at,checkArguments,createReport,object,own } from './support.ts';
import { artifactInput,fileReference } from './artifact-input.ts';
import canonical from '../contracts/question-types.v1.schema.json' with { type: 'json' };
// Structural wire hints are derived from the canonical fields; domain rules remain authoritative.
const defs: CanonicalRecord=canonical.$defs;
function wire(node: CanonicalRecord): CanonicalRecord {
 if(node.$ref)return wire(defs[node.$ref.slice(8)]);
 const out: CanonicalRecord={};
 for(const k of ['type','enum','const'])if(node[k]!==undefined)out[k]=node[k];
 if(node.properties)out.properties=Object.fromEntries(Object.entries(node.properties).map(([k,v])=>[k,wire(v as CanonicalRecord)]));
 if(node.items&&typeof node.items==='object')out.items=wire(node.items);
 if(node.prefixItems){out.prefixItems=node.prefixItems.map(wire);out.items=false;}
 if(node.additionalProperties&&typeof node.additionalProperties==='object')out.additionalProperties=wire(node.additionalProperties);
 return out;
}
const questionProperties=Object.assign({},...['QuestionBase','CompletionQuestion','MatchingQuestion','MatchingExerciseQuestion','SHORT_ANSWER','FLOW_CHART'].map(k=>wire(defs[k]).properties),wire(defs.QuestionBase).properties);
const questionWire={type:'object',properties:questionProperties,additionalProperties:true};
const string={type:'string'},integer={type:'integer'},strings={type:'array',items:string};
const groupWire={type:'object',properties:{id:string,idx:integer,sectionId:string,startIdx:integer,endIdx:integer,instructionMd:string,questions:{type:'array',items:questionWire}},additionalProperties:true};
const nullableString={anyOf:[string,{type:'null'}]};
const sectionWire={type:'object',properties:{id:string,idx:integer,examId:string,title:string,instructionsMd:nullableString,passageMd:nullableString,audioUrl:nullableString,transcriptMd:nullableString,questionGroups:{type:'array',items:groupWire},questions:{type:'array',items:questionWire}},additionalProperties:true};
const examWire={type:'object',properties:{id:string,complete:{type:'boolean'},expectedQuestionCount:integer,sections:{type:'array',items:sectionWire},slug:string,title:string,descriptionMd:nullableString,category:string,level:string,durationMin:integer,imageUrl:nullableString},additionalProperties:true};
const spanWire={type:'object',properties:{start:integer,end:integer,quote:string,sourceId:string,questionId:string},required:['start','end','quote'],additionalProperties:false};
const answerWire={type:'object',properties:{questionId:string,sectionId:string,selectedOptionIds:strings,textAnswer:string},additionalProperties:true};
const withFile=(schema: CanonicalRecord,description: string): TSchema & {description: string; anyOf: CanonicalRecord[]}=>({anyOf:[fileReference,schema],description:`${description} Prefer a saved {file,pointer} reference for repeated checks; no reconstruction or type coercion.`});
const declarations: [string,string[],string][]=[
 ['get_question_spec',['type'],'Get canonical fields, rules, answer family and a valid example for one exact question type.'],
 ['validate_question',['question'],'Check a private Question against canonical structure and applicable semantic rules.'],
 ['validate_group',['group'],'Check a QuestionGroup’s membership, identities, ordering and bounds.'],
 ['validate_exam',['exam'],'Check Exam hierarchy, scoring units and explicitly requested completeness.'],
 ['verify_evidence',['question','passage','evidence'],'Check exact passage/source spans; does not establish entailment or NOT GIVEN correctness.'],
 ['check_grading_parity',['question','submission'],'Check answer serialization and source-derived compatibility; actual .NET parity remains unverified.'],
 ['inspect_delivery_projection',['question'],'Build an allowlisted public Question, preserving inputs/media and diagnosing privacy risks.'],
];
// Describe the wire shape, not a second copy of the canonical Question schema.
const argumentsSchema: Record<string,TSchema & {type?: string; description: string}>={
 type:{type:'string',description:'Exact uppercase canonical literal, e.g. TRUE_FALSE_NOT_GIVEN (not TrueFalseNotGiven or a slug). Unsupported values return all available literals.'},
 question:withFile(questionWire,'Private canonical Question; numeric idx/difficulty and boolean isCorrect. Get its type spec once per context. No {item:...} wrappers.'),
 group:withFile(groupWire,'QuestionGroup with full questions array, not IDs. Numeric indices; optional bounds and instructionMd.'),
 exam:withFile(examWire,'Exam with sections and questionGroups arrays (not groups). complete is boolean; expectedQuestionCount counts Question records, not slots. Include the full passage in sections[].passageMd.'),
 passage:withFile({anyOf:[string,{type:'object',properties:{id:string,text:string},required:['id','text'],additionalProperties:false}]},'Exact passage text or {id,text}; a file without pointer reads UTF-8 text. Use {id,text} to verify source identity.'),
 evidence:withFile({anyOf:[spanWire,{type:'array',items:spanWire}]},'One exact span or array. Compute zero-based UTF-16 start/end (end-exclusive) locally, never guess offsets or submit sweeps. Mechanical spans do not prove entailment.'),
 submission:withFile({anyOf:[answerWire,{type:'object',properties:{state:{enum:['autosave','final','restored']},answer:answerWire},required:['state','answer'],additionalProperties:false}]},'Canonical wire answer or {state,answer}. UUID identities require a verified backend map; do not invent UUIDs to obtain PASS. Does not execute .NET.'),
};
const outputSchema: TSchema={type:'object',required:['status','contractVersion','checks','diagnostics'],properties:{status:{enum:['PASS','FAIL','UNVERIFIED','ERROR']},contractVersion:{type:'string'},checks:{type:'array'},diagnostics:{type:'array'},data:{type:'object',additionalProperties:true}},additionalProperties:true};
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
 return declarations.map(([name,names,description])=>{
 const optional=name==='validate_exam'?['pilot']:[];
 const parameters: TSchema={type:'object',properties:{...Object.fromEntries(names.map(k=>[k,argumentsSchema[k]])),...(optional.length?{pilot:{type:'boolean',description:'Set true for the 13-mark pilot: require complete artifact, embedded passages, exactly 13 Questions/slots/scoring units and one independently scored slot per Question. Mechanical PASS is not quality PASS; both independent revision-bound reviews remain required.'}}:{})},required:[...names],additionalProperties:false};
 return {
  name,label:name,description,
  parameters,
  outputSchema,
  prepareArguments(args: unknown){const invalid=checkArguments(args,names,optional);if(invalid)throw new Error(JSON.stringify(invalid));
   // Native argument validation may coerce primitives; reject the raw wire shape first.
   if(!Value.Check(parameters,args))throw new Error('NATIVE_ARGUMENT_INVALID');return args;},
  formatPreparationError(_error: unknown,args: unknown){
   const invalid=checkArguments(args,names,optional);if(invalid)return adapt(invalid);
   const r=createReport();
   for(const k of names){const type=argumentsSchema[k].type,v=(args as Record<string,unknown>)[k];
    if(type && (typeof v!==type || v===null || Array.isArray(v)))r.diagnostic('NATIVE_ARGUMENT_INVALID',`/${k}`,`Native argument schema requires a JSON ${type}; domain validation was not invoked.`,String(argumentsSchema[k].description));
   }
   if(name==='verify_evidence'&&object(args)){
    const spans=Array.isArray(args.evidence)?args.evidence:[args.evidence];
    spans.forEach((span,i)=>{if(!object(span)||own(span,'file'))return;
     for(const key of ['start','end'])if(own(span,key)&&!Number.isInteger(span[key]))r.diagnostic('NATIVE_ARGUMENT_INVALID',at(Array.isArray(args.evidence)?`/evidence/${i}`:'/evidence',key),'Evidence offsets must be JSON integers, not quoted strings; domain validation was not invoked.','Compute UTF-16 offsets with JavaScript and JSON.stringify numeric values into a saved evidence file; pass {file,pointer}. Do not retry other shapes.');
    });
   }
   if(r.result.status==='PASS')r.diagnostic('NATIVE_ARGUMENT_INVALID','/','Native wire shape rejected; domain validation was not invoked.','Use typed JSON arrays/numbers/booleans, or saved {file,pointer} references. Do not repeat unchanged calls.');
   return adapt(r.finish());
  },
  async execute(_id: string,args: unknown,signal, _onUpdate,ctx){
   const aborted=()=>{const r=createReport();r.diagnostic('EXECUTION_ABORTED','/','Reading execution was cancelled.','Retry only when the operator intends to continue.',undefined,'ERROR');return adapt(r.finish());};
   try{
    if(signal?.aborted)return aborted();
    const invalid=checkArguments(args,names,optional);if(invalid)return adapt(invalid);
    const resolved: Record<string,unknown>={};
    try{for(const k of names)resolved[k]=k==='type'?(args as Record<string,unknown>)[k]:await artifactInput((args as Record<string,unknown>)[k],ctx?.cwd??process.cwd(),k==='passage');}
    catch{const r=createReport();r.diagnostic('ARTIFACT_INPUT_INVALID','/','Artifact reference could not be read as bounded JSON/text or its pointer was absent.','Check {file,pointer}, the tool cwd, file size and JSON syntax. No validation verdict was produced.',undefined,'ERROR');return adapt(r.finish());}
    if(optional.length&&object(args)&&own(args,'pilot'))resolved.pilot=args.pilot;
    const domain=await getDomain();if(signal?.aborted)return aborted();return adapt(domain.call(name,resolved));
   }catch{const r=createReport();r.diagnostic('INTERNAL_ERROR','/','Reading tool dependency or execution failed before a domain report was available.','Check that the local Reading extension and its domain.ts dependency load. No validation verdict was produced; do not claim readiness.',undefined,'ERROR');return adapt(r.finish());}
  },
 };});
}
