#!/usr/bin/env bash

set -uo pipefail

LOG_FILE="${1:-/var/log/auth.log}"
THRESHOLD="${2:-5}"

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
REPORT_FILE="$REPORT_DIR/ssh_source_report_$TIMESTAMP.txt"

if [[ ! "$THRESHOLD" =~ ^[1-9][0-9]*$ ]]; then
    echo "ERROR: Threshold must be a positive whole number."
    echo "Usage: $0 [auth-log-file] [threshold]"
    exit 1
fi

if [[ ! -f "$LOG_FILE" ]]; then
    echo "ERROR: Authentication log not found: $LOG_FILE"
    exit 1
fi

if [[ ! -r "$LOG_FILE" ]]; then
    echo "ERROR: Cannot read authentication log: $LOG_FILE"
    echo "Try running with sudo if necessary."
    exit 1
fi

if ! mkdir -p "$REPORT_DIR"; then
    echo "ERROR: Cannot create report directory."
    exit 1
fi

# Count failed-password attempts separately from invalid-user events.
failed_pattern='sshd.*Failed password for '
invalid_user_pattern='sshd\[[^]]+\]: Invalid user '
success_pattern='sshd.*Accepted (password|publickey) for '

FAILED_COUNTS="$(
    grep -aE "$failed_pattern" "$LOG_FILE" |
        grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' |
        awk '{print $2}' |
        sort |
        uniq -c |
        sort -nr || true
)"

INVALID_USER_COUNTS="$(
    grep -aE "$invalid_user_pattern" "$LOG_FILE" |
        grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' |
        awk '{print $2}' |
        sort |
        uniq -c |
        sort -nr || true
)"

SUCCESS_COUNTS="$(
    grep -aE "$success_pattern" "$LOG_FILE" |
        grep -oE 'from ([0-9]{1,3}\.){3}[0-9]{1,3}' |
        awk '{print $2}' |
        sort |
        uniq -c |
        sort -nr || true
)"

SUCCESS_IPS="$(
    printf '%s\n' "$SUCCESS_COUNTS" |
        awk 'NF >= 2 {print $2}'
)"

if ! {
    echo "======================================"
    echo " LINUXOPS SSH SOURCE-IP ANALYSIS"
    echo "======================================"
    echo "Generated: $(date)"
    echo "Log source: $LOG_FILE"
    echo "Alert threshold: $THRESHOLD"
    echo

    echo "----- FAILED PASSWORD ATTEMPTS BY SOURCE -----"

    if [[ -n "$FAILED_COUNTS" ]]; then
        printf '%s\n' "$FAILED_COUNTS"
    else
        echo "No failed-password attempts with source IPs were found."
    fi

    echo
    echo "----- THRESHOLD-BASED FINDINGS -----"

    if [[ -z "$FAILED_COUNTS" ]]; then
        echo "INFO: No relevant SSH authentication events with source IPs were found."
    else
        while read -r COUNT IP; do
            [[ -n "${COUNT:-}" && -n "${IP:-}" ]] || continue

            if (( COUNT >= THRESHOLD )); then
                printf 'ALERT: %s failed password attempt(s) from %s (threshold: %s)\n' \
                    "$COUNT" "$IP" "$THRESHOLD"
            else
                printf 'INFO: %s failed password attempt(s) from %s; below threshold.\n' \
                    "$COUNT" "$IP"
            fi
        done <<< "$FAILED_COUNTS"
    fi

    echo
    echo "----- STANDALONE INVALID-USER EVENTS BY SOURCE -----"

    if [[ -n "$INVALID_USER_COUNTS" ]]; then
        printf '%s\n' "$INVALID_USER_COUNTS"
    else
        echo "No standalone invalid-user events with source IPs were found."
    fi

    echo
    echo "----- SUCCESSFUL AUTHENTICATION BY SOURCE -----"

    if [[ -n "$SUCCESS_COUNTS" ]]; then
        printf '%s\n' "$SUCCESS_COUNTS"
    else
        echo "No successful SSH authentication events with source IPs were found."
    fi

    echo
    echo "----- SOURCE-IP CORRELATION -----"

    CORRELATION_FOUND=0

    if [[ -n "$FAILED_COUNTS" && -n "$SUCCESS_IPS" ]]; then
        while read -r COUNT IP; do
            [[ -n "${IP:-}" ]] || continue

            if grep -Fxq "$IP" <<< "$SUCCESS_IPS"; then
                printf 'REVIEW: Both failed and successful SSH authentication events were recorded from %s.\n' "$IP"
                CORRELATION_FOUND=1
            fi
        done <<< "$FAILED_COUNTS"
    fi

    if (( CORRELATION_FOUND == 0 )); then
        echo "INFO: No source IPs with both failed and successful authentication events were found."
    fi

    echo
    echo "----- INTERPRETATION -----"
    echo "Repeated authentication events from one address may warrant investigation."
    echo "An IP address associated with both failed and successful events may also warrant review."
    echo "These findings are indicators for investigation, not proof of malicious activity."

} > "$REPORT_FILE" 2>&1; then
    echo "ERROR: Report generation failed."
    exit 1
fi

echo "SSH source analysis completed."
echo "Report: $REPORT_FILE"
