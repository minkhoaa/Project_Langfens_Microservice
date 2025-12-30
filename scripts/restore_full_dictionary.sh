#!/bin/bash
# ============================================
# Dictionary Elasticsearch Restore Script
# For Azure Server Deployment
# ============================================
#
# This script restores the dictionary data exported from local machine
# Run this on the Azure server after copying the data files
#
# Requirements:
#   - Docker installed
#   - dictionary_full_mapping.json 
#   - dictionary_full_data.json.gz
#
# Usage:
#   ./restore_full_dictionary.sh
#   ./restore_full_dictionary.sh http://localhost:9200  # custom ES URL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"

ES_URL="${1:-http://localhost:9200}"
INDEX="dictionary_v1"
ALIAS="dictionary_current"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "Dictionary Elasticsearch Restore Script"
echo "========================================"
echo ""

# 1. Check Elasticsearch connection
echo "1️⃣  Checking Elasticsearch connection..."
if ! curl -s "${ES_URL}" > /dev/null 2>&1; then
    echo -e "${RED}❌ Cannot connect to Elasticsearch at ${ES_URL}${NC}"
    echo "   Make sure Elasticsearch is running"
    exit 1
fi
echo -e "${GREEN}✅ Elasticsearch is running${NC}"

# 2. Check required files
echo ""
echo "2️⃣  Checking required files..."
if [[ ! -f "dictionary_full_mapping.json" ]]; then
    echo -e "${RED}❌ Missing: dictionary_full_mapping.json${NC}"
    exit 1
fi
if [[ ! -f "dictionary_full_data.json.gz" ]]; then
    echo -e "${RED}❌ Missing: dictionary_full_data.json.gz${NC}"
    exit 1
fi
echo -e "${GREEN}✅ All required files found${NC}"

# 3. Decompress data file
echo ""
echo "3️⃣  Decompressing data file..."
if [[ -f "dictionary_full_data.json" ]]; then
    echo -e "${YELLOW}   File already decompressed, skipping...${NC}"
else
    gunzip -k dictionary_full_data.json.gz
    echo "   Decompressed: dictionary_full_data.json"
fi
SIZE=$(du -h dictionary_full_data.json | cut -f1)
echo "   File size: ${SIZE}"

# 4. Delete existing index
echo ""
echo "4️⃣  Deleting existing index (if any)..."
curl -s -X DELETE "${ES_URL}/${INDEX}" > /dev/null 2>&1 || true
sleep 2

# 5. Create index with mapping
echo ""
echo "5️⃣  Creating index with mapping..."
docker run --rm -v "${SCRIPT_DIR}:/data" --net=host \
    elasticdump/elasticsearch-dump \
    --input=/data/dictionary_full_mapping.json \
    --output="${ES_URL}/${INDEX}" \
    --type=mapping

# 6. Import data (this takes 10-30 minutes)
echo ""
echo "6️⃣  Importing data (1.4M records, may take 20-40 minutes)..."
echo "   Started at: $(date)"
docker run --rm -v "${SCRIPT_DIR}:/data" --net=host \
    elasticdump/elasticsearch-dump \
    --input=/data/dictionary_full_data.json \
    --output="${ES_URL}/${INDEX}" \
    --type=data \
    --limit=10000

echo "   Finished at: $(date)"

# 7. Create alias
echo ""
echo "7️⃣  Creating alias ${ALIAS} -> ${INDEX}..."
curl -s -X POST "${ES_URL}/_aliases" \
    -H "Content-Type: application/json" \
    -d "{\"actions\":[{\"remove\":{\"index\":\"*\",\"alias\":\"${ALIAS}\"}},{\"add\":{\"index\":\"${INDEX}\",\"alias\":\"${ALIAS}\"}}]}" > /dev/null 2>&1 || \
curl -s -X POST "${ES_URL}/_aliases" \
    -H "Content-Type: application/json" \
    -d "{\"actions\":[{\"add\":{\"index\":\"${INDEX}\",\"alias\":\"${ALIAS}\"}}]}"

# 8. Refresh and verify
echo ""
echo "8️⃣  Refreshing index..."
curl -s -X POST "${ES_URL}/${INDEX}/_refresh" > /dev/null

echo ""
echo "========================================"
COUNT=$(curl -s "${ES_URL}/${INDEX}/_count" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
echo -e "${GREEN}✅ Restore complete!${NC}"
echo "   Total documents: ${COUNT}"
echo "   Index: ${INDEX}"
echo "   Alias: ${ALIAS}"
echo "========================================"

# Test search
echo ""
echo "Testing search for 'hello'..."
RESULT=$(curl -s "${ES_URL}/${INDEX}/_search?q=word:hello&size=1" | grep -o '"word":"hello"' || echo "")
if [[ -n "$RESULT" ]]; then
    echo -e "${GREEN}✅ Search test passed${NC}"
else
    echo -e "${YELLOW}⚠️  Search test returned no results${NC}"
fi
