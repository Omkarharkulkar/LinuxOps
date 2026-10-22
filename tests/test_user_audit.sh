
#!/usr/bin/env bash

# LinuxOps User Audit Tests
# Purpose: Verify user_audit.sh output and warning detection.

set -u

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_SCRIPT="$PROJECT_DIR/scripts/user_audit.sh"

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
echo " LINUXOPS USER AUDIT TESTS"
echo "======================================"

# Test 1: Audit script exists.
if [[ -x "$AUDIT_SCRIPT" ]]; then
    pass "Audit script exists and is executable"
else
    fail "Audit script exists and is executable"
    echo "Tests passed: $PASSED"
    echo "Tests failed: $FAILED"
    exit 1
fi

# Test 2: Default user audit.
OUTPUT="$("$AUDIT_SCRIPT" 2>&1)"

if grep -q "linuxops_test" <<< "$OUTPUT"; then
    pass "Default audit identifies linuxops_test"
else
    fail "Default audit identifies linuxops_test"
fi

# Test 3: Default group audit.
if grep -q "linuxops_lab" <<< "$OUTPUT"; then
    pass "Default audit identifies linuxops_lab"
else
    fail "Default audit identifies linuxops_lab"
fi

# Test 4: Expected directory permissions.
if grep -q "Permissions: drwxrws--- (2770)" <<< "$OUTPUT"; then
    pass "Shared directory permissions are reported correctly"
else
    fail "Shared directory permissions are reported correctly"
fi

# Test 5: Secure shared directory warning check.
if grep -q "PASS: Directory is not writable by others." <<< "$OUTPUT"; then
    pass "Shared directory is not reported as writable by others"
else
    fail "Shared directory is not reported as writable by others"
fi

# Test 6: Detect /tmp permissions.
TMP_OUTPUT="$("$AUDIT_SCRIPT" root root /tmp 2>&1)"

if grep -q "WARNING: Directory is writable by others." <<< "$TMP_OUTPUT"; then
    pass "Detects a directory writable by others"
else
    fail "Detects a directory writable by others"
fi

# Test 7: Missing user warning.
MISSING_USER="linuxops_missing_user_test_$$"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" "$MISSING_USER" linuxops_lab /opt/linuxops-lab/shared 2>&1)"

if grep -q "WARNING: User '$MISSING_USER' does not exist." <<< "$MISSING_OUTPUT"; then
    pass "Warns when the requested user does not exist"
else
    fail "Warns when the requested user does not exist"
fi

# Test 8: Missing group warning.
MISSING_GROUP="linuxops_missing_group_test_$$"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" linuxops_test "$MISSING_GROUP" /opt/linuxops-lab/shared 2>&1)"

if grep -q "WARNING: Group '$MISSING_GROUP' does not exist." <<< "$MISSING_OUTPUT"; then
    pass "Warns when the requested group does not exist"
else
    fail "Warns when the requested group does not exist"
fi

# Test 9: Missing directory warning.
MISSING_DIR="/tmp/linuxops_missing_directory_test_$$"
MISSING_OUTPUT="$("$AUDIT_SCRIPT" linuxops_test linuxops_lab "$MISSING_DIR" 2>&1)"

if grep -q "WARNING: Directory '$MISSING_DIR' does not exist." <<< "$MISSING_OUTPUT"; then
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

exit 0
