#!/usr/bin/env bash

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$PROJECT_DIR/scripts/ssh_source_analyzer.sh"
FIXTURE="$PROJECT_DIR/tests/fixtures/sample_auth.log"

PASS=0
FAIL=0
DEFAULT_REPORT=""
CUSTOM_REPORT=""

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

cleanup() {
    [[ -n "$DEFAULT_REPORT" ]] && rm -f -- "$DEFAULT_REPORT"
    [[ -n "$CUSTOM_REPORT" ]] && rm -f -- "$CUSTOM_REPORT"
}

trap cleanup EXIT

echo "===== LINUXOPS SSH ANALYZER TESTS ====="

if [[ -f "$SCRIPT" && -f "$FIXTURE" ]]; then
    pass "Analyzer and sample log exist"
else
    fail "Analyzer and sample log exist"
    exit 1
fi

if bash -n "$SCRIPT"; then
    pass "Analyzer syntax is valid"
else
    fail "Analyzer syntax is valid"
    exit 1
fi

if output=$(bash "$SCRIPT" "$FIXTURE" 2>&1); then
    pass "Default-threshold execution"
else
    fail "Default-threshold execution"
    echo "$output"
    exit 1
fi

DEFAULT_REPORT=$(printf '%s\n' "$output" |
    sed -n 's/^Report: //p' | tail -n 1)

if [[ -n "$DEFAULT_REPORT" && -f "$DEFAULT_REPORT" ]]; then
    pass "Default-threshold report generated"
else
    fail "Default-threshold report generated"
    exit 1
fi

if grep -Fq 'Alert threshold: 5' "$DEFAULT_REPORT"; then
    pass "Default threshold is five"
else
    fail "Default threshold is five"
fi

if grep -A1 -F -- '----- FAILED PASSWORD ATTEMPTS BY SOURCE -----' "$DEFAULT_REPORT" |
    grep -Eq '2[[:space:]]+192\.0\.2\.10'; then
    pass "Two failed-password attempts counted without double counting"
else
    fail "Two failed-password attempts counted without double counting"
fi

if grep -A1 -F -- '----- STANDALONE INVALID-USER EVENTS BY SOURCE -----' "$DEFAULT_REPORT" |
    grep -Eq '2[[:space:]]+192\.0\.2\.10'; then
    pass "Invalid-user events counted separately"
else
    fail "Invalid-user events counted separately"
fi

if grep -Eq '1[[:space:]]+198\.51\.100\.20' "$DEFAULT_REPORT"; then
    pass "One event counted for 198.51.100.20"
else
    fail "One event counted for 198.51.100.20"
fi

if ! grep -Fq 'ALERT:' "$DEFAULT_REPORT"; then
    pass "No alert below the default threshold"
else
    fail "No alert below the default threshold"
fi

if grep -Fq '192.0.2.10' "$DEFAULT_REPORT" &&
   grep -Fq '203.0.113.15' "$DEFAULT_REPORT"; then
    pass "Successful authentication sources are included"
else
    fail "Successful authentication sources are included"
fi

if grep -Fq 'Both failed and successful SSH authentication events were recorded from 192.0.2.10.' "$DEFAULT_REPORT"; then
    pass "Failed and successful events are correlated"
else
    fail "Failed and successful events are correlated"
fi

if output=$(bash "$SCRIPT" "$FIXTURE" 2 2>&1); then
    pass "Custom-threshold execution"
else
    fail "Custom-threshold execution"
    echo "$output"
    exit 1
fi

CUSTOM_REPORT=$(printf '%s\n' "$output" |
    sed -n 's/^Report: //p' | tail -n 1)

if [[ -n "$CUSTOM_REPORT" && -f "$CUSTOM_REPORT" ]]; then
    pass "Custom-threshold report generated"
else
    fail "Custom-threshold report generated"
    exit 1
fi

if grep -Fq 'Alert threshold: 2' "$CUSTOM_REPORT" &&
   grep -Fq 'ALERT: 2 failed password attempt(s) from 192.0.2.10 (threshold: 2)' "$CUSTOM_REPORT"; then
    pass "Custom threshold triggers the expected alert"
else
    fail "Custom threshold triggers the expected alert"
fi

if grep -Fq 'indicators for investigation, not proof of malicious activity.' "$CUSTOM_REPORT"; then
    pass "Report includes appropriate interpretation"
else
    fail "Report includes appropriate interpretation"
fi

echo
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

if (( FAIL > 0 )); then
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
