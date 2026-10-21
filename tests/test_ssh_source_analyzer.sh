
#!/usr/bin/env bash

set -uo pipefail

PROJECT_DIR="$HOME/linuxops"
SCRIPT="$PROJECT_DIR/scripts/ssh_source_analyzer.sh"
FIXTURE="$PROJECT_DIR/tests/fixtures/sample_auth.log"
REPORT_DIR="$PROJECT_DIR/reports"

PASS=0
FAIL=0

pass() {
    echo "[PASS] $1"
    PASS=$((PASS + 1))
}

fail() {
    echo "[FAIL] $1"
    FAIL=$((FAIL + 1))
}

echo "===== LINUXOPS SSH ANALYZER TESTS ====="

# Test 1: Required files exist
if [[ -f "$SCRIPT" && -f "$FIXTURE" ]]; then
    pass "Analyzer and sample log exist"
else
    fail "Analyzer and sample log exist"
fi

# Test 2: Bash syntax is valid
if bash -n "$SCRIPT"; then
    pass "Analyzer syntax"
else
    fail "Analyzer syntax"
fi

# Test 3: Analyzer executes successfully
if output=$(bash "$SCRIPT" "$FIXTURE" 2>&1); then
    pass "Analyzer execution"
else
    fail "Analyzer execution"
    echo "$output"
fi

# Test 4: Report is generated
report=$(printf '%s\n' "$output" |
    sed -n 's/^Report: //p' | tail -n 1)

if [[ -n "$report" && -f "$report" ]]; then
    pass "Report generated"

    # Test 5: Expected source-IP counts
    if grep -Eq '2[[:space:]]+192\.0\.2\.10' "$report"; then
        pass "Two failed attempts from 192.0.2.10"
    else
        fail "Two failed attempts from 192.0.2.10"
    fi

    if grep -Eq '1[[:space:]]+198\.51\.100\.20' "$report"; then
        pass "One failed attempt from 198.51.100.20"
    else
        fail "One failed attempt from 198.51.100.20"
    fi

    # Test 6: Successful login isn't counted as a failure
    if ! grep -Eq '203\.0\.113\.15' "$report"; then
        pass "Successful login excluded from failed-attempt counts"
    else
        fail "Successful login excluded from failed-attempt counts"
    fi
else
    fail "Report generated"
    echo "$output"
fi

echo
echo "Tests passed: $PASS"
echo "Tests failed: $FAIL"

if (( FAIL > 0 )); then
    exit 1
fi

exit 0
