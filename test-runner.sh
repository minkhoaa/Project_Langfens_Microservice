#!/bin/bash

# ==========================================
# MASTER TEST ORCHESTRATOR
# One command to rule them all.
# ==========================================

chmod +x run-unit-tests.sh
chmod +x run-integration-tests.sh
chmod +x run-frontend-tests.sh
chmod +x frontend/langfens-fe-app/run-tests.sh

echo "⚡ Master Test Suite"
echo "-------------------"
echo "1) Backend UNIT Tests"
echo "2) Backend INTEGRATION Tests (requires Docker)"
echo "3) Frontend Tests (Unit + E2E)"
echo "4) FULL SYSTEM CHECK (Run Everything)"
echo "q) Quit"

read -p "Select Mode: " choice

case $choice in
    1) ./run-unit-tests.sh ;;
    2) ./run-integration-tests.sh ;;
    3) ./run-frontend-tests.sh ;;
    4)
        echo "🔥 RUNNING EVERYTHING..."
        ./run-unit-tests.sh && \
        ./run-integration-tests.sh && \
        ./run-frontend-tests.sh 1 && \
        ./run-frontend-tests.sh 2
        ;;
    q) exit 0 ;;
    *) echo "Invalid choice" ;;
esac
