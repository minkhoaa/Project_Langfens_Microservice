#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "${script_dir}/../.." && pwd)

if (($# > 0)); then
  echo "[baseline] positional arguments are not supported by this runner"
  echo "[baseline] run dotnet/pytest directly for custom filters or verbosity"
  exit 2
fi

echo "[baseline] repo root: ${repo_root}"

mapfile -d '' dotnet_test_projects < <(
  find "${repo_root}" \
    -type f \
    \( -name '*Test*.csproj' -o -name '*Tests.csproj' \) \
    ! -path '*/bin/*' \
    ! -path '*/obj/*' \
    -print0 | sort -z
)

if ((${#dotnet_test_projects[@]} == 0)); then
  echo "[baseline] no committed .NET test projects found in this repo snapshot"
else
  echo "[baseline] running ${#dotnet_test_projects[@]} .NET test project(s)"
  for project in "${dotnet_test_projects[@]}"; do
    echo "[baseline] dotnet test ${project}"
    dotnet test \
      /m:1 \
      /p:BuildInParallel=false \
      /p:NodeReuse=false \
      /p:UseSharedCompilation=false \
      "${project}"
  done
fi

if command -v pytest >/dev/null 2>&1 && [[ -d "${repo_root}/services/ai-service/tests" ]]; then
  echo "[baseline] running ai-service pytest suite"
  (
    cd "${repo_root}/services/ai-service"
    pytest
  )
else
  echo "[baseline] pytest or ai-service test directory not available; skipping python suite"
fi
