#!/usr/bin/env python3
"""Generate declarative RG10 batch specifications from an already frozen assignment manifest.
This tool does NOT execute any provider calls, modify the frozen input or access secrets.
Input JSON must contain: {"dataset_version":..., "assignments":[{"assignment_id":...,
"dataset_item_id":..., "configuration_id":"A|B|C", "domain":"READING|GRAMMAR"}]}
"""
import argparse, json, hashlib
from pathlib import Path

def main():
    p=argparse.ArgumentParser()
    p.add_argument('--manifest',required=True)
    p.add_argument('--output-dir',required=True)
    p.add_argument('--max-items-per-batch',type=int,default=5)
    a=p.parse_args()
    if not 1<=a.max_items_per_batch<=5: p.error('max-items-per-batch must be 1..5')
    raw=Path(a.manifest).read_bytes(); manifest=json.loads(raw)
    if manifest.get('freeze_status')!='FROZEN' or manifest.get('split')!='FINAL_EVAL':
        raise ValueError('Only FROZEN FINAL_EVAL manifest is eligible for batch specifications')
    rows=manifest['assignments']; seen=set(); grouped={}
    for row in rows:
        rid=row['assignment_id']; item=row['dataset_item_id']; arm=row['configuration_id']; domain=row['domain']
        if domain not in ('READING','GRAMMAR') or arm not in ('A','B','C'):raise ValueError('Invalid arm/domain')
        if rid in seen:raise ValueError('Duplicate assignment ID')
        seen.add(rid);grouped.setdefault(domain,{}).setdefault(item,[]).append(row)
    for domain,items in grouped.items():
        for item,rr in items.items():
            if sorted(r['configuration_id'] for r in rr)!=['A','B','C']:raise ValueError(f'Missing or extra A/B/C arms for {item}')
    out=Path(a.output_dir);out.mkdir(parents=True,exist_ok=True)
    digest=hashlib.sha256(raw).hexdigest()
    count=0
    for domain,items in sorted(grouped.items()):
        ordered=sorted(items)
        for pos in range(0,len(ordered),a.max_items_per_batch):
            chunk=ordered[pos:pos+a.max_items_per_batch];index=pos//a.max_items_per_batch+1
            bids=[r['assignment_id'] for item in chunk for r in items[item]]
            text=(f'# RG10 — {domain} frozen research batch {index:02d}\n\n'
                  f'**Source manifest SHA-256:** `{digest}`\n\n'
                  f'**Dataset version:** `{manifest["dataset_version"]}`\n\n'
                  f'**Unit:** up to {a.max_items_per_batch} frozen dataset items with A/B/C arm assignments.\n\n'
                  '## Assigned IDs (immutable)\n\n'+'\n'.join(f'- `{b}`' for b in bids)+
                  '\n\n## Acceptance requirements\n\n'
                  '- Every listed assignment has one reconciled final outcome with retry lineage.\n'
                  '- Failures, partials, external evaluator status, token/usage confidence and elapsed time are retained.\n'
                  '- No replacement item, modified model/prompt, omitted failed row, fabricated PASS or silent rescore.\n'
                  '- This document specifies batch membership only and does not authorize live execution.\n')
            (out/f'RG10-{domain.lower()}-batch-{index:02d}.md').write_text(text,encoding='utf-8');count+=1
    print(f'{count} frozen batch specs created; manifest SHA-256: {digest}')
if __name__=='__main__':main()
