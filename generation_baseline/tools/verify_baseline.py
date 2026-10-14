#!/usr/bin/env python3
"""Offline package structural and contract validator. Not a source or model test."""
from pathlib import Path
import json,re,sys,hashlib
BASE=Path(__file__).resolve().parents[1]
issues=[];checks=0

def check(label,ok):
 global checks
 checks+=1
 if not ok:issues.append(label)

def load(p):return (BASE/p).read_text(encoding='utf8')

phase_files=sorted((BASE/'prompts').glob('prompt-phase-*.md'))
sprint_files=sorted((BASE/'prompts/sprints').glob('prompt-sprint-*.md'))
check('14 phases',len(phase_files)==14)
check('70 sprints',len(sprint_files)==70)
check('phase sequence',[p.name for p in phase_files]==[f'prompt-phase-{i:02d}.md' for i in range(14)])
check('sprint sequence',[p.name for p in sprint_files]==[f'prompt-sprint-{i:02d}-{j:02d}.md' for i in range(14) for j in range(1,6)])
for path in phase_files:
 text=path.read_text(encoding='utf8');phase=int(path.stem[-2:])
 for label,criterion in [
  ('normative header','TARGET_SPEC / NOT_RUN' in text),
  ('phase boundary','Scope boundaries' in text and 'Explicit exclusions' in text),
  ('observables','Required phase-wide behavior' in text),
  ('gate','Phase acceptance and evidence requirements' in text),
  ('five referenced sprints',all(f'prompt-sprint-{phase:02d}-{j:02d}.md' in text for j in range(1,6))),
  ('no old skills','/my_'+'plan_skill' not in text and '/my_'+'implement_skill' not in text),
  ('autonomous phase prompt','Autonomous RG' in text and 'run this phase end to end' in text),
  ('micro-sprint checkpoints','Between sprints' in text and 'PHASE_STATUS.json' in text),
 ]:check(f'{path.relative_to(BASE)} {label}',criterion)
for path in sprint_files:
 text=path.read_text(encoding='utf8');m=re.fullmatch(r'prompt-sprint-(\d\d)-(\d\d)\.md',path.name)
 pid,si=map(int,m.groups());sid=f'RG{pid:02d}-S{si:02d}'
 for label,criterion in [
  ('target state','TARGET_SPEC / NOT_RUN' in text),
  ('own ID',sid in text),
  ('bounded scope','Objective and bounded scope' in text and 'Out of scope' in text),
  ('preconditions','Preconditions and input contract' in text),
  ('observed behaviors','Required observable behavior' in text),
  ('specific positive',f'POS-{sid}' in text),
  ('specific negative',f'NEG-{sid}' in text),
  ('failure edge',f'EDGE-{sid}' in text),
  ('regression',f'REG-{sid}' in text),
  ('evidence','Acceptance and required evidence' in text),
  ('links',f'../prompt-phase-{pid:02d}.md' in text),
  ('no old skills','/my_'+'plan_skill' not in text and '/my_'+'implement_skill' not in text),
  ('self-contained sprint execution','Self-contained native execution pipeline' in text),
  ('named tests in execution',all(f'{k}-{sid}' in text for k in ['POS','NEG','EDGE','REG'])),
  ('sprint checkpoint',f'{sid}.json' in text),
 ]:check(f'{path.relative_to(BASE)} {label}',criterion)

files=list(BASE.rglob('*.md'))
for path in files:
 t=path.read_text(encoding='utf8')
 for match in re.finditer(r'(?<!!)\[[^]]+\]\(([^)]+)\)',t):
  val=match.group(1).split('#')[0]
  if not val or val.startswith(('https:','http:','mailto:')):continue
  check(f'broken link {path.relative_to(BASE)} → {val}',(path.parent/val).exists())

for f in ['SOURCE_OF_TRUTH.md','MASTER_PROPOSAL.md','PHASE_INDEX.md','SPRINT_INDEX.md','REQUIREMENTS_TRACEABILITY.md','architecture/SYSTEM_BOUNDARIES.md','architecture/GENERATION_FLOWS.md','architecture/STATE_AND_AUTHORITY.md','architecture/PRODUCT_LIFECYCLE.md','research/RQ2_PROTOCOL.md','research/RUBRIC.md','research/DATA_GOVERNANCE.md','research/ANALYSIS_PLAN.md','research/FINAL_BATCH_RULES.md','verification/EVIDENCE_AND_GATE_POLICY.md','verification/GATE_MATRIX.md','contracts/CONTRACT_REGISTRY.md','contracts/JSON_SCHEMAS.json']:
 check('required file '+f,(BASE/f).exists())

