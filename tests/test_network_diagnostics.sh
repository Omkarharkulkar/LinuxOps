#!/usr/bin/env bash

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$PROJECT_DIR/scripts/network_diagnostics.sh"

PASS=0
FAIL=0
REPORT=""

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

cleanup() {
    if [[ -n "$REPORT" && -f "$REPORT" ]]; then
        rm -f -- "$REPORT"
    fi
}

trap cleanup EXIT

echo "===== LINUXOPS NETWORK DIAGNOSTICS TESTS ====="

# Test 1: Script exists.
if [[ -f "$SCRIPT" ]]; then
    pass "Network diagnostics script exists"
else
    fail "Network diagnostics script exists"
    exit 1
fi

# Test 2: Bash syntax is valid.
if bash -n "$SCRIPT"; then
    pass "Network diagnostics script syntax"
else
    fail "Network diagnostics script syntax"
    exit 1
fi

# Test 3: Script is executable.
if [[ -x "$SCRIPT" ]]; then
    pass "Network diagnostics script is executable"
else
    fail "Network diagnostics script is executable"
    exit 1
fi

# Test 4: Script executes successfully.
if output=$("$SCRIPT" 2>&1); then
    pass "Network diagnostics execution"
else
    fail "Network diagnostics execution"
    echo "$output"
    exit 1
fi

# Test 5: Report is generated.
REPORT="$(printf '%s\n' "$output" |
    sed -n 's/^Report saved to: //p' | tail -n 1)"

if [[ -n "$REPORT" && -f "$REPORT" ]]; then
    pass "Network diagnostics report generated"
else
    fail "Network diagnostics report generated"
    echo "$output"
    exit 1
fi

# Test 6: Interface section exists.
if grep -Fq -- "----- NETWORK INTERFACES -----" "$REPORT"; then
    pass "Network interface section exists"
else
    fail "Network interface section exists"
fi

# Test 7: Routing section exists.
if grep -Fq -- "----- ROUTING TABLE -----" "$REPORT"; then
    pass "Routing table section exists"
else
    fail "Routing table section exists"
fi

# Test 8: DNS section exists.
if grep -Fq -- "----- DNS CONFIGURATION -----" "$REPORT"; then
    pass "DNS configuration section exists"
else
    fail "DNS configuration section exists"
fi

# Test 9: Listening ports section exists.
if grep -Fq -- "----- LISTENING TCP AND UDP PORTS -----" "$REPORT"; then
    pass "Listening ports section exists"
else
    fail "Listening ports section exists"
fi

# Test 10: Route selection section exists.
if grep -Fq -- "----- ROUTE SELECTION TEST -----" "$REPORT"; then
    pass "Route selection section exists"
else
    fail "Route selection section exists"
fi

echo
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

if (( FAIL > 0 )); then
    echo "RESULT: SOME TESTS FAILED"
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
