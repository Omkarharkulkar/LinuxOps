


# LinuxOps Service Health Audit Tests
# Purpose: Verify the service health audit script.

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$PROJECT_DIR/scripts/service_health_audit.sh"

PASSED=0
FAILED=0

pass() {
    echo "[PASS] $1"
    ((PASSED += 1))
}

fail() {
    echo "[FAIL] $1"
    ((FAILED += 1))
}

echo "======================================"
echo " LINUXOPS SERVICE HEALTH AUDIT TESTS"
echo "======================================"

# Test 1: Audit script exists.
if [[ -f "$AUDIT_SCRIPT" ]]; then
    pass "Audit script exists"
else
    fail "Audit script exists"
fi

# Test 2: Audit script is executable.
if [[ -x "$AUDIT_SCRIPT" ]]; then
    pass "Audit script is executable"
else
    fail "Audit script is executable"
fi

# Stop further tests if the script is missing or not executable.
if [[ ! -f "$AUDIT_SCRIPT" || ! -x "$AUDIT_SCRIPT" ]]; then
    echo
    echo "Tests passed: $PASSED"
    echo "Tests failed: $FAILED"
    exit 1
fi

# Test 3: Bash syntax is valid.
if bash -n "$AUDIT_SCRIPT"; then
    pass "Bash syntax is valid"
else
    fail "Bash syntax is valid"
fi

# Capture output for the remaining tests.
OUTPUT="$(bash "$AUDIT_SCRIPT" 2>&1)"
AUDIT_EXIT=$?

# Test 4: Correct report header.
if grep -q "LINUXOPS SERVICE HEALTH AUDIT" <<< "$OUTPUT"; then
    pass "Report header is present"
else
    fail "Report header is present"
fi

# Test 5: System state is reported.
if grep -q "System state:" <<< "$OUTPUT"; then
    pass "System state is reported"
else
    fail "System state is reported"
fi

# Test 6: Running service count is numeric.
if grep -Eq 'Running services : [0-9]+' <<< "$OUTPUT"; then
    pass "Running service count is numeric"
else
    fail "Running service count is numeric"
fi

# Test 7: Failed service count is numeric.
if grep -Eq 'Failed services  : [0-9]+' <<< "$OUTPUT"; then
    pass "Failed service count is numeric"
else
    fail "Failed service count is numeric"
fi

# Test 8: Important service checks are included.
if grep -q "Service: cron" <<< "$OUTPUT" &&
   grep -q "Service: NetworkManager" <<< "$OUTPUT" &&
   grep -q "Service: rsyslog" <<< "$OUTPUT"; then
    pass "Important service checks are included"
else
    fail "Important service checks are included"
fi

# Test 9: Resource summary is included.
if grep -q "RESOURCE SUMMARY" <<< "$OUTPUT" &&
   grep -q "Memory:" <<< "$OUTPUT" &&
   grep -q "Root filesystem:" <<< "$OUTPUT"; then
    pass "Resource summary is included"
else
    fail "Resource summary is included"
fi

# Test 10: Audit completion marker is present.
if grep -q "Service health audit completed." <<< "$OUTPUT"; then
    pass "Audit completion marker is present"
else
    fail "Audit completion marker is present"
fi

# Test 11: Audit script exits successfully.
if [[ "$AUDIT_EXIT" -eq 0 ]]; then
    pass "Audit script exits successfully"
else
    fail "Audit script exits successfully"
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
