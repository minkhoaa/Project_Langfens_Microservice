#!/bin/bash
# ============================================
# Dictionary Service Data Migration Script
# ============================================
# 
# Purpose: Export PostgreSQL data from local and import to production server
# Also triggers Elasticsearch re-indexing
#
# Usage:
#   ./migrate_dictionary.sh export   # Export từ local
#   ./migrate_dictionary.sh import   # Import trên server
#
# Prerequisites:
#   - Docker running
#   - Local: dictionary-database container running
#   - Server: SSH access configured

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_FILE="${SCRIPT_DIR}/dictionary_backup.sql"
COMPOSE_DIR="${SCRIPT_DIR}/../deploy"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================
# EXPORT: Chạy trên local
# ============================================
export_data() {
    log_info "Exporting dictionary data from local..."
    
    cd "${COMPOSE_DIR}"
    
    # Check container running
    if ! docker compose ps dictionary-database | grep -q "running"; then
        log_error "dictionary-database container not running!"
        log_info "Run: docker compose up -d dictionary-database"
        exit 1
    fi
    
    # Export with pg_dump
    log_info "Running pg_dump..."
    docker compose exec -T dictionary-database pg_dump \
        -U dictionary \
        -d dictionary-db \
        --data-only \
        --table=dictionary \
        --column-inserts \
        > "${BACKUP_FILE}"
    
    ROWS=$(grep -c "^INSERT INTO" "${BACKUP_FILE}" || echo "0")
    SIZE=$(du -h "${BACKUP_FILE}" | cut -f1)
    
    log_info "Export complete!"
    log_info "  File: ${BACKUP_FILE}"
    log_info "  Size: ${SIZE}"
    log_info "  Rows: ${ROWS}"
    
    echo ""
    log_info "Next steps:"
    echo "  1. Copy to server: scp ${BACKUP_FILE} user@server:/tmp/"
    echo "  2. On server, run: ./migrate_dictionary.sh import"
}

# ============================================
# IMPORT: Chạy trên server
# ============================================
import_data() {
    log_info "Importing dictionary data to production..."
    
    # Check backup file exists
    if [[ ! -f "${BACKUP_FILE}" ]] && [[ ! -f "/tmp/dictionary_backup.sql" ]]; then
        log_error "Backup file not found!"
        log_info "Expected: ${BACKUP_FILE} or /tmp/dictionary_backup.sql"
        exit 1
    fi
    
    # Use /tmp if script's backup not available
    [[ ! -f "${BACKUP_FILE}" ]] && BACKUP_FILE="/tmp/dictionary_backup.sql"
    
    cd "${COMPOSE_DIR}"
    
    # Check container running
    if ! docker compose ps dictionary-database | grep -q "running"; then
        log_error "dictionary-database container not running!"
        exit 1
    fi
    
    # Clear existing data (optional - comment out if you want to merge)
    log_warn "Clearing existing dictionary data..."
    docker compose exec -T dictionary-database psql \
        -U dictionary \
        -d dictionary-db \
        -c "TRUNCATE TABLE dictionary RESTART IDENTITY CASCADE;"
    
    # Import data
    log_info "Importing data..."
    docker compose exec -T dictionary-database psql \
        -U dictionary \
        -d dictionary-db \
        < "${BACKUP_FILE}"
    
    # Count imported rows
    ROWS=$(docker compose exec -T dictionary-database psql \
        -U dictionary \
        -d dictionary-db \
        -t -c "SELECT COUNT(*) FROM dictionary;" | xargs)
    
    log_info "Import complete! ${ROWS} rows imported."
    
    # Trigger Elasticsearch re-index
    log_info "Triggering Elasticsearch re-index..."
    reindex_elasticsearch
}

# ============================================
# ELASTICSEARCH RE-INDEX
# ============================================
reindex_elasticsearch() {
    log_info "Re-indexing Elasticsearch..."
    
    # Call the dictionary-service reindex endpoint if available
    # Or restart the service to trigger auto-index
    cd "${COMPOSE_DIR}"
    
    # Option 1: Restart dictionary-service (auto-indexes on startup)
    log_info "Restarting dictionary-service to trigger re-index..."
    docker compose restart dictionary-service
    
    # Wait for service to be healthy
    log_info "Waiting for dictionary-service to be ready..."
    sleep 10
    
    # Verify Elasticsearch has data
    ES_COUNT=$(curl -s "http://localhost:9200/dictionary/_count" 2>/dev/null | grep -o '"count":[0-9]*' | grep -o '[0-9]*' || echo "0")
    
    if [[ "${ES_COUNT}" -gt 0 ]]; then
        log_info "Elasticsearch indexed: ${ES_COUNT} documents"
    else
        log_warn "Elasticsearch may not have indexed yet. Check dictionary-service logs."
    fi
    
    log_info "Migration complete! ✅"
}

# ============================================
# MAIN
# ============================================
case "${1:-help}" in
    export)
        export_data
        ;;
    import)
        import_data
        ;;
    reindex)
        reindex_elasticsearch
        ;;
    *)
        echo "Usage: $0 {export|import|reindex}"
        echo ""
        echo "Commands:"
        echo "  export   - Export dictionary data from local PostgreSQL"
        echo "  import   - Import dictionary data to production PostgreSQL + reindex ES"
        echo "  reindex  - Only trigger Elasticsearch re-indexing"
        exit 1
        ;;
esac
