#!/usr/bin/env bash
set -u

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
REPORT_FILE="$REPORT_DIR/system_baseline_$TIMESTAMP.txt"

if ! mkdir -p "$REPORT_DIR"; then
    echo "Error: Could not create report directory: $REPORT_DIR" >&2
    exit 1
fi

{

echo "======================================="
echo "       LINUXOPS SYSTEM BASELINE"
echo "======================================="
echo "Generated :$(date)"
echo

echo "------ SYSTEM INFORMATION -----"
hostname
cat /etc/os-release
echo

echo "-----KERNEL INFORMATION-----"
uname -a
echo

echo "-----CURRENT USER-----"
whoami
echo

echo "-----MEMORY USAGE-----"
free -h
echo

echo "-----DISK USAGE-----"
df -h
echo

echo "-----UPTIME-----"
uptime
echo

echo "-----IP ADDRESSES-----"
ip -brief address
echo

} > "$REPORT_FILE" 2>&1

echo "System baseline report generated:"
echo "$REPORT_FILE"
