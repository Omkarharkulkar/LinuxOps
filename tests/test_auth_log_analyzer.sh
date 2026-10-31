#!/usr/bin/env bash

# LinuxOps Authentication Analyzer Tests

set -u

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
ANALYZER="$PROJECT_DIR/scripts/auth_log_analyzer.sh"
FIXTURE="$PROJECT_DIR/tests/fixtures/sample_auth.log"

PASSED=0
FAILED=0
REPORT=""

pass() {
    echo "[PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "[FAIL] $1"
    FAILED=$((FAILED + 1))
}

cleanup() {
    if [[ -n "$REPORT" ]]; then
        rm -f -- "$REPORT"
    fi
}

trap cleanup EXIT

echo "===== LINUXOPS AUTH ANALYZER TESTS ====="

if [[ -f "$ANALYZER" && -f "$FIXTURE" ]]; then
    pass "Analyzer and sample log exist"
else
    fail "Analyzer and sample log exist"
    exit 1
fi

if bash -n "$ANALYZER"; then
    pass "Analyzer syntax is valid"
else
    fail "Analyzer syntax is valid"
    exit 1
fi

if OUTPUT=$(bash "$ANALYZER" "$FIXTURE" 2>&1); then
    pass "Analyzer executes successfully"
else
    fail "Analyzer executes successfully"
    echo "$OUTPUT"
    exit 1
fi

REPORT=$(awk '
    /Authentication report generated:/ { getline; print; exit }
' <<< "$OUTPUT")

if [[ -n "$REPORT" && -f "$REPORT" ]]; then
    pass "Report file is generated"
else
    fail "Report file is generated"
    echo "$OUTPUT"
    exit 1
fi

if grep -q 'Failed SSH password events: 3' "$REPORT"; then
    pass "Three failed SSH password events detected"
else
    fail "Three failed SSH password events detected"
fi

if grep -q 'Invalid SSH user events: 2' "$REPORT"; then
    pass "Two invalid-user events detected"
else
    fail "Two invalid-user events detected"
fi

if grep -q 'Successful SSH authentications: 2' "$REPORT"; then
    pass "Two successful SSH authentications detected"
else
    fail "Two successful SSH authentications detected"
fi

if ! grep -q 'sudo: student.*COMMAND=.*grep.*Failed password' "$REPORT"; then
    pass "Unrelated sudo command is excluded"
else
    fail "Unrelated sudo command is excluded"
fi

if grep -q 'Log source: .*sample_auth.log' "$REPORT"; then
    pass "Report identifies the selected sample log"
else
    fail "Report identifies the selected sample log"
fi

echo
echo "Tests passed: $PASSED"
echo "Tests failed: $FAILED"

if (( FAILED > 0 )); then
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
