#!/usr/bin/env bash

set -u

PASS=0
FAIL=0

PROJECT_DIR="$HOME/linuxops"
BASELINE="$PROJECT_DIR/scripts/system_baseline.sh"
HEALTH="$PROJECT_DIR/scripts/system_health.sh"
SSH_TEST="$PROJECT_DIR/tests/test_ssh_source_analyzer.sh"
HEALTH_OUTPUT="/tmp/linuxops_health_test.txt"

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

echo "===== LINUXOPS TEST SUITE ====="

# Test 1: Required scripts exist
if [[ -f "$BASELINE" ]]; then
    pass "Baseline script exists"
else
    fail "Baseline script exists"
fi

if [[ -f "$HEALTH" ]]; then
    pass "Health script exists"
else
    fail "Health script exists"
fi

# Test 2: Bash syntax
if bash -n "$BASELINE"; then
    pass "Baseline script syntax"
else
    fail "Baseline script syntax"
fi

if bash -n "$HEALTH"; then
    pass "Health script syntax"
else
    fail "Health script syntax"
fi

# Test 3: Baseline execution
if bash "$BASELINE"; then
    pass "Baseline script executed"
else
    fail "Baseline script executed"
fi

# Test 4: Health checker execution and report sections
if bash "$HEALTH" > "$HEALTH_OUTPUT" 2>&1; then
    pass "Health checker executed"

    if grep -q "DISK HEALTH" "$HEALTH_OUTPUT" &&
       grep -q "MEMORY HEALTH" "$HEALTH_OUTPUT" &&
       grep -q "FAILED SERVICES" "$HEALTH_OUTPUT"; then
        pass "Health report sections"
    else
        fail "Health report sections"
        cat "$HEALTH_OUTPUT"
    fi
else
    fail "Health checker executed"
    cat "$HEALTH_OUTPUT"
fi

# Test 5: SSH analyzer test suite
echo
echo "===== SSH SOURCE ANALYZER TESTS ====="

if [[ -f "$SSH_TEST" ]]; then
    if bash "$SSH_TEST"; then
        pass "SSH analyzer test suite"
    else
        fail "SSH analyzer test suite"
    fi
else
    fail "SSH analyzer test script exists"
fi

# Final summary
echo
echo "===== FINAL LINUXOPS TEST SUMMARY ====="
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

if (( FAIL > 0 )); then
    exit 1
fi

exit 0
