#!/usr/bin/env bash

# LinuxOps User and Permission Audit
# Purpose: Read-only audit of users, groups, and directory permissions.

set -u

TARGET_USER="${1:-linuxops_test}"
TARGET_GROUP="${2:-linuxops_lab}"
TARGET_DIR="${3:-/opt/linuxops-lab/shared}"

echo "=========================================="
echo " LINUXOPS USER & PERMISSION AUDIT"
echo "=========================================="
echo "Timestamp : $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname  : $(hostname)"
echo "Run as    : $(id -un)"
echo

echo "---- USER AUDIT ----"

if getent passwd "$TARGET_USER" > /dev/null; then
    id "$TARGET_USER"
else
    echo "WARNING: User '$TARGET_USER' does not exist."
fi

echo
echo "---- GROUP AUDIT ----"

if getent group "$TARGET_GROUP" > /dev/null; then
    getent group "$TARGET_GROUP"
else
    echo "WARNING: Group '$TARGET_GROUP' does not exist."
fi

echo
echo "---- DIRECTORY PERMISSION AUDIT ----"

if [[ -d "$TARGET_DIR" ]]; then
    printf 'Path: %s\n' "$TARGET_DIR"
    printf 'Owner: '
    stat -c '%U' "$TARGET_DIR"
    printf 'Group: '
    stat -c '%G' "$TARGET_DIR"
    stat -c 'Permissions: %A (%a)' "$TARGET_DIR"

    MODE="$(stat -c '%a' "$TARGET_DIR")"

    echo
    if (( (8#$MODE & 0002) != 0 )); then
        echo "WARNING: Directory is writable by others."
    else
        echo "PASS: Directory is not writable by others."
    fi

    if (( (8#$MODE & 0001) != 0 )); then
        echo "NOTICE: Others have directory traversal permission."
    else
        echo "INFO: Others do not have directory traversal permission."
    fi
else
    echo "WARNING: Directory '$TARGET_DIR' does not exist."
fi

echo
echo "=========================================="
echo " Audit completed."
echo "=========================================="
