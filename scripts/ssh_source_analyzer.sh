#!/usr/bin/env bash

set -uo pipefail

LOG_FILE="${1:-/var/log/auth.log}"
PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_FILE="$REPORT_DIR/ssh_source_report_$TIMESTAMP.txt"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Authentication log not found."
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    echo "ERROR: Cannot read authentication log."
    echo "Try running with sudo if necessary."
    exit 1
fi

if ! mkdir -p "$REPORT_DIR"; then
    echo "ERROR: Cannot create report directory."
    exit 1
fi

if ! {
    echo "======================================"
    echo " LINUXOPS SSH SOURCE-IP ANALYSIS"
    echo "======================================"
    echo "Generated: $(date)"
    echo

    echo "----- FAILED PASSWORD ATTEMPTS BY SOURCE -----"

    grep -aEi 'sshd.*Failed password for ' "$LOG_FILE" |
        grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' |
        awk '{print $2}' |
        sort |
        uniq -c |
        sort -nr || true

    echo
    echo "----- INTERPRETATION -----"
    echo "Repeated events from one address may warrant investigation."
    echo "Counts alone do not establish malicious activity."

} > "$REPORT_FILE" 2>&1; then
    echo "ERROR: Report generation failed."
    exit 1
fi

echo "SSH source analysis completed."
echo "Report: $REPORT_FILE"
