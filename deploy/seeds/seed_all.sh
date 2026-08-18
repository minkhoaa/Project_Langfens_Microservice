#!/usr/bin/env bash
# seed_all.sh — runs every *.sql in deploy/seeds/ against its target database.
# Designed for the local AppHost setup where each postgres runs in its own
# container (random-suffix name) and is reachable via docker exec.
#
# Usage:   bash deploy/seeds/seed_all.sh
# Stops on first SQL error (-v ON_ERROR_STOP=1).
#
# DB → SQL file mapping:
#   exam-db         → placement.sql + seed_exam_*.sql + seed_exam_image_urls.sql + fix-matching-features.sql
#   attempt-db      → fix-matching-features-attempts.sql
#   writing-db      → seed_writing_exams_pack.sql + seed_writing_exams_image_urls.sql
#                     + seed_exam_ielts-mentor-writing-*.sql (mis-named but targets writing_exams)
#   speaking-db     → seed_speaking_exams.sql + seed_speaking_exams_image_urls.sql
#   gamification-db → seed_achievements.sql
#   vocabulary-db   → seed_deck-*.sql (11 files)
#   auth/dictionary/course-db → (no seeds)

set -u

declare -A DB_USER
DB_USER=(
    [exam-db]=exam
    [attempt-db]=attempt
    [writing-db]=writing
    [speaking-db]=speaking
    [gamification-db]=gamification
    [vocabulary-db]=vocabulary
)

declare -i fail=0 ok=0

# Resolve a live container id for each service name (AppHost gives them a
# random suffix; e.g. exam-db-server-7c03dc93).
resolve_container() {
    local svc="$1"
    docker ps --format '{{.Names}}' | grep -E "^${svc}-server-" | head -1
}

run_sql() {
    local svc="$1" file="$2" label="$3"
    local container
    container="$(resolve_container "$svc")"
    if [[ -z "$container" ]]; then
        echo "[FAIL ] ${label}  — no container found for ${svc}"
        return 1
    fi
    local user="${DB_USER[$svc]}"
    if docker exec -i -e "PGPASSWORD=$user" "$container" \
            psql -U "$user" -d "$svc" -v ON_ERROR_STOP=1 \
            < "$file" >/tmp/sql_out.$$ 2>&1; then
        echo "[ OK  ] ${label}"
        ok=$((ok + 1))
        rm -f /tmp/sql_out.$$
        return 0
    else
        echo "[FAIL ] ${label}"
        sed 's/^/         /' /tmp/sql_out.$$
        rm -f /tmp/sql_out.$$
        return 1
    fi
}

cd "$(dirname "$0")"
SEED_DIR="$(pwd)"

echo "============================================================"
echo "  exam-db"
echo "============================================================"
run_sql exam-db "$SEED_DIR/placement.sql"               "placement.sql"            || fail+=1
# All exam-db seeds EXCEPT the ones targeting writing_exams table.
for f in $(ls "$SEED_DIR"/seed_exam_*.sql | sort | grep -v 'seed_exam_ielts-mentor-writing-'); do
    run_sql exam-db "$f" "$(basename "$f")" || fail+=1
done
run_sql exam-db "$SEED_DIR/seed_exam_image_urls.sql"     "seed_exam_image_urls.sql" || fail+=1
run_sql exam-db "$SEED_DIR/fix-matching-features.sql"    "fix-matching-features.sql" || fail+=1

echo
echo "============================================================"
echo "  attempt-db"
echo "============================================================"
run_sql attempt-db "$SEED_DIR/fix-matching-features-attempts.sql" "fix-matching-features-attempts.sql" || fail+=1

echo
echo "============================================================"
echo "  writing-db"
echo "============================================================"
run_sql writing-db "$SEED_DIR/seed_writing_exams_pack.sql"          "seed_writing_exams_pack.sql"          || fail+=1
run_sql writing-db "$SEED_DIR/seed_writing_exams_image_urls.sql"    "seed_writing_exams_image_urls.sql"    || fail+=1
# Mis-named file: starts with seed_exam_ but operates on writing_exams table.
for f in $(ls "$SEED_DIR"/seed_exam_ielts-mentor-writing-*.sql 2>/dev/null); do
    run_sql writing-db "$f" "$(basename "$f")" || fail+=1
done

echo
echo "============================================================"
echo "  speaking-db"
echo "============================================================"
run_sql speaking-db "$SEED_DIR/seed_speaking_exams.sql"             "seed_speaking_exams.sql"             || fail+=1
run_sql speaking-db "$SEED_DIR/seed_speaking_exams_image_urls.sql"  "seed_speaking_exams_image_urls.sql"  || fail+=1

echo
echo "============================================================"
echo "  gamification-db"
echo "============================================================"
run_sql gamification-db "$SEED_DIR/seed_achievements.sql" "seed_achievements.sql" || fail+=1

echo
echo "============================================================"
echo "  vocabulary-db"
echo "============================================================"
for f in $(ls "$SEED_DIR"/seed_deck-*.sql | sort); do
    run_sql vocabulary-db "$f" "$(basename "$f")" || fail+=1
done

echo
echo "============================================================"
echo "  Summary: ok=$ok fail=$fail"
echo "============================================================"

# Cleanup tmp files
rm -f /tmp/sql_out.*

exit $((fail > 0 ? 1 : 0))