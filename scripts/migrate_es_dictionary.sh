#!/bin/bash
# ============================================
# Dictionary Elasticsearch Migration Script
# ============================================
# 
# Workflow:
#   1. Local: Download + Import kaikki.org data
#   2. Local: Export using elasticdump
#   3. Copy to server
#   4. Server: Import dump
#
# Usage:
#   ./migrate_es_dictionary.sh download   # Download kaikki.org file
#   ./migrate_es_dictionary.sh import     # Import to local ES
#   ./migrate_es_dictionary.sh export     # Export from local ES
#   ./migrate_es_dictionary.sh copy       # Copy to server
#   ./migrate_es_dictionary.sh restore    # Restore on server
#   ./migrate_es_dictionary.sh all        # Full pipeline

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/data"
KAIKKI_URL="https://kaikki.org/dictionary/English/kaikki.org-dictionary-English.jsonl"
KAIKKI_FILE="${DATA_DIR}/kaikki.org-dictionary-English.jsonl"

# Elasticsearch
LOCAL_ES="http://localhost:9200"
INDEX="dictionary_v1"

# Server info - EDIT THESE
SERVER_USER="azureuser"
SERVER_HOST="20.193.253.180"
SERVER_ES="http://localhost:9200"
REMOTE_DIR="/home/azureuser/DeployProjects/Project_Langfens_Microservice/scripts/data"
SSH_KEY="/home/khoa/Key/langfens_key.pem"  # Path to your SSH private key

# SSH/SCP options with key
SSH_OPTS="-i ${SSH_KEY} -o StrictHostKeyChecking=no"

# Export files
MAPPING_FILE="${DATA_DIR}/dictionary_mapping.json"
DATA_FILE="${DATA_DIR}/dictionary_data.json"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_step() { echo -e "${CYAN}[STEP]${NC} $1"; }

# ============================================
# STEP 1: Download kaikki.org dictionary (MULTI-THREADED)
# ============================================
download_kaikki() {
    log_step "Downloading kaikki.org English dictionary (multi-threaded)..."
    mkdir -p "${DATA_DIR}"
    
    if [[ -f "${KAIKKI_FILE}" ]]; then
        SIZE=$(du -h "${KAIKKI_FILE}" | cut -f1)
        log_warn "File already exists: ${KAIKKI_FILE} (${SIZE})"
        read -p "Re-download? (y/N): " confirm
        [[ "$confirm" != "y" ]] && return
        rm -f "${KAIKKI_FILE}"
    fi
    
    log_info "Downloading from: ${KAIKKI_URL}"
    log_info "Using aria2c with 16 parallel connections..."
    log_info "File size: ~2.8 GB"
    
    # Use aria2c for multi-threaded download
    aria2c \
        --max-connection-per-server=16 \
        --split=16 \
        --min-split-size=10M \
        --file-allocation=none \
        --continue=true \
        --dir="${DATA_DIR}" \
        --out="$(basename ${KAIKKI_FILE})" \
        "${KAIKKI_URL}"
    
    SIZE=$(du -h "${KAIKKI_FILE}" | cut -f1)
    LINES=$(wc -l < "${KAIKKI_FILE}")
    log_info "Download complete: ${SIZE}, ${LINES} entries"
}

