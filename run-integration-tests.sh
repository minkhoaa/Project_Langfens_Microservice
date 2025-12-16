#!/bin/bash

# ==========================================
# INTEGRATION TEST ORCHESTRATOR
# Runs Integration Tests which require Docker containers (DB, Redis).
# ==========================================

echo "🐳 Preparing Integration Test Environment (Docker)..."

# Ensure docker is up for testing
docker compose -f deploy/compose.testing.yaml up -d db redis

echo "🚀 Starting Backend INTEGRATION Tests..."

# Find all projects ending in .IntegrationTests.csproj
TEST_PROJECTS=$(find ./tests -name "*.IntegrationTests.csproj")

if [ -z "$TEST_PROJECTS" ]; then
    echo "❌ No Integration Test projects found in ./tests"
    exit 1
fi

FAILURES=0

for PROJECT in $TEST_PROJECTS; do
    echo "--------------------------------------------------"
    echo "▶️ Running: $(basename $PROJECT)"
    # Pass environment variables if needed
    OUTPUT_FILE=$(mktemp)
    ASPNETCORE_ENVIRONMENT=Testing dotnet test "$PROJECT" --nologo --verbosity normal > "$OUTPUT_FILE" 2>&1
    EXIT_CODE=$?
    
    if [ $EXIT_CODE -ne 0 ]; then
        echo "❌ FAILED: $(basename $PROJECT)"
        # Show only the first error block (3 lines) to avoid spamming duplicates in Data-Driven Tests
        grep -A 2 "Error Message:" "$OUTPUT_FILE" | grep -v "\-\-" | sed 's/^/   /' | head -n 3
        
        # Count total errors
        FAILURES=$((FAILURES+1))
    else
        echo "✅ PASSED: $(basename $PROJECT)"
    fi
    rm "$OUTPUT_FILE"
done

echo "--------------------------------------------------"
if [ $FAILURES -eq 0 ]; then
    echo "🎉 ALL INTEGRATION TESTS PASSED!"
    exit 0
else
    echo "💥 $FAILURES INTEGRATION TEST SUITE(S) FAILED."
    exit 1
fi
