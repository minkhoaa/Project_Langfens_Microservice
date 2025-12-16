#!/bin/bash
# run-full-stack.sh - E2E test runner
# 
# PREREQUISITES: Docker stack must already be running!
#   cd deploy && docker compose -f compose.local.yaml -f compose.testing.yaml up -d --build
#
# This script:
# 1. Checks if services are healthy
# 2. Runs Playwright E2E tests
#
# Usage: ./tests/run-full-stack.sh

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
GATEWAY_URL="http://localhost:5000"
AUTH_URL="http://localhost:8080"
FRONTEND_URL="http://localhost:3000"
TEST_SECRET="test-key"
MAX_WAIT_SECONDS=60

# Export for tests
export GATEWAY_URL
export AUTH_URL
export FRONTEND_URL
export TEST_SECRET

echo -e "${YELLOW}=== E2E Test Runner ===${NC}"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$SCRIPT_DIR/frontend/langfens-fe-app"

# ============================================
# STEP 1: Health Check
# ============================================
echo -e "${YELLOW}[STEP 1] Checking services...${NC}"

check_service() {
    local url=$1
    local name=$2
    if curl -s --fail "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $name is up${NC}"
        return 0
    else
        echo -e "${RED}✗ $name is down ($url)${NC}"
        return 1
    fi
}

check_service "$GATEWAY_URL/swagger/index.html" "Gateway" || true
check_service "$AUTH_URL/swagger/index.html" "AuthService" || true
check_service "$FRONTEND_URL" "Frontend" || true

# Check test harness
HARNESS_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -H "X-Test-Secret: $TEST_SECRET" "$AUTH_URL/__test/health" 2>/dev/null)
if [ "$HARNESS_RESPONSE" = "200" ]; then
    echo -e "${GREEN}✓ Test harness active (Testing mode)${NC}"
else
    echo -e "${YELLOW}⚠ Test harness: $HARNESS_RESPONSE${NC}"
fi

echo ""

# ============================================
# STEP 2: Run Playwright Tests
# ============================================
echo -e "${YELLOW}[STEP 2] Running Playwright E2E tests...${NC}"
echo ""

cd "$FRONTEND_DIR"

# Install if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Run tests
npx playwright test --reporter=list
PLAYWRIGHT_EXIT=$?

# ============================================
# Results
# ============================================
echo ""
if [ $PLAYWRIGHT_EXIT -eq 0 ]; then
    echo -e "${GREEN}=== ALL E2E TESTS PASSED ===${NC}"
else
    echo -e "${RED}=== SOME E2E TESTS FAILED ===${NC}"
    echo "Run 'npm run e2e:report' to see details"
fi

exit $PLAYWRIGHT_EXIT
