
#!/usr/bin/env bash

# LinuxOps Service Health Auditor
# Purpose: Read-only systemd service and resource inspection.

set -u

echo "=========================================="
echo " LINUXOPS SERVICE HEALTH AUDIT"
echo "=========================================="
echo "Timestamp : $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname  : $(hostname)"
echo "Run as    : $(id -un)"
echo

echo "---- SYSTEM STATE ----"
SYSTEM_STATE="$(systemctl is-system-running 2>&1)"
echo "System state: $SYSTEM_STATE"
echo

echo "---- SERVICE SUMMARY ----"

RUNNING_COUNT="$(systemctl list-units \
    --type=service \
    --state=running \
    --no-legend \
    --no-pager | awk 'NF { count++ } END { print count+0 }')"

FAILED_COUNT="$(systemctl --failed \
    --type=service \
    --no-legend \
    --no-pager | awk 'NF { count++ } END { print count+0 }')"

echo "Running services : $RUNNING_COUNT"
echo "Failed services  : $FAILED_COUNT"
echo

echo "---- FAILED SERVICES ----"

if (( FAILED_COUNT > 0 )); then
    systemctl --failed --type=service --no-pager
else
    echo "PASS: No failed services reported."
fi

echo
echo "---- IMPORTANT SERVICE CHECKS ----"

SERVICES=("cron" "NetworkManager" "rsyslog" "ssh")

for SERVICE in "${SERVICES[@]}"; do
    echo
    echo "Service: $SERVICE"

    if systemctl list-unit-files "${SERVICE}.service" \
        --no-legend --no-pager 2>/dev/null | grep -q "${SERVICE}.service"; then

        ACTIVE_STATE="$(systemctl show "${SERVICE}.service" \
            -p ActiveState --value 2>/dev/null)"
        ENABLE_STATE="$(systemctl show "${SERVICE}.service" \
            -p UnitFileState --value 2>/dev/null)"

        echo "  Active state : ${ACTIVE_STATE:-unknown}"
        echo "  Enable state : ${ENABLE_STATE:-unknown}"
    else
        echo "  INFO: Service unit file was not found."
    fi
done

echo
echo "---- RESOURCE SUMMARY ----"

echo "Uptime:"
uptime -p

echo
echo "Memory:"
free -h

echo
echo "Root filesystem:"
df -h /

echo
echo "=========================================="
echo " Service health audit completed."
echo "=========================================="
