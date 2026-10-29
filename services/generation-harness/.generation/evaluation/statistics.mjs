// Exact Clopper-Pearson intervals for a binomial *working independence model*.
// Section intervals are reported separately: within-section items are correlated.
function cdf(k,n,p) {
  if(p===0) return 1;
  if(p===1) return k>=n?1:0;
  let logChoose=0, sum=0;
  for(let i=0;i<=k;i++) {
    if(i) logChoose+=Math.log(n-i+1)-Math.log(i);
    sum+=Math.exp(logChoose+i*Math.log(p)+(n-i)*Math.log1p(-p));
  }
  return Math.min(1,sum);
}
function invert(k,n,target) {
  let lo=0,hi=1;
  for(let i=0;i<80;i++) {const mid=(lo+hi)/2; if(cdf(k,n,mid)>target) lo=mid; else hi=mid;}
  return (lo+hi)/2;
}
export function exactInterval(k,n,confidence=0.95) {
  if(!Number.isInteger(k) || !Number.isInteger(n) || n<1 || k<0 || k>n || confidence<=0 || confidence>=1) throw new Error('Invalid binomial counts');
  const alpha=1-confidence;
  return {events:k,total:n,rate:k/n,lower:k===0?0:invert(k-1,n,1-alpha/2),upper:k===n?1:invert(k,n,alpha/2),confidence,method:'Clopper-Pearson two-sided; independence assumption'};
}
export function confidenceMetrics(questions) {
  const sections=[...new Set(questions.map(q=>q.sectionId))].map(id=>questions.filter(q=>q.sectionId===id));
  return {
    observedCriticalItems:questions.filter(q=>q.critical).length,
    criticalOrUnresolvedItems:exactInterval(questions.filter(q=>q.critical || q.unresolved.length).length,questions.length),
    criticalOrUnresolvedSections:exactInterval(sections.filter(s=>s.some(q=>q.critical || q.unresolved.length)).length,sections.length),
    unresolvedItems:questions.filter(q=>q.unresolved.length).length,
    noncriticalPass:exactInterval(questions.filter(q=>q.noncriticalPass).length,questions.length),
    caution:'Descriptive only. Critical-rate bounds conservatively count unresolved items/sections as adverse events, not as defect-free. Missing/UNCERTAIN is not PASS; no advancement from a pilot. Section independence also needs study-design justification. Preregister a section-cluster bootstrap for heterogeneous larger samples.',
  };
}
