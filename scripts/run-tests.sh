#!/usr/bin/env bash
set -euo pipefail

# Run unit + integration suites sequentially to reduce resource spikes

dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/AttemptService.UnitTests/AttemptService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/AuthService.UnitTests/AuthService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/CourseService.UnitTests/CourseService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/ExamService.UnitTest/ExamService.UnitTest.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/VocabularyService.UnitTests/VocabularyService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/unit/EmailService.UnitTests/EmailService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/integration/IntegrationTests/IntegrationTests.csproj
