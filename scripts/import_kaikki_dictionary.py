#!/usr/bin/env python3
"""
Import Kaikki.org English dictionary into Elasticsearch
Source: https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl
Size: ~2.8GB, ~1M+ entries
"""
import json
import sys
import os
from datetime import datetime
from elasticsearch import Elasticsearch
from elasticsearch.helpers import bulk, streaming_bulk
import gzip
from pathlib import Path

# Config
ES_URL = os.getenv("ELASTICSEARCH_URL", "http://localhost:9200")
INDEX = "dictionary_v1"
BATCH_SIZE = 1000
DATA_FILE = "data/kaikki.org-dictionary-English.jsonl"

def create_index(es: Elasticsearch):
    """Create index with mapping if not exists"""
    mapping = {
        "settings": {
            "index": {
                "mapping": {"total_fields": {"limit": 2000}},
                "refresh_interval": "30s"  # Faster bulk import
            }
        },
        "mappings": {
            "dynamic": False,
            "properties": {
                "id": {"type": "long"},
                "word": {"type": "keyword"},
                "wordNorm": {"type": "search_as_you_type"},
                "pos": {"type": "keyword"},
                "importedAt": {"type": "date"},
                "data": {"type": "object", "enabled": False}
            }
        }
    }
    
    if not es.indices.exists(index=INDEX):
        es.indices.create(index=INDEX, body=mapping)
        print(f"✅ Created index: {INDEX}")
    else:
        print(f"ℹ️  Index {INDEX} already exists")

def generate_actions(filepath: str):
    """Generator for bulk actions from JSONL file"""
    doc_id = 0
    imported_at = datetime.utcnow().isoformat()
    
    with open(filepath, 'r', encoding='utf-8') as f:
        for line in f:
            try:
                entry = json.loads(line.strip())
                if not entry:
                    continue
                    
                word = entry.get("word", "")
                pos = entry.get("pos", "unknown")
                
                if not word:
                    continue
                
                doc_id += 1
                
                yield {
                    "_index": INDEX,
                    "_id": str(doc_id),
                    "_source": {
                        "id": doc_id,
                        "word": word,
                        "wordNorm": word.lower(),
                        "pos": pos,
                        "importedAt": imported_at,
                        "data": entry
                    }
                }
                
                if doc_id % 50000 == 0:
                    print(f"  Processed {doc_id:,} entries...")
                    
            except json.JSONDecodeError:
                continue

def import_dictionary(filepath: str, clear_first: bool = False):
    """Import dictionary data into Elasticsearch"""
    print(f"🔗 Connecting to Elasticsearch: {ES_URL}")
    es = Elasticsearch([ES_URL])
    
    if not es.ping():
        print("❌ Cannot connect to Elasticsearch!")
        sys.exit(1)
    
    print(f"✅ Connected to Elasticsearch")
    
    # Create index
    create_index(es)
    
    # Clear existing data if requested
    if clear_first:
        print("🗑️  Clearing existing data...")
        es.delete_by_query(
            index=INDEX,
            body={"query": {"match_all": {}}},
            refresh=True
        )
    
    # Optimize for bulk import
    print("⚙️  Optimizing index for bulk import...")
    es.indices.put_settings(index=INDEX, body={
        "index": {"refresh_interval": "-1", "number_of_replicas": 0}
    })
    
    # Bulk import
    print(f"📥 Importing from: {filepath}")
    print("   This may take 10-30 minutes for 1M+ entries...")
    
    success_count = 0
    error_count = 0
    
    for ok, result in streaming_bulk(
        es,
        generate_actions(filepath),
        chunk_size=BATCH_SIZE,
        raise_on_error=False
    ):
        if ok:
            success_count += 1
        else:
            error_count += 1
            if error_count < 10:
                print(f"  Error: {result}")
    
    # Restore normal settings
    print("⚙️  Restoring normal index settings...")
    es.indices.put_settings(index=INDEX, body={
        "index": {"refresh_interval": "1s"}
    })
    
    # Refresh index
    print("🔄 Refreshing index...")
    es.indices.refresh(index=INDEX)
    
    # Count docs
    count = es.count(index=INDEX)["count"]
    
    print()
    print("=" * 50)
    print(f"✅ Import complete!")
    print(f"   Successful: {success_count:,}")
    print(f"   Errors: {error_count:,}")
    print(f"   Total in index: {count:,}")
    print("=" * 50)

def download_kaikki():
    """Download the Kaikki.org dictionary file"""
    import urllib.request
    
    url = "https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl"
    output = DATA_FILE
    
    os.makedirs(os.path.dirname(output), exist_ok=True)
    
    if os.path.exists(output):
        size_gb = os.path.getsize(output) / (1024**3)
        print(f"ℹ️  File already exists: {output} ({size_gb:.2f} GB)")
        return output
    
    print(f"📥 Downloading from: {url}")
    print("   This will take 10-30 minutes (2.8 GB)...")
    
    def progress_hook(count, block_size, total_size):
        percent = int(count * block_size * 100 / total_size)
        downloaded_mb = count * block_size / (1024**2)
        total_mb = total_size / (1024**2)
        sys.stdout.write(f"\r   Progress: {percent}% ({downloaded_mb:.0f}/{total_mb:.0f} MB)")
        sys.stdout.flush()
    
    urllib.request.urlretrieve(url, output, progress_hook)
    print()
    print(f"✅ Downloaded to: {output}")
    return output

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Import Kaikki.org dictionary to Elasticsearch")
    parser.add_argument("--download", action="store_true", help="Download the dictionary file first")
    parser.add_argument("--clear", action="store_true", help="Clear existing data before import")
    parser.add_argument("--file", default=DATA_FILE, help="Path to JSONL file")
    parser.add_argument("--es-url", default=ES_URL, help="Elasticsearch URL")
    args = parser.parse_args()
    
    if args.es_url:
        ES_URL = args.es_url
    
    if args.download:
        args.file = download_kaikki()
    
    if not os.path.exists(args.file):
        print(f"❌ File not found: {args.file}")
        print("   Run with --download to download the file first")
        sys.exit(1)
    
    import_dictionary(args.file, clear_first=args.clear)
