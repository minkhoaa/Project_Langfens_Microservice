// Executable JSON schemas; no provider, credentials, inference, or runtime orchestration.
import { Type as T } from 'typebox';
import { Value } from 'typebox/value';
import { readFileSync } from 'node:fs';
import { groupSchema } from '../reading/contracts.ts';
export const rubric = JSON.parse(readFileSync(new URL('./rubric.json', import.meta.url), 'utf8'));
const object = properties => T.Object(properties, {additionalProperties:false});
const text = T.String({minLength:1, pattern:'\\S'});
const optional = T.Optional;
const nullable = s => T.Union([s,T.Null()]);
const enumeration = values => T.Union(values.map(x=>T.Literal(x)));
export const verdict = enumeration(rubric.verdicts);
export const span = object({sectionId:text,start:T.Integer({minimum:0}),end:T.Integer({minimum:1}),quote:text});
export const judgment = object({criterion:enumeration(rubric.criteria),verdict,severity:enumeration(['none','minor','major','critical']),reason:text,category:text,spans:optional(T.Array(span))});
export const metadata = object({provider:text,model:text,version:text,prompt:text,temperature:T.Number(),usage:nullable(object({inputTokens:T.Integer({minimum:0}),outputTokens:T.Integer({minimum:0})})),latencyMs:nullable(T.Number({minimum:0})),cost:nullable(T.Number({minimum:0})),currency:text,costBasis:text});
export const solverOutput = object({questionId:text,answer:T.String(),confidence:nullable(T.Number({minimum:0,maximum:1})),spans:T.Array(span)});
export const reviewerOutput = object({questionId:text,reasoning:text,judgments:T.Array(judgment,{minItems:8,maxItems:8})});
export const adjudication = object({questionId:text,criterion:enumeration(rubric.criteria),source:T.Literal('human'),adjudicatorId:text,reasoning:text,verdict,severity:enumeration(['none','minor','major','critical']),reason:text,category:text,spans:T.Array(span,{minItems:1})});
export const solverAdjudication = object({questionId:text,source:T.Literal('human'),adjudicatorId:text,verdict,reasoning:text,spans:T.Array(span,{minItems:1})});
export const manifestEntry = object({role:enumeration(['assignment','prompt','rubric','canonical','projection','native_results','lifecycle','generator_raw','solver_raw','reviewer_raw','human_review']),path:text,sha256:T.String({pattern:'^[a-f0-9]{64}$'}),sessionId:optional(text)});
export const protocolChecks = ['independence','blindIsolation','noLeakage','noUnauthorizedAccess','compatibility','nativeReceipts','manifestComplete','heldOutSuitability','frozenBeforeGeneration'];
export const record = object({
  version:T.Literal(rubric.version),evidenceClass:enumeration(['SYNTHETIC','REAL_MODEL']),
  artifact:object({id:text,sections:T.Array(object({id:text,passage:text,groups:T.Array(object({id:text}))}),{minItems:1}),questions:T.Array(object({id:text,groupId:text,sectionId:text,prompt:text,acceptedAnswers:optional(T.Array(text,{minItems:1})),evidence:optional(T.Array(span,{minItems:1}))}),{minItems:1})}),
  generator:object({raw:text,sessionId:optional(text),metadata:optional(nullable(metadata))}),
  deterministic:object(Object.fromEntries(['structure','scoring','delivery','isolation','compatibility'].map(k=>[k,verdict]))),
  solverAnswers:T.Array(object({...solverOutput.properties,raw:text,sessionId:optional(text),metadata:optional(nullable(metadata))})),
  reviews:T.Array(object({...reviewerOutput.properties,sessionId:text,source:enumeration(['synthetic','model','human']),raw:optional(text),metadata:optional(nullable(metadata))})),
  adjudications:T.Array(adjudication),solverAdjudications:optional(T.Array(solverAdjudication)),
  manifest:optional(T.Array(manifestEntry)),
  protocolAudit:optional(object({source:T.Literal('human'),adjudicatorId:text,verdict,reasoning:text,manifestDigest:T.String({pattern:'^[a-f0-9]{64}$'}),checks:object(Object.fromEntries(protocolChecks.map(k=>[k,verdict])))})),
});
export function validate(schema, value, label='record') {
  if (!Value.Check(schema,value)) throw new Error(`Invalid ${label} schema`);
}
export const generatorOutput = object({groups:T.Array(groupSchema,{minItems:1}),evidence:T.Array(object({questionId:text,...span.properties}),{minItems:1})});
export const modelOutputSchemas = {generator:generatorOutput,solver:solverOutput,reviewer:reviewerOutput,adjudication,solverAdjudication};
