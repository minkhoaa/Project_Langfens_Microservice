import '../../../test/offline.mjs';
import { readFileSync } from 'node:fs';
import { createReport } from '../support.ts';
export const canonicalUrl=new URL('../../contracts/question-types.v1.schema.json',import.meta.url);
export const vectors=JSON.parse(readFileSync(new URL('../../contracts/test-vectors/canonical-questions.v1.json',import.meta.url)));
export const gradingCases=JSON.parse(readFileSync(new URL('../../contracts/test-vectors/grading-cases.v1.json',import.meta.url)));
export const q=type=>structuredClone(vectors.find(x=>x.type===type));
export const hasCode=(r,code)=>r.diagnostics.some(d=>d.code===code);
export const check=(r,id)=>r.checks.find(c=>c.id===id)?.status;
export const group=(questions=[{...q('MULTIPLE_CHOICE_SINGLE'),idx:1}])=>({id:'g1',idx:1,questions});
export const exam=(groups=[group()])=>({id:'e1',sections:[{id:'s1',idx:1,questionGroups:groups}]});
export const wire=(question,fields={})=>({questionId:question.id,sectionId:question.sectionId,selectedOptionIds:[],...fields});
let context;
export async function initialize(){const {loadCanonical}=await import('../contract.ts');context??=loadCanonical(canonicalUrl);return context;}
export function inspect(handler,...args){if(!context)throw Error('Call initialize in test setup');const r=createReport(context);const data=handler(context,r,...args);return r.finish(data);}
