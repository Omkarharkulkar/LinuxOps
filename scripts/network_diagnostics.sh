#!/usr/bin/env bash

set -uo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
REPORT_DIR="$PROJECT_DIR/reports"
TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
REPORT_FILE="$REPORT_DIR/network_report_$TIMESTAMP.txt"

if ! mkdir -p "$REPORT_DIR"; then
    echo "Error: Could not create report directory: $REPORT_DIR" >&2
    exit 1
fi

# Send output to both the terminal and the report file.
exec > >(tee "$REPORT_FILE") 2>&1

echo "======================================"
echo " LINUXOPS NETWORK DIAGNOSTICS REPORT"
echo "======================================"
echo "Generated: $(date)"
echo "Hostname: $(hostname)"
echo

echo "----- NETWORK INTERFACES -----"
if command -v ip >/dev/null 2>&1; then
    ip -brief address || echo "WARNING: Unable to inspect network interfaces."
else
    echo "ERROR: The 'ip' command is unavailable."
fi
echo

echo "----- IPV4 ADDRESSES -----"
if command -v ip >/dev/null 2>&1; then
    ip -4 -brief address || echo "WARNING: Unable to inspect IPv4 addresses."
else
    echo "ERROR: The 'ip' command is unavailable."
fi
echo

echo "----- ROUTING TABLE -----"
if command -v ip >/dev/null 2>&1; then
    ip route show || echo "WARNING: Unable to read the routing table."
    echo
    if ip route show default | grep -q .; then
        echo "INFO: A default route is configured."
    else
        echo "WARNING: No default route was found."
    fi
else
    echo "ERROR: The 'ip' command is unavailable."
fi
echo

echo "----- DNS CONFIGURATION -----"
if command -v resolvectl >/dev/null 2>&1; then
    resolvectl status || echo "WARNING: Unable to read DNS status."
elif [[ -r /etc/resolv.conf ]]; then
    cat /etc/resolv.conf
else
    echo "WARNING: DNS configuration could not be inspected."
fi
echo

echo "----- DNS RESOLUTION TEST -----"
if command -v getent >/dev/null 2>&1; then
    if getent ahosts example.com; then
        echo "INFO: DNS/name resolution returned results for example.com."
    else
        echo "WARNING: Name resolution for example.com failed."
        echo "Check DNS configuration and network connectivity."
    fi
else
    echo "WARNING: The 'getent' command is unavailable; resolution test skipped."
fi
echo

echo "----- LISTENING TCP AND UDP PORTS -----"
if command -v ss >/dev/null 2>&1; then
    ss -tuln || echo "WARNING: Unable to inspect listening ports."
else
    echo "WARNING: The 'ss' command is unavailable."
fi
echo

echo "----- ROUTE SELECTION TEST -----"
if command -v ip >/dev/null 2>&1; then
    if ip route get 1.1.1.1; then
        echo "INFO: Linux found a route toward 1.1.1.1."
    else
        echo "WARNING: Linux could not find a route toward 1.1.1.1."
    fi
else
    echo "ERROR: The 'ip' command is unavailable."
fi
echo

echo "======================================"
echo "Report saved to: $REPORT_FILE"
echo "======================================"
