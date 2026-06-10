#!/usr/bin/env bash
# =============================================================================
# Dictionary Seed — convenience wrapper
# =============================================================================
#
# Re-seeds the dictionary-db (PostgreSQL) from the Kaikki Wiktionary JSONL
# already on disk under data/. This is the "run it later" script — it
# assumes the project is set up (PostgreSQL running on 5443, wordlist and
# kaikki JSONL present) and just invokes scripts/seed_dictionary.py with
# sensible defaults.
#
# Usage:
#   ./scripts/seed_dictionary_lite.sh                # full seed (~50s once warmed)
#   ./scripts/seed_dictionary_lite.sh --limit 1000   # dry run, 1000 rows
#   ./scripts/seed_dictionary_lite.sh --skip-truncate  # resume an interrupted run
#   ./scripts/seed_dictionary_lite.sh --check        # verify DB + files, no insert
#   DICT_DSN="host=... port=..." ./scripts/seed_dictionary_lite.sh
#
# Environment:
#   DICT_DSN          psql connection string (default: localhost:5443)
#   DATA_DIR          data directory (default: ./data relative to repo root)
#   PSQL              psql binary (default: psql)
#
# Exit codes:
#   0  success
#   1  prerequisites failed (data files missing, DB unreachable)
#   2  seeder script itself failed
# =============================================================================
set -euo pipefail

# Resolve repo root (this script lives in scripts/).
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

# --- Defaults ----------------------------------------------------------------
DATA_DIR="${DATA_DIR:-${REPO_ROOT}/data}"
KAIKKI_PATH="${DATA_DIR}/kaikki.org-dictionary-English.jsonl"
WORDS_PATH="${DATA_DIR}/english-100k.txt"
DICT_DSN="${DICT_DSN:-host=localhost port=5443 dbname=dictionary-db user=dictionary password=dictionary}"
PYTHON="${PYTHON:-python3}"

# --- Colors ------------------------------------------------------------------
if [[ -t 1 ]]; then
  C_OK="\033[1;32m"; C_WARN="\033[1;33m"; C_ERR="\033[1;31m"; C_OFF="\033[0m"
else
  C_OK=""; C_WARN=""; C_ERR=""; C_OFF=""
fi
log()  { echo -e "${C_OK}[seed]${C_OFF} $*"; }
warn() { echo -e "${C_WARN}[seed]${C_OFF} $*"; }
err()  { echo -e "${C_ERR}[seed]${C_OFF} $*" >&2; }

# --- Pre-flight: --check mode -------------------------------------------------
run_check() {
  local fail=0
  log "Pre-flight check"

  if ! command -v "${PYTHON}" >/dev/null 2>&1; then
    err "python3 not found (set PYTHON to override)"; fail=1
  else
    log "  python3:  $($PYTHON --version)"
  fi

  if ! command -v psql >/dev/null 2>&1; then
    err "psql not found in PATH"; fail=1
  else
    log "  psql:     $(psql --version)"
  fi

  if [[ -f "${WORDS_PATH}" ]]; then
    log "  wordlist: ${WORDS_PATH} ($(wc -l < "${WORDS_PATH}") lines, $(du -h "${WORDS_PATH}" | cut -f1))"
  else
    err "wordlist missing: ${WORDS_PATH}"; fail=1
  fi

  if [[ -f "${KAIKKI_PATH}" ]]; then
    log "  kaikki:   ${KAIKKI_PATH} ($(du -h "${KAIKKI_PATH}" | cut -f1))"
  else
    err "kaikki jsonl missing: ${KAIKKI_PATH}"; fail=1
  fi

  if PGPASSWORD="$(echo "${DICT_DSN}" | sed -n 's/.*password=\([^ ]*\).*/\1/p')" \
     psql "${DICT_DSN}" -c "SELECT 1" >/dev/null 2>&1; then
    local n
    n="$(PGPASSWORD="$(echo "${DICT_DSN}" | sed -n 's/.*password=\([^ ]*\).*/\1/p')" \
        psql "${DICT_DSN}" -tA -c "SELECT COUNT(*) FROM dictionary;" 2>/dev/null || echo "?")"
    log "  db:       ${DICT_DSN}  (dictionary rows: ${n})"
  else
    err "db unreachable: ${DICT_DSN}"; fail=1
  fi

  if (( fail )); then
    err "pre-flight failed"
    return 1
  fi
  log "  ok"
}

# --- Argument parsing --------------------------------------------------------
LIMIT=""
SKIP_DOWNLOAD="--no-download"
SKIP_TRUNCATE=""
CHECK_ONLY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --limit)         LIMIT="--limit $2"; shift 2 ;;
    --limit=*)       LIMIT="--limit ${1#*=}"; shift ;;
    --no-download)   SKIP_DOWNLOAD="--no-download"; shift ;;
    --skip-truncate) SKIP_TRUNCATE="--skip-truncate"; shift ;;
    --check)         CHECK_ONLY=1; shift ;;
    -h|--help)
      sed -n '2,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      err "unknown flag: $1 (try --help)"; exit 1
      ;;
  esac
done

# --- Run ---------------------------------------------------------------------
if (( CHECK_ONLY )); then
  run_check
  exit $?
fi

# In live mode, pre-flight is mandatory.
run_check || exit 1

# Remind the user what the run will do.
if [[ -n "${SKIP_TRUNCATE}" ]]; then
  warn "append mode (--skip-truncate): existing rows will NOT be removed"
else
  warn "truncate mode: existing rows will be deleted before insert"
fi
if [[ -n "${LIMIT}" ]]; then
  warn "limited to: ${LIMIT}"
fi

# Hard guard: kaikki file must be at least 1 GB. If someone points DATA_DIR at
# a fresh checkout, the seeder will happily start streaming a 0-byte file and
# "succeed" with 0 rows. Catch that here.
if [[ ! -s "${KAIKKI_PATH}" ]] || [[ $(stat -c%s "${KAIKKI_PATH}" 2>/dev/null || stat -f%z "${KAIKKI_PATH}" 2>/dev/null || echo 0) -lt 1000000000 ]]; then
  err "kaikki file at ${KAIKKI_PATH} is missing or smaller than 1 GB."
  err "remove --no-download or run the full seeder once to fetch it."
  exit 1
fi

# Hand off to the Python seeder.
log "running seed_dictionary.py ${SKIP_DOWNLOAD} ${SKIP_TRUNCATE} ${LIMIT}"
exec env \
  DICT_DSN="${DICT_DSN}" \
  DATA_DIR="${DATA_DIR}" \
  PSQL="${PSQL:-psql}" \
  "${PYTHON}" "${REPO_ROOT}/scripts/seed_dictionary.py" \
    ${SKIP_DOWNLOAD} ${SKIP_TRUNCATE} ${LIMIT}
