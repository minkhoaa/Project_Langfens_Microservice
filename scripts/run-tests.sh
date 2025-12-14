#!/usr/bin/env bash
set -euo pipefail

# Run unit + integration suites sequentially to reduce resource spikes

dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/AttemptService.UnitTests/AttemptService.UnitTests.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/AuthService.UnitTests/AuthService.UnitTests.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/CourseService.UnitTests/CourseService.UnitTests.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/ExamService.UnitTest/ExamService.UnitTest.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/VocabularyService.UnitTests/VocabularyService.UnitTests.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/UnitTests/EmailService.UnitTests/EmailService.UnitTests.csproj"
dotnet test /m:1 /p:BuildInParallel=false /p:NodeReuse=false /p:UseSharedCompilation=false "$@" "tests/IntegrationTests/IntegrationTests/IntegrationTests.csproj"
