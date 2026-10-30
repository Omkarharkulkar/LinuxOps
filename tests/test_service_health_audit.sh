#!/usr/bin/env bash

# LinuxOps Service Health Audit Tests
# Purpose: Verify service audit behavior.

set -u

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$PROJECT_DIR/scripts/service_health_audit.sh"

PASSED=0
FAILED=0

pass() {
    echo "[PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "[FAIL] $1"
    FAILED=$((FAILED + 1))
}

echo "======================================"
echo " LINUXOPS SERVICE HEALTH AUDIT TESTS"
echo "======================================"

# Test 1: Audit script exists.
if [[ -f "$AUDIT_SCRIPT" ]]; then
    pass "Audit script exists"
else
    fail "Audit script exists"
    exit 1
fi

# Test 2: Audit script is executable.
if [[ -x "$AUDIT_SCRIPT" ]]; then
    pass "Audit script is executable"
else
    fail "Audit script is executable"
    exit 1
fi

# Test 3: Bash syntax is valid.
if bash -n "$AUDIT_SCRIPT"; then
    pass "Bash syntax is valid"
else
    fail "Bash syntax is valid"
    exit 1
fi

# Test 4: Script execution.
OUTPUT="$(bash "$AUDIT_SCRIPT" 2>&1)"
AUDIT_EXIT=$?

if [[ "$AUDIT_EXIT" -eq 0 ]]; then
    pass "Audit script exits successfully"
else
    fail "Audit script exits successfully"
    echo "$OUTPUT"
    exit 1
fi

# Check behavior based on systemctl availability.
if command -v systemctl >/dev/null 2>&1; then

    if grep -Fq "LINUXOPS SERVICE HEALTH AUDIT" <<< "$OUTPUT"; then
        pass "Report header is present"
    else
        fail "Report header is present"
    fi

    if grep -Fq "System state:" <<< "$OUTPUT"; then
        pass "System state is reported"
    else
        fail "System state is reported"
    fi

    if grep -Eq 'Running services : [0-9]+' <<< "$OUTPUT"; then
        pass "Running service count is numeric"
    else
        fail "Running service count is numeric"
    fi

    if grep -Eq 'Failed services  : [0-9]+' <<< "$OUTPUT"; then
        pass "Failed service count is numeric"
    else
        fail "Failed service count is numeric"
    fi

    if grep -Fq "Service: cron" <<< "$OUTPUT" &&
       grep -Fq "Service: NetworkManager" <<< "$OUTPUT" &&
       grep -Fq "Service: rsyslog" <<< "$OUTPUT"; then
        pass "Important service checks are included"
    else
        fail "Important service checks are included"
    fi

    if grep -Fq "RESOURCE SUMMARY" <<< "$OUTPUT" &&
       grep -Fq "Memory:" <<< "$OUTPUT" &&
       grep -Fq "Root filesystem:" <<< "$OUTPUT"; then
        pass "Resource summary is included"
    else
        fail "Resource summary is included"
    fi

    if grep -Fq "Service health audit completed." <<< "$OUTPUT"; then
        pass "Audit completion marker is present"
    else
        fail "Audit completion marker is present"
    fi

else
    if grep -Fq "WARNING: systemctl is unavailable; service audit cannot run." <<< "$OUTPUT"; then
        pass "Missing systemctl warning is displayed"
    else
        fail "Missing systemctl warning is displayed"
    fi
fi

echo
echo "======================================"
echo " Tests passed: $PASSED"
echo " Tests failed: $FAILED"
echo "======================================"

if (( FAILED > 0 )); then
    echo "RESULT: SOME TESTS FAILED"
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
