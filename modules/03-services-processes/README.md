# Module 03: Services & Process Management

## Overview

This module demonstrates Linux service administration, process inspection, and basic system resource monitoring using Bash and systemd utilities.

The module includes a read-only service health audit script that collects service states, identifies failed services, checks selected system services, and summarizes system resource usage.

## Objectives

- Inspect the systemd service manager and overall system state.
- List and count running services.
- Identify failed system services.
- Inspect whether selected services are active and enabled.
- View running processes and their CPU and memory usage.
- Review uptime, memory availability, and root filesystem utilization.
- Automate service health checks using Bash.
- Validate the script with automated tests.

## Lab Environment

- Operating system: Ubuntu 24.04 LTS
- Service manager: systemd
- Shell: Bash
- Virtualization: VirtualBox

## Tools and Commands

| Command | Purpose |
|---|---|
| `systemctl is-system-running` | Check the overall system state |
| `systemctl list-units --type=service --state=running` | List running services |
| `systemctl --failed` | Identify failed units |
| `systemctl status <service>` | Inspect a service's status |
| `systemctl show <service>` | Read selected service properties |
| `ps -eo ...` | Inspect processes and resource usage |
| `uptime -p` | Display system uptime |
| `free -h` | Review memory and swap usage |
| `df -h /` | Check root filesystem capacity |

## Service Health Auditor

Script: `scripts/service_health_audit.sh`

The auditor performs read-only checks and reports:

1. Timestamp, hostname, and execution user.
2. Overall system state.
3. Counts of running and failed services.
4. Details of failed services, if any.
5. Active and enabled states for selected services:
   - `cron`
   - `NetworkManager`
   - `rsyslog`
   - `ssh`
6. System uptime.
7. Memory and swap usage.
8. Root filesystem utilization.

A service that is not installed is reported as unavailable rather than automatically installed or modified. For example, the OpenSSH server unit may not exist on a system that does not have the server package installed.

The auditor does not start, stop, enable, disable, or reconfigure services.

## Running the Auditor

From the project root:

```bash
./scripts/service_health_audit.sh
```

## Automated Tests

Test script: `tests/test_service_health_audit.sh`

Run the tests:

```bash
./tests/test_service_health_audit.sh
```

The test suite checks script existence and permissions, Bash syntax, report sections, service-count formatting, resource information, completion output, and successful execution.

### Latest Test Results

- Tests passed: 11
- Tests failed: 0
- Result: All tests passed

## Process Inspection

To inspect processes ordered by CPU usage:

```bash
ps -eo pid,ppid,user,%cpu,%mem,stat,comm --sort=-%cpu | head -n 15
```

CPU readings for short-lived processes can be temporarily high. Interpret them in context instead of treating a single reading as proof of a problem.

## Security and Reliability Considerations

- The auditor is designed to be read-only.
- A failed service should be investigated before taking corrective action.
- A service being active does not necessarily mean its application is healthy.
- An enabled service is configured to start through its unit's enablement mechanism; this is distinct from its current active state.
- Some services are optional and may not be installed.
- Resource usage should be assessed against the system's workload and available capacity.

## Skills Demonstrated

- Linux service administration with systemd.
- Service-state inspection and troubleshooting.
- Process monitoring.
- Memory, swap, uptime, and filesystem monitoring.
- Bash scripting and command pipelines.
- Automated shell testing.
- Technical documentation.

## Outcome

This module provides a repeatable, tested method for inspecting service health and basic resource conditions on a Linux system without making configuration changes.
