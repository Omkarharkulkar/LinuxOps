#!/usr/bin/env bash

set -uo pipefail

LOG_FILE="${1:-/var/log/auth.log}"
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_FILE="$REPORT_DIR/auth_report_$TIMESTAMP.txt"

# Check the log source.
if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Authentication log not found: $LOG_FILE"
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    echo "ERROR: Cannot read $LOG_FILE"
    echo "Try running with sudo if necessary."
    exit 1
fi

if ! mkdir -p "$REPORT_DIR"; then
    echo "ERROR: Cannot create report directory."
    exit 1
fi

# Match actual authentication messages, not sudo command text.
failed_pattern='sshd.*Failed password for '
invalid_pattern='sshd.*Invalid user '
success_pattern='sshd.*Accepted (password|publickey) for '

failed_count=$(grep -aEic "$failed_pattern" "$LOG_FILE" || true)
invalid_count=$(grep -aEic "$invalid_pattern" "$LOG_FILE" || true)
success_count=$(grep -aEic "$success_pattern" "$LOG_FILE" || true)

# Generate the report.
if ! {
    echo "======================================"
    echo " LINUXOPS AUTHENTICATION REPORT"
    echo "======================================"
    echo "Generated: $(date)"
    echo "Log source: $LOG_FILE"
    echo

    echo "----- FAILED SSH PASSWORD ATTEMPTS -----"
    grep -aEi "$failed_pattern" "$LOG_FILE" || true
    echo

    echo "----- INVALID SSH USER ATTEMPTS -----"
    grep -aEi "$invalid_pattern" "$LOG_FILE" || true
    echo

    echo "----- SUCCESSFUL SSH AUTHENTICATION -----"
    grep -aEi "$success_pattern" "$LOG_FILE" || true
    echo

    echo "----- SUMMARY -----"
    printf 'Failed SSH password events: %s\n' "$failed_count"
    printf 'Invalid SSH user events: %s\n' "$invalid_count"
    printf 'Successful SSH authentications: %s\n' "$success_count"

} > "$REPORT_FILE" 2>&1; then
    echo "ERROR: Failed to generate report."
    exit 1
fi

echo "Authentication report generated:"
echo "$REPORT_FILE"
