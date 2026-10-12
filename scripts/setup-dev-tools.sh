#!/usr/bin/env bash
# Host bootstrap prerequisites for the generation-service recovery verification.
#
# This host has NO sudo, so the PostgreSQL client cannot be installed via the
# package manager. Instead we extract the genuine `psql` binary that ships inside
# the `postgres:17.6` image we already have locally and place it on PATH.
#
# This script does NOT stub, shim, or rewrite psql behaviour: it copies the real
# PostgreSQL 17.6 client executable plus the three shared libraries missing from
# this host (libpq, libtinfo, libsasl2). The only wrapper is a launcher that
# prepends the extracted lib dir to LD_LIBRARY_PATH.
#
# Usage:  scripts/setup-dev-tools.sh
set -euo pipefail

PG_IMAGE="${PG_IMAGE:-postgres:17.6}"
PREFIX="${PREFIX:-$HOME/.local/pgsql}"
BINLINK="$HOME/.local/bin"

echo "==> Extracting real psql from ${PG_IMAGE}"
rm -rf "$PREFIX"
mkdir -p "$PREFIX/bin" "$PREFIX/lib" "$BINLINK"

cid="$(docker create "$PG_IMAGE" /bin/true)"
trap 'docker rm -f "$cid" >/dev/null 2>&1 || true' EXIT

# Real client executable (NOT /usr/bin/psql, which is a perl wrapper script).
docker cp "$cid":/usr/lib/postgresql/17/bin/psql "$PREFIX/bin/psql"
chmod +x "$PREFIX/bin/psql"

# Shared libraries this Arch host does not provide.
for lib in \
  usr/lib/x86_64-linux-gnu/libpq.so.5 \
  usr/lib/x86_64-linux-gnu/libpq.so.5.18 \
  lib/x86_64-linux-gnu/libtinfo.so.6 \
  lib/x86_64-linux-gnu/libsasl2.so.2
do
  docker cp "$cid":/"$lib" "$PREFIX/lib/$(basename "$lib")" 2>/dev/null || \
    echo "    (skipped missing $lib)"
done

# Launcher: sets the library search path only; does not alter psql behaviour.
cat > "$BINLINK/psql" <<EOF
#!/bin/sh
# Real PostgreSQL client extracted from ${PG_IMAGE} (no sudo on this host).
# Only prepends the extracted shared-library dir to LD_LIBRARY_PATH.
PREFIX=${PREFIX}
export LD_LIBRARY_PATH="\$PREFIX/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}"
exec "\$PREFIX/bin/psql" "\$@"
EOF
chmod +x "$BINLINK/psql"

echo "==> Verifying"
export PATH="$BINLINK:$PATH"
psql --version
# Prove it is a real client that really connects, not a stub.
PGPASSWORD="${EXAM_DB_PASSWORD:-exam}" \
  psql -h "${EXAM_DB_HOST:-127.0.0.1}" -p "${EXAM_DB_PORT:-5433}" \
       -U "${EXAM_DB_USER:-exam}" -d "${EXAM_DB_NAME:-exam-db}" \
       -t -A -c 'SELECT version();'

cat <<EOF

Done. psql is on PATH at ${BINLINK}/psql (real ${PG_IMAGE} client).

Next prerequisite — internal service auth key used by the generation-service
tests. It belongs in the gitignored runtime input, never in a commit:

    printf 'EXAMSERVICE__INTERNAL__API__KEY=%s\\n' \\
      'test-only-ephemeral-secret-key-phase09' >> deploy/envs/loop-caps.env

That value is pinned by tests/test_t09_real_postgres_durability.py:43 and
test_automated_minimax_benchmark_dispatch.py:47. app/config.py reads
deploy/envs/loop-caps.env as a pydantic-settings env_file, so the key is picked
up without exporting it into the test process.
EOF