# ============================================
# STEP 2: Import to local Elasticsearch
# ============================================
import_local() {
    log_step "Importing to local Elasticsearch..."
    
    if [[ ! -f "${KAIKKI_FILE}" ]]; then
        log_error "File not found: ${KAIKKI_FILE}"
        log_info "Run: $0 download"
        exit 1
    fi
    
    # Check ES is running
    if ! curl -s "${LOCAL_ES}" > /dev/null; then
        log_error "Elasticsearch not running at ${LOCAL_ES}"
        exit 1
    fi
    
    # Check if Python script exists
    if [[ ! -f "${SCRIPT_DIR}/import_kaikki_dictionary.py" ]]; then
        log_error "Python script not found!"
        exit 1
    fi
    
    # Run Python import script
    log_info "Running Python import script..."
    python3 "${SCRIPT_DIR}/import_kaikki_dictionary.py" \
        --file "${KAIKKI_FILE}" \
        --clear \
        --es-url "${LOCAL_ES}"
    
    # Verify
    COUNT=$(curl -s "${LOCAL_ES}/${INDEX}/_count" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    log_info "Import complete! ${COUNT} documents in ${INDEX}"
}

# ============================================
# STEP 3: Export using elasticdump
# ============================================
export_local() {
    log_step "Exporting from local Elasticsearch..."
    mkdir -p "${DATA_DIR}"
    
    # Check ES
    if ! curl -s "${LOCAL_ES}" > /dev/null; then
        log_error "Elasticsearch not running at ${LOCAL_ES}"
        exit 1
    fi
    
    COUNT=$(curl -s "${LOCAL_ES}/${INDEX}/_count" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
    log_info "Index ${INDEX} has ${COUNT} documents"
    
    # Export mapping
    log_info "Exporting mapping..."
    elasticdump \
        --input="${LOCAL_ES}/${INDEX}" \
        --output="${MAPPING_FILE}" \
        --type=mapping
    
    # Export data (with gzip compression for faster transfer)
    log_info "Exporting data (this may take 5-10 minutes)..."
    elasticdump \
        --input="${LOCAL_ES}/${INDEX}" \
        --output="${DATA_FILE}" \
        --type=data \
        --limit=10000
    
    # Compress data file
    log_info "Compressing data file..."
    gzip -f "${DATA_FILE}"
    
    SIZE_MAPPING=$(du -h "${MAPPING_FILE}" | cut -f1)
    SIZE_DATA=$(du -h "${DATA_FILE}.gz" | cut -f1)
    
    log_info "Export complete!"
    log_info "  Mapping: ${MAPPING_FILE} (${SIZE_MAPPING})"
    log_info "  Data: ${DATA_FILE}.gz (${SIZE_DATA})"
}

# ============================================
# STEP 4: Copy to server
# ============================================
copy_to_server() {
    log_step "Copying to server ${SERVER_HOST}..."
    
    if [[ ! -f "${MAPPING_FILE}" ]] || [[ ! -f "${DATA_FILE}.gz" ]]; then
        log_error "Export files not found. Run: $0 export"
        exit 1
    fi
    
    # Create remote directory
    log_info "Creating remote directory..."
    ssh ${SSH_OPTS} "${SERVER_USER}@${SERVER_HOST}" "mkdir -p ${REMOTE_DIR}"
    
    # Copy files
    log_info "Copying mapping file..."
    scp ${SSH_OPTS} "${MAPPING_FILE}" "${SERVER_USER}@${SERVER_HOST}:${REMOTE_DIR}/"
    
    log_info "Copying data file (may take a while)..."
    scp ${SSH_OPTS} "${DATA_FILE}.gz" "${SERVER_USER}@${SERVER_HOST}:${REMOTE_DIR}/"
    
    # Copy restore script
    log_info "Copying restore script..."
    cat > /tmp/restore_dictionary.sh << 'RESTORE_SCRIPT'
#!/bin/bash
set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "${SCRIPT_DIR}"

ES_URL="${1:-http://elasticsearch:9200}"
INDEX="dictionary_v1"

echo "========================================"
echo "Dictionary Elasticsearch Restore Script"
echo "========================================"

# Check Elasticsearch is running
echo "Checking Elasticsearch connection..."
if ! curl -s "${ES_URL}" > /dev/null 2>&1; then
    echo "❌ Cannot connect to Elasticsearch at ${ES_URL}"
    exit 1
fi
echo "✅ Elasticsearch is running"

# Decompress data file
echo ""
echo "1️⃣ Decompressing data file..."
if [[ -f "dictionary_data.json.gz" ]]; then
    gunzip -k -f dictionary_data.json.gz
    echo "   Decompressed: dictionary_data.json"
else
    echo "   File already decompressed or doesn't exist"
fi

# Delete existing index
echo ""
echo "2️⃣ Deleting existing index..."
curl -s -X DELETE "${ES_URL}/${INDEX}" || true
sleep 2

# Create index with mapping
echo ""
echo "3️⃣ Creating index with mapping..."
elasticdump \
    --input=dictionary_mapping.json \
    --output="${ES_URL}/${INDEX}" \
    --type=mapping

# Import data
echo ""
echo "4️⃣ Importing data (this may take 10-20 minutes)..."
elasticdump \
    --input=dictionary_data.json \
    --output="${ES_URL}/${INDEX}" \
    --type=data \
    --limit=10000

# Refresh index for immediate searchability
echo ""
echo "5️⃣ Refreshing index for reindexing..."
curl -s -X POST "${ES_URL}/${INDEX}/_refresh"

# Verify
echo ""
echo "========================================"
COUNT=$(curl -s "${ES_URL}/${INDEX}/_count" | grep -o '"count":[0-9]*' | grep -o '[0-9]*')
echo "✅ Restore complete! ${COUNT} documents in ${INDEX}"
echo "========================================"
RESTORE_SCRIPT
    
    scp ${SSH_OPTS} /tmp/restore_dictionary.sh "${SERVER_USER}@${SERVER_HOST}:${REMOTE_DIR}/"
    ssh ${SSH_OPTS} "${SERVER_USER}@${SERVER_HOST}" "chmod +x ${REMOTE_DIR}/restore_dictionary.sh"
    
    log_info "Files copied to server!"
    log_info ""
    log_info "To restore on server, run:"
    log_info "  ssh ${SERVER_USER}@${SERVER_HOST}"
    log_info "  cd ${REMOTE_DIR}"
    log_info "  npm install -g elasticdump  # if not installed"
    log_info "  ./restore_dictionary.sh http://elasticsearch:9200"
}

# ============================================
# STEP 5: Restore on server (run via SSH)
# ============================================
restore_server() {
    log_step "Restoring on server..."
    
    ssh ${SSH_OPTS} -t "${SERVER_USER}@${SERVER_HOST}" "cd ${REMOTE_DIR} && ./restore_dictionary.sh ${SERVER_ES}"
}

# ============================================
# ALL: Full pipeline
# ============================================
run_all() {
    log_step "Running full migration pipeline..."
    echo ""
    
    download_kaikki
    echo ""
    
    import_local
    echo ""
    
    export_local
    echo ""
    
    copy_to_server
    echo ""
    
    log_info "✅ All local steps complete!"
    log_info ""
    log_info "To finish, run on server:"
    log_info "  ssh ${SERVER_USER}@${SERVER_HOST}"
    log_info "  cd ${REMOTE_DIR}"
    log_info "  ./restore_dictionary.sh"
}

# ============================================
# STATUS: Check current state
# ============================================
status() {
    log_step "Checking status..."
    
    echo ""
    echo "Files:"
    [[ -f "${KAIKKI_FILE}" ]] && echo "  ✅ Kaikki.org file: $(du -h "${KAIKKI_FILE}" | cut -f1)" || echo "  ❌ Kaikki.org file: not found"
    [[ -f "${MAPPING_FILE}" ]] && echo "  ✅ Mapping export: $(du -h "${MAPPING_FILE}" | cut -f1)" || echo "  ❌ Mapping export: not found"
    [[ -f "${DATA_FILE}.gz" ]] && echo "  ✅ Data export: $(du -h "${DATA_FILE}.gz" | cut -f1)" || echo "  ❌ Data export: not found"
    
    echo ""
    echo "Elasticsearch (local):"
    if curl -s "${LOCAL_ES}" > /dev/null 2>&1; then
        COUNT=$(curl -s "${LOCAL_ES}/${INDEX}/_count" 2>/dev/null | grep -o '"count":[0-9]*' | grep -o '[0-9]*' || echo "0")
        echo "  ✅ Running at ${LOCAL_ES}"
        echo "  📊 Index ${INDEX}: ${COUNT} documents"
    else
        echo "  ❌ Not running at ${LOCAL_ES}"
    fi
}

# ============================================
# MAIN
# ============================================
case "${1:-help}" in
    download)
        download_kaikki
        ;;
    import)
        import_local
        ;;
    export)
        export_local
        ;;
    copy)
        copy_to_server
        ;;
    restore)
        restore_server
        ;;
    all)
        run_all
        ;;
    status)
        status
        ;;
    *)
        echo "Usage: $0 {download|import|export|copy|restore|all|status}"
        echo ""
        echo "Commands:"
        echo "  download  - Download kaikki.org dictionary (2.8 GB)"
        echo "  import    - Import into local Elasticsearch"
        echo "  export    - Export from local ES using elasticdump"
        echo "  copy      - Copy export files to server"
        echo "  restore   - Restore on server via SSH"
        echo "  all       - Run full pipeline (download → import → export → copy)"
        echo "  status    - Check current state"
        exit 1
        ;;
esac
