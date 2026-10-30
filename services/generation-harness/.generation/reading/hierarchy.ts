import type { CanonicalContext, CanonicalRecord, Report, QuestionSummary } from './types.ts';
import { fields,own,object,nonblank,positive,identity,identities,keysEqual,at } from './support.ts';
import { validateQuestion } from './question.ts';
interface QuestionNode {q: CanonicalRecord; path: string; idx?: number}
const ints=(v: unknown): v is number=>typeof v==='number' && Number.isInteger(v)&&v>=-2147483648&&v<=2147483647;
const fail=(r: Report,code: string,path: string,message: string)=>r.diagnostic(code,path,message);
function container(r: Report,v: unknown,path: string,allowed: string[],required: string[]): v is CanonicalRecord{
 if(!fields(r,v,allowed,required,path))return false;
 if(own(v,'id')&&!nonblank(v.id))fail(r,'IDENTITY_INVALID',at(path,'id'),'Identity must be a nonblank string.');
 for(const k of ['sectionId','examId'])if(own(v,k)&&!nonblank(v[k]))fail(r,'IDENTITY_INVALID',at(path,k),'Parent identity must be a nonblank string.');
 if(own(v,'idx')&&!ints(v.idx))fail(r,'INDEX_INVALID',at(path,'idx'),'Index must be a signed int32.');
 for(const k of allowed.filter(k=>!['id','idx','sectionId','examId','sections','questionGroups','questions','startIdx','endIdx','complete','expectedQuestionCount'].includes(k))){
  const nullable=['descriptionMd','imageUrl','instructionsMd','passageMd','audioUrl','transcriptMd'].includes(k);
  if(own(v,k)&&!(v[k]===null&&nullable) && (k==='durationMin'?!ints(v[k]):typeof v[k]!=='string'))fail(r,'FIELD_TYPE',at(path,k),'Descriptive field has the wrong source primitive type or nullability.');
 }
 return true;
}
function collection(r: Report,v: CanonicalRecord,key: string,path: string,required=false): CanonicalRecord[]{if(!own(v,key)&&!required)return [];
 if(!Array.isArray(v[key])){fail(r,'ARRAY_REQUIRED',at(path,key),'A supplied collection must be an array.');return [];}return v[key];}
