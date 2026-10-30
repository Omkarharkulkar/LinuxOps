#!/usr/bin/env bash
set -u

echo "========================="
echo "  LINUXOPS HEALTH CHECK"
echo "========================="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo

#disk usage check
echo "-----DISK HEALTH-----"

df -P -x tmpfs -x devtmpfs | awk '
NR == 1 { print; next }
{
usage =$5
sub(/%/, "", usage)

if (usage >= 90)
status  = "CRITICAL"
else if (usage >= 75)
status = "WARNING"
else
status = "OK"

print $0, "Status:", status
}'
echo

#memory check
echo "-----MEMORY HEALTH-----"

free -m | awk '
/^Mem:/ {
if ($2 > 0) {
usage = ($2 -$7)/$2*100

printf "Memory usage :%.1f%%\n", usage

if (usage >= 90)
print "Status: WARNING"
else
print "Status: OK"
}
}'
echo

#Load Information
echo "-----LOAD INFORMATION-----"
uptime
echo

#Failed system services
echo "-----FAILED SERVICES-----"

if command -v systemctl >/dev/null 2>&1
then
systemctl --failed --no-legend --no-pager
echo "Review any listed failed services."
else
echo "systemctl is unavailable."
fi

echo
echo "Health check completed"
