#!/usr/bin/env bash
set -euo pipefail

# Run unit + integration suites sequentially to reduce resource spikes

dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/AttemptService.UnitTests/AttemptService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/AuthService.UnitTests/AuthService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/CourseService.UnitTests/CourseService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/ExamService/ExamService.UnitTest/ExamService.UnitTest.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/VocabularyService.UnitTests/VocabularyService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/EmailService.UnitTests/EmailService.UnitTests.csproj
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" tests/IntegrationTests/IntegrationTests.csproj
