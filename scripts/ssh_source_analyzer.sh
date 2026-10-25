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
    echo "----- THRESHOLD-BASED FINDINGS -----"

    THRESHOLD=2
    FAILED_COUNTS="$(
        grep -aEi 'sshd.*Failed password for ' "$LOG_FILE" |
            grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' |
            awk '{print $2}' |
            sort |
            uniq -c |
            sort -nr || true
    )"

    if [[ -z "$FAILED_COUNTS" ]]; then
        echo "INFO: No failed SSH password attempts with a source IP were found."
    else
        while read -r COUNT IP; do
            [[ -n "${COUNT:-}" && -n "${IP:-}" ]] || continue

            if (( COUNT >= THRESHOLD )); then
                printf 'ALERT: %s failed attempts from %s (threshold: %s)\n' \
                    "$COUNT" "$IP" "$THRESHOLD"
            else
                printf 'INFO: %s failed attempt(s) from %s; below threshold.\n' \
                    "$COUNT" "$IP"
            fi
        done <<< "$FAILED_COUNTS"
    fi

    echo
    echo "----- INTERPRETATION -----"
    echo "Repeated events from one address may warrant investigation."
    echo "Threshold alerts are indicators for review, not proof of malicious activity."


} > "$REPORT_FILE" 2>&1; then
    echo "ERROR: Report generation failed."
    exit 1
fi

echo "SSH source analysis completed."
echo "Report: $REPORT_FILE"
