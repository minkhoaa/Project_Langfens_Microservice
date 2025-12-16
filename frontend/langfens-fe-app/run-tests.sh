#!/bin/bash

# Helper script to run specific E2E test suites
# Usage: ./run-tests.sh [suite_name]

set -e

function show_menu() {
    echo "Select a test suite to run (Visual Mode):"
    echo "1) Auth Flows       (auth.spec.ts)"
    echo "2) Security & Edge  (security-edge.spec.ts, auth-lockout.spec.ts)"
    echo "3) API Endpoints    (api-endpoints.spec.ts)"
    echo "4) Page Sanity      (missing-pages.spec.ts, sanity.spec.ts)"
    echo "5) Dictionary       (dictionary.spec.ts)"
    echo "6) Flashcards       (flashcard-learning.spec.ts)"
    echo "7) Exam Simulation  (exam-simulation.spec.ts)"
    echo "8) Mobile Layout    (mobile-layout.spec.ts)"
    echo "9) All Tests"
    echo "q) Quit"
    read -p "Enter choice [1-9]: " choice
}

if [ -z "$1" ]; then
    show_menu
else
    choice=$1
fi

case $choice in
    1) npm run e2e:auth ;;
    2) npm run e2e:security ;;
    3) npm run e2e:api ;;
    4) npm run e2e:pages ;;
    5) npm run e2e:dictionary ;;
    6) npm run e2e:flashcard ;;
    7) npm run e2e:exam ;;
    8) npm run e2e:mobile ;;
    9) npm run e2e:visual ;;
    q) exit 0 ;;
    *) echo "Invalid option"; exit 1 ;;
esac