schemas=json.loads(load('contracts/JSON_SCHEMAS.json'))
check('schema 2020-12',schemas.get('$schema','').endswith('2020-12/schema'))
check('schema count >= 20',len(schemas.get('$defs',{}))>=20)
for name in ['GenerationRequest','GenerationResult','SolverView','AnswerVerificationView','GoldReferenceView','EvaluationResult','ExperimentManifest','StudentAttempt']:
 check('defined schema '+name,name in schemas['$defs'])
try:
 import jsonschema
 jsonschema.Draft202012Validator.check_schema(schemas)
 check('JSON Schema meta validation',True)
 ex=json.loads(load('contracts/SCHEMA_EXAMPLES.json'))
 for name,definition in [('generation_result_valid','GenerationResult'),('solver_view_valid','SolverView'),('usage_unknown_valid','UsageRecord')]:
  jsonschema.Draft202012Validator({'$schema':schemas['$schema'],'$defs':schemas['$defs'],'$ref':'#/$defs/'+definition}).validate(ex[name]);check('example '+name,True)
 bad=dict(ex['solver_view_valid']);bad['generator_proposed_answer']='CANARY_SECRET'
 try:
  jsonschema.Draft202012Validator({'$schema':schemas['$schema'],'$defs':schemas['$defs'],'$ref':'#/$defs/SolverView'}).validate(bad)
  check('solver rejects proposed answer',False)
 except jsonschema.ValidationError:check('solver rejects proposed answer',True)
except ModuleNotFoundError:
 print('WARN: jsonschema unavailable, schema meta + example validation not executed')
 check('jsonschema dependency present',False)

catalog=json.loads(load('verification/TEST_CATALOG.json'))['cases']
check('280 planned test cases',len(catalog)==280)
check('unique test IDs',len(set(x['test_id'] for x in catalog))==len(catalog))
check('all planned NOT_RUN',all(x['status']=='NOT_RUN' for x in catalog))
for p in range(14):
 for s in range(1,6):
  sid=f'RG{p:02d}-S{s:02d}'
  check('4 test cases '+sid,sum(x['sprint']==sid for x in catalog)==4)

# DAG sanity extracted from package-authoritative phase definitions.
phase_re=re.compile(r'\*\*Depends on:\*\* (.+)  ')
deps={}
for p in phase_files:
 m=phase_re.search(load(str(p.relative_to(BASE))))
 check('dependency defined '+p.name,bool(m))
 if m:
  label='RG'+p.stem[-2:]
  deps[label]=set([] if m.group(1)=='none' else m.group(1).split(', '))
for node,values in deps.items():
 for v in values:check('valid upstream '+node+' '+v,v in deps and int(v[2:])<int(node[2:]))

check('README native phase', '@generation_baseline/prompts/prompt-phase-00.md' in load('README.md'))
check('README native sprint', '@generation_baseline/prompts/sprints/prompt-sprint-03-01.md' in load('README.md'))
check('agent pipeline present', 'Autonomous internal pipeline' in load('AGENT_PIPELINE.md'))
check('no old third-party skills', all(x not in p.read_text(encoding='utf8') for p in BASE.rglob('*.md') for x in ['/brainstorming', '/my_plan_skill', '/my_implement_skill', 'superpowers']))
check('no old skill in package', all('/my_'+'plan_skill' not in p.read_text(encoding='utf8') and '/my_'+'implement_skill' not in p.read_text(encoding='utf8') for p in BASE.rglob('*.md')))
report={'package':'generation_baseline','version':'4.0','scope':'OFFLINE_ONLY','checks':checks,'passed':checks-len(issues),'failed':len(issues),'failures':issues,'source_repo_verified':False,'live_provider_tests':'NOT_RUN','db_integration_tests':'NOT_RUN','scientific_campaign':'NOT_RUN','all_implementation_gates':'NOT_RUN'}
(BASE/'verification/PACKAGE_VALIDATION_REPORT.json').write_text(json.dumps(report,indent=2)+chr(10),encoding='utf8')
print(f'Offline package checks: {checks-len(issues)}/{checks} PASS')
for issue in issues[:30]:print('FAIL:',issue)
sys.exit(0 if not issues else 1)
