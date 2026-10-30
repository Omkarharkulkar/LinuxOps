#!/usr/bin/env bash

# LinuxOps User Audit Tests
# Purpose: Verify user_audit.sh output and warning detection.

set -u

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$PROJECT_DIR/scripts/user_audit.sh"

PASSED=0
FAILED=0
TEST_DIR="$(mktemp -d)"

cleanup() {
    rm -rf -- "$TEST_DIR"
}

trap cleanup EXIT

pass() {
    echo "[PASS] $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo "[FAIL] $1"
    FAILED=$((FAILED + 1))
}

echo "======================================"
echo " LINUXOPS USER AUDIT TESTS"
echo "======================================"

# Test 1: Audit script exists and is executable.
if [[ -x "$AUDIT_SCRIPT" ]]; then
    pass "Audit script exists and is executable"
else
    fail "Audit script exists and is executable"
    exit 1
fi

CURRENT_USER="$(id -un)"
CURRENT_GROUP="$(id -gn)"

# Prepare controlled test directories.
SECURE_DIR="$TEST_DIR/secure"
WRITABLE_DIR="$TEST_DIR/writable"
mkdir -p "$SECURE_DIR" "$WRITABLE_DIR"
chmod 2770 "$SECURE_DIR"
chmod 1777 "$WRITABLE_DIR"

# Test 2: Current user is identified.
OUTPUT="$("$AUDIT_SCRIPT" "$CURRENT_USER" "$CURRENT_GROUP" "$SECURE_DIR" 2>&1)"

if grep -Fq "Run as    : $CURRENT_USER" <<< "$OUTPUT" &&
   grep -Fq -- "---- USER AUDIT ----" <<< "$OUTPUT"; then
    pass "Current user is identified"
else
    fail "Current user is identified"
fi

# Test 3: Current group is identified.
if grep -Fq "$CURRENT_GROUP" <<< "$OUTPUT"; then
    pass "Current group is identified"
else
    fail "Current group is identified"
fi

# Test 4: Secure directory permissions are reported.
if grep -Fq "Permissions: drwxrws--- (2770)" <<< "$OUTPUT"; then
    pass "Secure directory permissions are reported correctly"
else
    fail "Secure directory permissions are reported correctly"
fi

# Test 5: Secure directory is not reported as writable by others.
if grep -Fq "PASS: Directory is not writable by others." <<< "$OUTPUT"; then
    pass "Secure directory is not writable by others"
else
    fail "Secure directory is not writable by others"
fi

# Test 6: World-writable directory is detected.
WRITABLE_OUTPUT="$("$AUDIT_SCRIPT" "$CURRENT_USER" "$CURRENT_GROUP" "$WRITABLE_DIR" 2>&1)"

if grep -Fq "WARNING: Directory is writable by others." <<< "$WRITABLE_OUTPUT"; then
    pass "Detects a directory writable by others"
else
    fail "Detects a directory writable by others"
fi

# Test 7: Missing user warning.
MISSING_USER="linuxops_missing_user_test_$$"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" "$MISSING_USER" "$CURRENT_GROUP" "$SECURE_DIR" 2>&1)"

if grep -Fq "WARNING: User '$MISSING_USER' does not exist." <<< "$MISSING_OUTPUT"; then
    pass "Warns when the requested user does not exist"
else
    fail "Warns when the requested user does not exist"
fi

# Test 8: Missing group warning.
MISSING_GROUP="linuxops_missing_group_test_$$"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" "$CURRENT_USER" "$MISSING_GROUP" "$SECURE_DIR" 2>&1)"

if grep -Fq "WARNING: Group '$MISSING_GROUP' does not exist." <<< "$MISSING_OUTPUT"; then
    pass "Warns when the requested group does not exist"
else
    fail "Warns when the requested group does not exist"
fi

# Test 9: Missing directory warning.
MISSING_DIR="$TEST_DIR/missing_directory"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" "$CURRENT_USER" "$CURRENT_GROUP" "$MISSING_DIR" 2>&1)"

if grep -Fq "WARNING: Directory '$MISSING_DIR' does not exist." <<< "$MISSING_OUTPUT"; then
    pass "Warns when the requested directory does not exist"
else
    fail "Warns when the requested directory does not exist"
fi

echo
echo "======================================"
echo " Tests passed: $PASSED"
echo " Tests failed: $FAILED"
echo "======================================"

if (( FAILED > 0 )); then
    exit 1
fi

echo "RESULT: ALL TESTS PASSED"
