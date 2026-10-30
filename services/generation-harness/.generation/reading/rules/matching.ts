import type { CanonicalContext, CanonicalRecord, Report, Status } from '../types.ts';
import { at,keysEqual } from '../support.ts';
export function readMatchingPresentation(c: CanonicalContext,q: CanonicalRecord) {
 const targets=[...q.promptMd.matchAll(/^\s*([1-9][0-9]*)\.\s+([^\n]+)$/gm)].map(m=>({id:m[1],text:m[2].trim()}));
 const heading=q.type==='MATCHING_HEADING', issues: {code: string; path: string}[]=[], bank: {label: string; text: string; optionId: string}[]=[];
 q.options.forEach((o: CanonicalRecord,i: number)=>{const m=o.contentMd.match(heading?/^([ivxlcdm]+)\.\s+(.+)$/u:/^([A-Z]+)\.\s+(.+)$/u);
  if(m)bank.push({label:m[1],text:m[2],optionId:o.id});else issues.push({code:q.type==='CLASSIFICATION'?'CLASSIFICATION_CATEGORY_UNPARSED':'MATCH_BANK_LABEL_INVALID',path:`/options/${i}/contentMd`});
 });return {targets,bank,issues};
}
export function runMatchingRule(id: string,c: CanonicalContext,r: Report,q: CanonicalRecord,path: string): Status {
 const provenance=`${c.schema.$id}#/x-langfens/semanticRules/${id}`,start=r.mark();
 const fail=(code: string,p: string,message: string)=>r.diagnostic(code,at(path,p),message,undefined,undefined,'FAIL',id);
 if(id==='FLOW_ORDERING'){
  r.pending('SOURCE_CONTRACT_DIVERGENCE',path,'Source-only flow legacy parsing differs from historical metadata; canonical answers remain arrays.',id);
  r.pending('FLOW_SEMANTICS_UNVERIFIED',path,'Actual .NET normalization, process order, hints and consumer state transitions require independent evidence.',id);
 }else{
  const {targets,bank,issues}=readMatchingPresentation(c,q),pairs=Object.entries(q.matchPairs) as [string,string[]][],assigned=pairs.map(([,p])=>p[0]),reused=new Set(assigned).size!==assigned.length;
  if(id==='MATCHING_TARGETS'){
   if(!targets.length)fail('MATCH_TARGET_MISSING','promptMd','Explicit numbered public targets are missing.');
   if(!keysEqual(targets.map(t=>t.id),Object.keys(q.matchPairs)))fail('MATCH_TARGET_KEY_MISMATCH','promptMd','Unique displayed statement IDs do not match private target keys.');
   r.pending('MATCH_SLOT_UNREACHABLE',path,'Independent editable target inputs and actual renderer events are unverified.',id);
  }else if(id==='MATCHING_BANK'){
   for(const issue of issues)r.diagnostic(issue.code,path+issue.path,'A canonical bank label cannot be parsed.','Use explicit canonical bank label syntax.',undefined,'FAIL',id);
   if(new Set(bank.map(b=>b.label)).size!==bank.length)fail('MATCH_BANK_LABEL_DUPLICATE','options','Bank labels are duplicated.');
   for(const [target,pair] of pairs){
    if(!bank.some(b=>b.label===pair[0]))r.diagnostic('MATCH_BANK_KEY_UNKNOWN',at(at(path,'matchPairs'),target),'A grading key does not name a bank label.',undefined,undefined,'FAIL',id);
    const expected=q.type==='MATCHING_HEADING'?bank.find(b=>b.label===pair[0])?.text:targets.find(t=>t.id===target)?.text;
    if(expected!==undefined && expected!==pair[1])r.diagnostic('MATCH_DISPLAY_INVALID',at(at(path,'matchPairs'),target),'Pair display text disagrees with its public source.',undefined,undefined,'FAIL',id);
   }
   if(q.type!=='CLASSIFICATION' && !bank.some(b=>!assigned.includes(b.label)))fail('MATCH_DISTRACTOR_MISSING','options','A new matching exercise needs an unused distractor.');
   r.pending('MATCH_BANK_TRANSPORT_UNVERIFIED',path,'Actual bank transport and renderer behavior are unverified.',id);
  }else if(id==='HEADING'){
   const marker=q.promptMd.indexOf('List of Headings:');
   const visible=marker<0?[]:[...q.promptMd.slice(marker+'List of Headings:'.length).matchAll(/^([ivxlcdm]+)\.\s+([^\n]+)$/gm)].map(m=>`${m[1]}. ${m[2]}`);
   if(!keysEqual(visible,bank.map(b=>`${b.label}. ${b.text}`)))fail('HEADING_BANK_MISSING','promptMd','The complete heading bank is not listed under List of Headings:.');
   if(reused)fail('HEADING_REUSED','matchPairs','A heading is assigned to multiple targets.');
   r.pending('HEADING_SEMANTICS_UNVERIFIED',path,'Passage-to-heading suitability and instructions require independent review.',id);
  }else if(id==='INFORMATION'){
   if(bank.some(b=>b.text!==`Paragraph ${b.label}`))fail('PARAGRAPH_BANK_INVALID','options','Information bank must identify its paragraph letters.');
   if(q.wordList)r.pending('WORD_BANK_UNSUPPORTED',at(path,'wordList'),'Word-list consumer propagation is unsupported; task remains paragraph matching.',id);
   if(!/\b(?:more than once|only once|once only|not reuse|cannot reuse)\b/i.test(q.promptMd))r.pending('INFORMATION_REUSE_UNVERIFIED',at(path,'promptMd'),'Reuse permission is not explicit.',id,'State whether paragraph letters can be reused.');
   r.pending('INFORMATION_SEMANTICS_UNVERIFIED',path,'Passage matching quality is unverified.',id);
  }else if(id==='FEATURES'){
   if(reused&&!/\b(?:may|can)\s+use\b[^\n.]*\bmore than once\b/i.test(q.promptMd))fail('FEATURE_REUSE_INSTRUCTION_MISMATCH','promptMd','Used feature reuse lacks explicit permission.');
   r.pending('FEATURE_SEMANTICS_UNVERIFIED',path,'Feature meaning and passage support are unverified.',id);
  }else if(id==='ENDINGS'){
   if(reused)fail('ENDING_REUSED','matchPairs','An ending is assigned more than once.');
   r.pending('ENDING_SENTENCE_INVALID',path,'Grammar and factual support of assembled sentences have not been independently reviewed.',id);
  }else{
   for(const issue of issues)r.diagnostic(issue.code,path+issue.path,'Canonical classification category labels are required.','Use A. label syntax without changing statement IDs.',undefined,'FAIL',id);
   r.pending('CLASSIFICATION_CONSUMER_UNVERIFIED',path,'Exact statement identities are preserved; legacy consumer support remains unverified.',id);
  }
 }
 const status=r.statusSince(start),shape=status==='FAIL'||status==='ERROR'?status:id==='FLOW_ORDERING'?'UNVERIFIED':'PASS';
 r.check(`${id}.shape`,shape,provenance,path);
 r.check(id,status,provenance,path);
 return shape;
}
