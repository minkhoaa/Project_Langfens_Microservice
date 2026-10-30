import type { CanonicalContext, CanonicalRecord, Report, Status } from './types.ts';
import { fields,object,nonblank,own,identity,at } from './support.ts';
import { validateQuestion } from './question.ts';
function splitSurrogate(text: string,i: number){if(i<=0||i>=text.length)return false;const a=text.charCodeAt(i-1),b=text.charCodeAt(i);return a>=0xd800&&a<=0xdbff&&b>=0xdc00&&b<=0xdfff;}
export function verifyEvidence(c: CanonicalContext,r: Report,question: unknown,passage: unknown,evidence: unknown): CanonicalRecord {
 validateQuestion(c,r,question);
 const start=r.mark();let text: string | undefined,id: string | undefined;
 if(typeof passage==='string')text=passage;
 else if(fields(r,passage,['id','text'],['id','text'],'/passage')){
  if(!nonblank(passage.id))r.diagnostic('FIELD_TYPE','/passage/id','Passage identity must be nonblank.');else id=passage.id;
  if(typeof passage.text!=='string')r.diagnostic('FIELD_TYPE','/passage/text','Passage text must be a string.');else text=passage.text;
 }
 const spans=Array.isArray(evidence)?evidence:[evidence];let verifiedSpanCount=0;
 if(!spans.length)r.diagnostic('EVIDENCE_SPAN_INVALID','/evidence','At least one explicit span is required.');
 spans.forEach((span,i)=>{
  const p=Array.isArray(evidence)?at('/evidence',i):'/evidence';
  if(!fields(r,span,['start','end','quote','sourceId','questionId'],['start','end','quote'],p))return;
  const valid=typeof text==='string'&&Number.isInteger(span.start)&&Number.isInteger(span.end)&&span.start>=0&&span.start<span.end&&span.end<=text.length&&!splitSurrogate(text,span.start)&&!splitSurrogate(text,span.end)&&typeof span.quote==='string'&&span.quote.length>0;
  let status: Status='FAIL';
  if(!valid)r.diagnostic('EVIDENCE_SPAN_INVALID',p,'Span offsets or quote are invalid.','Use exact zero-based UTF-16 end-exclusive offsets without splitting surrogate pairs.');
  else if(text!.slice(span.start,span.end)!==span.quote)r.diagnostic('EVIDENCE_SPAN_MISMATCH',p,'Quoted text does not equal the exact supplied passage span.','Correct the quote or explicit offsets without normalization.');
  else{status='PASS';verifiedSpanCount++;}
  r.check('EVIDENCE_SPAN',status,[],p,'evidence');
  if(own(span,'sourceId')&&!nonblank(span.sourceId))r.diagnostic('FIELD_TYPE',at(p,'sourceId'),'Source identity must be nonblank.');
  else if(!id||!own(span,'sourceId'))r.pending('EVIDENCE_SOURCE_UNVERIFIED',p,'Source identity is unavailable on one side of the reference.');
  else if(identity(span.sourceId)!==identity(id))r.diagnostic('EVIDENCE_SOURCE_MISMATCH',at(p,'sourceId'),'Evidence source does not match the supplied passage.');
  if(own(span,'questionId')){
   if(!nonblank(span.questionId))r.diagnostic('FIELD_TYPE',at(p,'questionId'),'Question reference must be nonblank.');
   else if(object(question)&&nonblank(question.id)&&identity(span.questionId)!==identity(question.id))r.diagnostic('EVIDENCE_QUESTION_MISMATCH',at(p,'questionId'),'Evidence references another Question.');
  }
 });
 const mechanicalStatus=r.statusSince(start);
 r.pending('EVIDENCE_SEMANTICS_UNVERIFIED','/evidence','Span matching does not establish entailment, contradiction, NOT GIVEN absence, factual truth or semantic quality.','TRUTH_EVIDENCE');
 r.check('EVIDENCE_SEMANTICS','UNVERIFIED',[], '/evidence','evidence');
 return {spanCount:spans.length,verifiedSpanCount,mechanicalStatus,semanticStatus:'UNVERIFIED'};
}
