
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
    ((PASSED += 1))
}

fail() {
    echo "[FAIL] $1"
    ((FAILED += 1))
}

cleanup() {
    if [[ -n "$REPORT" ]]; then
        rm -f -- "$REPORT"
    fi
}

trap cleanup EXIT

echo "======================================"
echo " LINUXOPS AUTH ANALYZER TESTS"
echo "======================================"

# Test 1: Analyzer exists.
if [[ -f "$ANALYZER" ]]; then
    pass "Analyzer exists"
else
    fail "Analyzer exists"
fi

# Test 2: Fixture exists.
if [[ -f "$FIXTURE" ]]; then
    pass "Sample authentication log exists"
else
    fail "Sample authentication log exists"
fi

if [[ ! -f "$ANALYZER" || ! -f "$FIXTURE" ]]; then
    echo
    echo "Tests passed: $PASSED"
    echo "Tests failed: $FAILED"
    exit 1
fi

# Test 3: Bash syntax is valid.
if bash -n "$ANALYZER"; then
    pass "Analyzer syntax is valid"
else
    fail "Analyzer syntax is valid"
    exit 1
fi

# Run analyzer against the controlled sample log.
OUTPUT="$(bash "$ANALYZER" "$FIXTURE" 2>&1)"
EXIT_CODE=$?

if [[ "$EXIT_CODE" -eq 0 ]]; then
    pass "Analyzer executes successfully"
else
    fail "Analyzer executes successfully"
    echo "$OUTPUT"
    exit 1
fi

# Extract report path from command output.
REPORT="$(sed -n 's/^Authentication report generated:$//p' <<< "$OUTPUT" |
    head -n 1)"

REPORT_PATH="$(sed -n 's/^Authentication report generated:$//p' <<< "$OUTPUT")"

# The script prints the report path on the line after the message.
REPORT="$(awk '
    /Authentication report generated:/ { getline; print; exit }
' <<< "$OUTPUT")"

if [[ -z "$REPORT" || ! -f "$REPORT" ]]; then
    fail "Report file is generated"
    echo "$OUTPUT"
    exit 1
else
    pass "Report file is generated"
fi

# Test 5: Failed SSH password count.
if grep -q 'Failed SSH password events: 3' "$REPORT"; then
    pass "Three failed SSH password events detected"
else
    fail "Three failed SSH password events detected"
fi

# Test 6: Invalid SSH username count.
if grep -q 'Invalid SSH user events: 1' "$REPORT"; then
    pass "One invalid SSH user event detected"
else
    fail "One invalid SSH user event detected"
fi

# Test 7: Successful SSH authentication count.
if grep -q 'Successful SSH authentications: 1' "$REPORT"; then
    pass "One successful SSH authentication detected"
else
    fail "One successful SSH authentication detected"
fi

# Test 8: Unrelated sudo command is excluded.
if ! grep -q 'sudo: student.*COMMAND=.*grep.*Failed password' "$REPORT"; then
    pass "Unrelated sudo command is excluded"
else
    fail "Unrelated sudo command is excluded"
fi

# Test 9: The selected fixture is reported as the source.
if grep -q 'Log source: .*sample_auth.log' "$REPORT"; then
    pass "Report identifies the selected sample log"
else
    fail "Report identifies the selected sample log"
fi

echo
echo "Tests passed: $PASSED"
echo "Tests failed: $FAILED"

if [[ "$FAILED" -eq 0 ]]; then
    echo "RESULT: ALL TESTS PASSED"
    exit 0
else
    echo "RESULT: SOME TESTS FAILED"
    exit 1
fi
