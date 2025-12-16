#!/bin/bash

# ==========================================
# FRONTEND ORCHESTRATOR
# Runs Frontend Logic Tests (Vitest) and E2E Tests (Playwright)
# ==========================================

CD_FRONTEND="cd frontend/langfens-fe-app"
FRONTEND_DIR="frontend/langfens-fe-app"

function show_menu() {
    echo "🎨 Frontend Test Menu:"
    echo "1) Run Unit/Component Tests (Vitest)"
    echo "2) Run All E2E Tests (Headless)"
    echo "3) Run Visual E2E Tests (Headed)"
    echo "q) Quit"
    read -p "Select option: " choice
}

if [ -z "$1" ]; then
    show_menu
else
    choice=$1
fi

case $choice in
    1)
        echo "🧪 Running Vitest..."
        (cd $FRONTEND_DIR && npm run test:run)
        ;;
    2)
        echo "🎭 Running Playwright E2E (Headless)..."
        (cd $FRONTEND_DIR && npm run e2e)
        ;;
    3)
        echo "📺 Running Playwright E2E (Visual)..."
        (cd $FRONTEND_DIR && ./run-tests.sh)
        ;;
    q) exit 0 ;;
    *) echo "Invalid option" ;;
esac
