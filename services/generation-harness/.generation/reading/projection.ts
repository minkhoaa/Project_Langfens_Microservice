import type { CanonicalContext, CanonicalRecord, Report } from './types.ts';
import { structural,own,at,keysEqual } from './support.ts';
import { validateQuestion } from './question.ts';
import { readBlankMarkers } from './rules/completion.ts';
import { readMatchingPresentation } from './rules/matching.ts';
const privateAnnotation=/(?:["'](?:blankAcceptTexts|blankAcceptRegex|shortAnswerAcceptTexts|shortAnswerAcceptRegex|matchPairs|orderCorrects|isCorrect|explanationMd|modelAnswers|evidence|reviews?)["']\s*:)|(?:^|[\n.!?]\s*)(?:the\s+)?(?:correct\s+answers?|answer\s+key|correct\s+order|solution)\s*[:=]/i;
function allow(value: CanonicalRecord,properties: CanonicalRecord): CanonicalRecord{const publicValue: CanonicalRecord={};for(const key of Object.keys(properties))if(own(value,key))Object.defineProperty(publicValue,key,{value:structuredClone(value[key]),enumerable:true,writable:true,configurable:true});return publicValue;}
export function inspectProjection(c: CanonicalContext,r: Report,q: CanonicalRecord): CanonicalRecord {
 const summary=validateQuestion(c,r,q),provenance=`${c.schema.$id}#/x-langfens/semanticRules/PROJECTION`;
 const base={inputIdentities:[],fieldPrivacyStatus:'UNVERIFIED',semanticPrivacyStatus:'UNVERIFIED',consumerCompatibility:'UNVERIFIED'};
 if(!summary.structuralValid)return base;
 const student=allow(q,c.schema.$defs.StudentQuestion.properties);
 // flowChartNodes is not a private canonical field; no solution-ordered array is copied.
 student.options=q.options.map((o: CanonicalRecord)=>allow(o,c.schema.$defs.PublicOption.properties));
 const scan=(v: unknown,path: string)=>{if(typeof v==='string'&&privateAnnotation.test(v))r.diagnostic('STUDENT_ANSWER_HINT',path,'Public content contains an explicit private-answer annotation.','Remove private answer annotations from public content.',undefined,'FAIL','PROJECTION');};
 for(const [key,value] of Object.entries(student)){
  if(key==='options')(value as CanonicalRecord[]).forEach((o: CanonicalRecord,i: number)=>Object.entries(o).forEach(([k,v])=>scan(v,at(at(at('/question','options'),i),k))));
  else if(Array.isArray(value))value.forEach((v,i)=>scan(v,at(at('/question',key),i)));
  else scan(value,at('/question',key));
 }
 let ids: {kind: string; id: string}[]=[];
 if(summary.family==='single'||summary.family==='multiple')ids=student.options.map((o: CanonicalRecord)=>({kind:'option',id:o.id}));
 else if(summary.family==='completion'){
  const markers=readBlankMarkers(student.promptMd);ids=markers.ids.map(id=>({kind:'blank',id}));
  if(markers.malformed||markers.duplicateIds.length||!keysEqual(markers.ids,Object.keys(q.blankAcceptTexts)))r.diagnostic('PUBLIC_FIELD_DROPPED','/question/promptMd','Public blank identities do not match required input slots.','Author exact visible blank markers.',undefined,'FAIL','PROJECTION');
 }else if(summary.family==='short')ids=[{kind:'short',id:student.id}];
 else if(summary.family==='matching'){
  const {targets}=readMatchingPresentation(c,q);ids=targets.map(t=>({kind:'target',id:t.id}));
  if(!keysEqual(targets.map(t=>t.id),Object.keys(q.matchPairs)))r.diagnostic('PUBLIC_FIELD_DROPPED','/question/promptMd','Visible target identities do not match required inputs.','Author exact public statements; never recover them from private pairs.',undefined,'FAIL','PROJECTION');
 }else{
  const nodes=[...student.promptMd.matchAll(/^\s*-\s+([a-z0-9]+(?:-[a-z0-9]+)*):\s*([^\n]+)$/gm)].map(m=>({key:m[1],label:m[2].trim()}));
  if(!keysEqual(nodes.map(n=>n.key),q.orderCorrects)||nodes.some(n=>!n.label)){
   r.pending('FLOW_PUBLIC_NODES_UNAVAILABLE','/question/promptMd','Explicit public flow labels are unavailable or do not match the node key set.','FLOW_ORDERING','Author public - key: label lines without revealing the solution order.');
   r.check('PROJECTION','UNVERIFIED',provenance,'/question','projection');return base;
  }
  student.flowChartNodes=nodes.sort((a: {key: string},b: {key: string})=>a.key<b.key?-1:a.key>b.key?1:0);ids=student.flowChartNodes.map((n: {key: string})=>({kind:'node',id:n.key}));
 }
 const valid=structural(c,r,student,'#/$defs/StudentQuestion','/question','STUDENT_STRUCTURE');
 const failed=r.result.status==='FAIL'||r.result.status==='ERROR';
 r.check('PROJECTION_FIELDS',valid&&!failed?'PASS':'FAIL',provenance,'/question','projection');
 r.pending('STUDENT_SEMANTIC_PRIVACY_UNVERIFIED','/question','Field allowlisting cannot establish absence of encoded or semantic answer hints.','PROJECTION');
 r.pending('BLIND_ISOLATION_UNVERIFIED','/question','Public projection and fresh context are not OS filesystem isolation.','COMPATIBILITY');
 r.check('PROJECTION','UNVERIFIED',provenance,'/question','projection');
 return {...base,fieldPrivacyStatus:valid&&!failed?'PASS':'FAIL',...(!failed&&valid?{studentQuestion:student,inputIdentities:ids}:{})};
}
