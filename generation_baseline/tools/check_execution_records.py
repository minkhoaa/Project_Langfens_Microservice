#!/usr/bin/env python3
"""Validate local phase/sprint evidence metadata shape; does NOT verify code test truth."""
import argparse,json,re,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
p=argparse.ArgumentParser();p.add_argument('--phase',required=True,help='RG00..RG13');args=p.parse_args()
phase=args.phase
if not re.fullmatch(r'RG(0[0-9]|1[0-3])',phase):p.error('invalid phase')
folder=root/'.execution'/phase
errors=[]
sp={}
allowed={'NOT_RUN','TARGET_SPEC','UNKNOWN','PARTIAL','BLOCKED','FAILED','PASS','VERIFIED'}
for n in range(1,6):
 sid=f'{phase}-S{n:02d}';f=folder/f'{sid}.json'
 if not f.exists():errors.append(f'{sid} missing status file');continue
 try:r=json.loads(f.read_text())
 except Exception as e:errors.append(f'{sid} invalid JSON: {e}');continue
 if r.get('sprint_id')!=sid or r.get('phase_id')!=phase:errors.append(f'{sid} ID mismatch')
 if r.get('status') not in allowed:errors.append(f'{sid} invalid status')
 if r.get('status')=='PASS':
  if not r.get('source_sha'):errors.append(f'{sid} PASS missing source_sha')
  e=r.get('evidence') or {}
  if not e.get('tests') and not e.get('report_refs'):errors.append(f'{sid} PASS missing evidence references')
 sp[f'S{n:02d}']=r.get('status')
phasefile=folder/'PHASE_STATUS.json'
if phasefile.exists():
 try:
  pr=json.loads(phasefile.read_text())
  if pr.get('phase_id')!=phase:errors.append('phase ID mismatch')
  if pr.get('status')=='PASS' and (any(v!='PASS' for v in sp.values()) or len(sp)!=5 or not pr.get('phase_tests')):errors.append('phase PASS lacks 5 sprint PASS + phase tests')
 except Exception as e:errors.append(f'phase invalid JSON: {e}')
else:errors.append('PHASE_STATUS.json missing')
print(f'{phase}: metadata checks {"PASS" if not errors else "FAILED"} (only structure, not verified external evidence)')
for e in errors:print(' -',e)
sys.exit(bool(errors))
