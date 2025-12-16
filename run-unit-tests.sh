#!/bin/bash

# ==========================================
# UNIT TEST ORCHESTRATOR
# Runs all Unit Tests which are fast, isolated, and require NO database.
# ==========================================

echo "🚀 Starting Backend UNIT Tests..."

# Find all projects ending in .UnitTests.csproj
TEST_PROJECTS=$(find ./tests -name "*.UnitTests.csproj")

if [ -z "$TEST_PROJECTS" ]; then
    echo "❌ No Unit Test projects found in ./tests"
    exit 1
fi

FAILURES=0

for PROJECT in $TEST_PROJECTS; do

    # Run test and capture output using TRX logger for easier parsing if needed, 
    # but for simple summary, standard output with normal verbosity is better.
    # We pipe valid output to a temp file to parse numbers.
    
    OUTPUT_FILE=$(mktemp)
    
    dotnet test "$PROJECT" --nologo --verbosity normal > "$OUTPUT_FILE" 2>&1
    EXIT_CODE=$?
    
    # Extract stats
    TOTAL=$(grep "Total tests:" "$OUTPUT_FILE" | head -n 1 | awk '{print $3}')
    PASSED=$(grep "Passed:" "$OUTPUT_FILE" | head -n 1 | awk '{print $2}')
    FAILED=$(grep "Failed:" "$OUTPUT_FILE" | head -n 1 | awk '{print $2}')
    SKIPPED=$(grep "Skipped:" "$OUTPUT_FILE" | head -n 1 | awk '{print $2}')
    
    # Defaults if missing
    TOTAL=${TOTAL:-0}
    PASSED=${PASSED:-0}
    FAILED=${FAILED:-0}
    SKIPPED=${SKIPPED:-0}
    
    echo "📊 Results: Total: $TOTAL | ✅ Passed: $PASSED | ❌ Failed: $FAILED | ⏭️ Skipped: $SKIPPED"

    if [ $EXIT_CODE -ne 0 ]; then
        echo "❌ FAILED: $(basename $PROJECT)"
        # Show concise error message (Error Message + 1 line)
        grep -A 2 "Error Message:" "$OUTPUT_FILE" | sed 's/^/   /'
        FAILURES=$((FAILURES+1))
    else
        echo "✅ PASSED: $(basename $PROJECT)"
    fi
    
    rm "$OUTPUT_FILE"
done

echo "--------------------------------------------------"
if [ $FAILURES -eq 0 ]; then
    echo "🎉 ALL UNIT TESTS PASSED!"
    exit 0
else
    echo "💥 $FAILURES UNIT TEST SUITE(S) FAILED."
    exit 1
fi