function join(r: Report,value: unknown,parent: unknown,path: string){if(value!==undefined&&typeof value==='string'&&typeof parent==='string'&&identity(value)!==identity(parent))fail(r,'MEMBERSHIP_INVALID',path,'Identity does not match its containing parent.');}
const ordered=<T extends CanonicalRecord>(items: T[])=>items.map((v,i)=>({v,i})).sort((a,b)=>(ints(a.v?.idx)?a.v.idx:0)-(ints(b.v?.idx)?b.v.idx:0));
function locatedIdentities(r: Report,items: {value: CanonicalRecord; path: string}[],caseInsensitive=false): void {
 const seen=new Set<string>();
 for(const {value,path} of items){if(!object(value)||typeof value.id!=='string')continue;const key=caseInsensitive?value.id.toLowerCase():identity(value.id);if(seen.has(key))fail(r,'IDENTITY_DUPLICATE',at(path,'id'),'Identity is duplicated in this scope.');seen.add(key);}
}
function duplicateIndices(r: Report,items: CanonicalRecord[],path: string,code: string){const seen=new Set();items.forEach((v,i)=>{if(object(v)&&ints(v.idx)){if(seen.has(v.idx))fail(r,code,at(at(path,i),'idx'),'Index is duplicated in this scope.');seen.add(v.idx);}});}
function totals(summaries: QuestionSummary[]){return {questionCount:summaries.length,answerSlots:summaries.every(x=>x.answerSlots!==null)?summaries.reduce((n,x)=>n+x.answerSlots!,0):null,scoringUnits:summaries.every(x=>x.scoringUnits!==null)?summaries.reduce((n,x)=>n+x.scoringUnits!,0):null};}
function groupDetails(c: CanonicalContext,r: Report,g: unknown,path: string,sectionId?: string,complete=false){
 const summaries: QuestionSummary[]=[],nodes: QuestionNode[]=[];
 if(!container(r,g,path,['id','idx','questions','sectionId','startIdx','endIdx','instructionMd'],['id','idx','questions']))return {summaries,nodes};
 if(own(g,'idx')&&!positive(g.idx))fail(r,'INDEX_INVALID',at(path,'idx'),'Group index must be positive int32.');
 join(r,g.sectionId,sectionId,at(path,'sectionId'));
 const questions=collection(r,g,'questions',path,true);identities(r,questions,at(path,'questions'));duplicateIndices(r,questions,at(path,'questions'),'QUESTION_INDEX_COVERAGE');
 const options: {value: CanonicalRecord; path: string}[]=[];
 questions.forEach((q,i)=>{const p=at(at(path,'questions'),i),summary=validateQuestion(c,r,q,p);summaries.push(summary);nodes.push({q,path:p});
  if(object(q)){join(r,q.groupId,g.id,at(p,'groupId'));join(r,q.sectionId,sectionId??g.sectionId,at(p,'sectionId'));if(Array.isArray(q.options))q.options.forEach((value: CanonicalRecord,j: number)=>options.push({value,path:at(at(p,'options'),j)}));}
 });
 locatedIdentities(r,options,true);
 const sections=new Set(questions.filter(object).map(q=>q.sectionId).filter(x=>typeof x==='string').map(identity));
 if(sections.size>1)fail(r,'MEMBERSHIP_INVALID',at(path,'questions'),'Questions disagree about their containing Section.');
 const indices=questions.map(q=>q?.idx).filter(positive),low=indices.length?Math.min(...indices):null,high=indices.length?Math.max(...indices):null;
 for(const k of ['startIdx','endIdx'])if(own(g,k)&&!positive(g[k]))fail(r,'GROUP_BOUNDS_MISMATCH',at(path,k),'Supplied group bound must be positive int32.');
 if(positive(g.startIdx)&&positive(g.endIdx)&&g.startIdx>g.endIdx)fail(r,'GROUP_BOUNDS_MISMATCH',path,'Group bounds are reversed.');
 if(indices.length){
  if((positive(g.startIdx)&&low!<g.startIdx)||(positive(g.endIdx)&&high!>g.endIdx))fail(r,'GROUP_BOUNDS_MISMATCH',path,'Question index lies outside the supplied group bounds.');
  else if((positive(g.startIdx)&&low!==g.startIdx)||(positive(g.endIdx)&&high!==g.endIdx)){
   if(complete)fail(r,'GROUP_BOUNDS_MISMATCH',path,'Complete group coverage disagrees with supplied bounds.');
   else r.pending('EXAM_DRAFT_INCOMPLETE',path,'Supplied group bounds contain missing draft coverage.','COMMON');
  }
 }else if(positive(g.startIdx)||positive(g.endIdx)){
  if(complete)fail(r,'GROUP_BOUNDS_MISMATCH',path,'An empty complete-requested group cannot satisfy its supplied Question bounds.');
  else r.pending('EXAM_DRAFT_INCOMPLETE',path,'An empty draft group has unfilled supplied Question bounds.','COMMON');
 }
 const sorted=ordered(questions).map(x=>x.v?.idx).filter(positive);
 if(sorted.some((n,i)=>i>0&&n!==sorted[i-1]+1))r.pending('EXAM_DRAFT_INCOMPLETE',path,'Question index coverage within this group is incomplete.','COMMON');
 return {summaries,nodes};
}
export function validateGroup(c: CanonicalContext,r: Report,g: unknown,path='/group'): CanonicalRecord {
 const start=r.mark(),{summaries,nodes}=groupDetails(c,r,g,path);
 const outcome=r.statusSince(start),invalid=outcome==='FAIL'||outcome==='ERROR',counts=totals(summaries);
 r.pending('PARENT_CONTEXT_UNVERIFIED',path,'A standalone group cannot establish external Section ownership or sibling group coverage.','COMMON');
 r.check('GROUP_HIERARCHY',invalid?'FAIL':'UNVERIFIED',`${c.schema.$id}#/x-langfens/indexing`,path,'hierarchy');
 return {...counts,...(invalid?{scoringUnits:null}:{}),observedQuestionIndices:nodes.map(n=>n.q?.idx).filter(positive),sectionConsistency:invalid?'FAIL':'PASS',parentMembership:'UNVERIFIED'};
}
export function validateExam(c: CanonicalContext,r: Report,e: unknown,path='/exam'): CanonicalRecord {
 const summaries: QuestionSummary[]=[],nodes: QuestionNode[]=[],groups: {value: CanonicalRecord; path: string}[]=[],sections: CanonicalRecord[]=[],options: CanonicalRecord[]=[];let groupCount=0;
 if(!container(r,e,path,['id','sections','complete','expectedQuestionCount','slug','title','descriptionMd','category','level','durationMin','imageUrl'],['id','sections']))return {sectionCount:0,groupCount:0,questionCount:0,answerSlots:null,scoringUnits:null};
 if(own(e,'complete')&&typeof e.complete!=='boolean')fail(r,'FIELD_TYPE',at(path,'complete'),'Completeness qualifier must be boolean.');
 if(own(e,'expectedQuestionCount')&&!positive(e.expectedQuestionCount))fail(r,'FIELD_TYPE',at(path,'expectedQuestionCount'),'Expected Question count must be positive int32.');
 const complete=e.complete===true, supplied=collection(r,e,'sections',path,true);identities(r,supplied,at(path,'sections'));duplicateIndices(r,supplied,at(path,'sections'),'ORDERING_CONFLICT');
 for(const {v:s,i} of ordered(supplied)){
  const p=at(at(path,'sections'),i);sections.push(s);
  if(!container(r,s,p,['id','idx','examId','title','instructionsMd','passageMd','audioUrl','transcriptMd','questionGroups','questions'],['id','idx']))continue;
  join(r,s.examId,e.id,at(p,'examId'));
  if(!own(s,'questionGroups')&&!own(s,'questions'))fail(r,'FIELD_REQUIRED',p,'Section needs a recognized Question collection.');
  if(ints(s.idx)&&s.idx!==sections.length)r.pending('SECTION_INDEX_POLICY_UNVERIFIED',at(p,'idx'),'Section positivity and contiguity policy is not defined by the Question contract.','COMMON');
  const gs=collection(r,s,'questionGroups',p),qs=collection(r,s,'questions',p);
  if(gs.length&&qs.length)fail(r,'SECTION_MEMBERSHIP_CONFLICT',p,'Grouped and section-level Questions compete for ownership; no content was discarded.');
  identities(r,gs,at(p,'questionGroups'));duplicateIndices(r,gs,at(p,'questionGroups'),'GROUP_INDEX_COVERAGE');
  if(!keysEqual(gs.map(g=>g?.idx),gs.map((_,j)=>j+1)))fail(r,'GROUP_INDEX_COVERAGE',at(p,'questionGroups'),'Group indices must uniquely cover 1..N within the Section.');
  for(const {v:g,i:j} of ordered(gs)){
   const gp=at(at(p,'questionGroups'),j);groupCount++;groups.push({value:g,path:gp});
   const d=groupDetails(c,r,g,gp,s.id,complete);summaries.push(...d.summaries);nodes.push(...ordered(d.nodes.map(n=>({...n,idx:n.q?.idx}))).map(n=>n.v));
  }
  for(const {v:q,i:j} of ordered(qs)){
   const qp=at(at(p,'questions'),j);summaries.push(validateQuestion(c,r,q,qp));nodes.push({q,path:qp});
   if(object(q)){join(r,q.sectionId,s.id,at(qp,'sectionId'));if(q.groupId!==undefined)fail(r,'MEMBERSHIP_INVALID',at(qp,'groupId'),'Ungrouped Question has an unresolved group reference.');}
  }
 }
 locatedIdentities(r,groups);const seenQ=new Set(),seenOptions=new Set(),seenIdx=new Set();
 let ownership=false;
 nodes.forEach(({q,path:p})=>{if(!object(q))return;
  if(typeof q.id==='string'){const key=identity(q.id);if(seenQ.has(key)){ownership=true;fail(r,'IDENTITY_DUPLICATE',at(p,'id'),'Question occurs more than once in this paper.');}seenQ.add(key);}
  if(positive(q.idx)){if(seenIdx.has(q.idx))fail(r,'QUESTION_INDEX_COVERAGE',at(p,'idx'),'Paper-wide Question index is duplicated.');seenIdx.add(q.idx);}
  if(Array.isArray(q.options))q.options.forEach((o: CanonicalRecord,i: number)=>{if(typeof o?.id!=='string')return;const key=o.id.toLowerCase();if(seenOptions.has(key)){ownership=true;fail(r,'IDENTITY_DUPLICATE',at(at(at(p,'options'),i),'id'),'Option identity is duplicated across the paper.');}seenOptions.add(key);options.push(o);});
 });
 const indices=nodes.map(n=>n.q?.idx),coverage=indices.every((n,i)=>n===i+1);
 if(!coverage){
  if(complete)fail(r,'QUESTION_INDEX_COVERAGE',path,'Complete paper Question indices must follow hierarchy order and cover 1..QuestionCount.');
  else if(indices.some((n,i)=>i>0&&positive(n)&&positive(indices[i-1])&&n<=indices[i-1]))fail(r,'ORDERING_CONFLICT',path,'Question indices conflict with Section/group hierarchy ordering.');
  else r.pending('EXAM_DRAFT_INCOMPLETE',path,'Paper-wide draft Question coverage is incomplete.','COMMON');
 }
 if(positive(e.expectedQuestionCount)&&nodes.length!==e.expectedQuestionCount){
  if(complete||nodes.length>e.expectedQuestionCount)fail(r,'EXAM_QUESTION_COUNT',at(path,'expectedQuestionCount'),'Question record count differs from the explicitly requested count.');
  else r.pending('EXAM_DRAFT_INCOMPLETE',path,'Draft is below the explicitly requested Question count.','COMMON');
 }
 if(!complete||nodes.length===0)r.pending('EXAM_COMPLETENESS_UNVERIFIED',path,'Draft or empty content cannot establish complete paper coverage.','COMMON');
 r.pending('TRANSPORT_ORDER_UNVERIFIED',path,'Typed delivery sorts by idx; JSON snapshot delivery traverses supplied arrays. No transport execution is claimed.','COMPATIBILITY');
 const counts=totals(summaries),invalid=r.result.status==='FAIL'||r.result.status==='ERROR';
 r.check('EXAM_HIERARCHY',invalid?'FAIL':'PASS',`${c.schema.$id}#/x-langfens/indexing`,path,'hierarchy');
 return {sectionCount:supplied.length,groupCount,...counts,...(ownership||invalid?{scoringUnits:null}:{}),completeness:complete?'complete-requested':'draft',...(positive(e.expectedQuestionCount)?{expectedQuestionCount:e.expectedQuestionCount}:{}),claims:{hierarchy:invalid?'FAIL':'PASS',structure:invalid?'FAIL':'PASS',semanticShape:'UNVERIFIED',ieltsSemantics:'UNVERIFIED',consumerCompatibility:'UNVERIFIED'}};
}
