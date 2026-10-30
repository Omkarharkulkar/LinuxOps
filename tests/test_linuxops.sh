#!/usr/bin/env bash

set -u

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

PASS=0
FAIL=0

HEALTH_OUTPUT="$(mktemp)"
trap 'rm -f -- "$HEALTH_OUTPUT"' EXIT

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

run_test_suite() {
    local test_script="$1"
    local test_name="$2"

    echo
    echo "===== $test_name ====="

    if [[ ! -f "$test_script" ]]; then
        fail "$test_name script exists"
        return
    fi

    if bash "$test_script"; then
        pass "$test_name"
    else
        fail "$test_name"
    fi
}

echo "===== LINUXOPS TEST SUITE ====="

BASELINE="$PROJECT_DIR/scripts/system_baseline.sh"
HEALTH="$PROJECT_DIR/scripts/system_health.sh"

# Test 1: Required scripts exist.
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

# Test 2: Bash syntax.
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

# Test 3: Baseline execution.
if [[ -f "$BASELINE" ]] && bash "$BASELINE"; then
    pass "Baseline script executed"
else
    fail "Baseline script executed"
fi

# Test 4: Health checker execution and output.
if [[ -f "$HEALTH" ]] && bash "$HEALTH" > "$HEALTH_OUTPUT" 2>&1; then
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

# Test 5: Run all focused test suites.
run_test_suite "$PROJECT_DIR/tests/test_auth_log_analyzer.sh" \
    "Authentication analyzer tests"

run_test_suite "$PROJECT_DIR/tests/test_ssh_source_analyzer.sh" \
    "SSH source analyzer tests"

run_test_suite "$PROJECT_DIR/tests/test_user_audit.sh" \
    "User audit tests"

run_test_suite "$PROJECT_DIR/tests/test_service_health_audit.sh" \
    "Service health audit tests"

run_test_suite "$PROJECT_DIR/tests/test_network_diagnostics.sh" \
    "Network diagnostics tests"

# Final summary.
echo
echo "===== FINAL LINUXOPS TEST SUMMARY ====="
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

if (( FAIL > 0 )); then
    echo "RESULT: SOME TESTS FAILED"
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
exit 0
