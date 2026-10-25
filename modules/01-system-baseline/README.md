# Module 01 — System Baseline & Health Checks

## Overview

This module establishes a basic system baseline and performs health checks on an Ubuntu Linux environment using Bash scripts.

It demonstrates practical Linux administration skills, system information collection, resource monitoring, and automated diagnostic reporting.

## Objectives

- Collect essential Linux system information.
- Inspect operating system and kernel details.
- Monitor disk and memory utilization.
- Review system uptime and load information.
- Identify failed systemd services.
- Inspect network interface addresses.
- Generate timestamped diagnostic reports.

## Scripts

### 1. System Baseline — `system_baseline.sh`

**Location:** `scripts/system_baseline.sh`

Collects basic information about the Linux system, including:

- Hostname and operating system
- Kernel information
- Current user
- Memory usage
- Disk utilization
- System uptime
- Network interface addresses

The collected information is written to a timestamped report in the project's `reports/` directory.

### 2. System Health — `system_health.sh`

**Location:** `scripts/system_health.sh`

Performs basic system health checks, including:

- Disk utilization
- Memory usage
- System uptime and load information
- Failed systemd services

The script generates a readable report to help identify conditions that may require further investigation.

## Requirements

- Ubuntu Linux or a compatible Linux environment
- Bash
- Standard Linux system utilities
- Access to the system information being inspected

Some checks depend on the commands and services available on the system.

## Usage

Run the commands from the LinuxOps project root:

```bash
bash scripts/system_baseline.sh
```

Run the system health checks:

```bash
bash scripts/system_health.sh
```

After execution, review the generated reports in:

```text
reports/
```

Reports are timestamped to help distinguish between separate runs.

## Testing

The project includes an automated test suite:

```bash
bash tests/test_linuxops.sh
```

This suite checks core LinuxOps functionality. Additional modules have their own test suites.

## Skills Demonstrated

- Linux command-line administration
- Bash scripting
- System information gathering
- Disk and memory monitoring
- System uptime and load inspection
- systemd service-state checks
- Network interface inspection
- Timestamped report generation
- Automated testing

## Limitations

These scripts provide basic diagnostic information; they are not a replacement for a production monitoring platform.

A warning identifies a condition worth reviewing but does not automatically establish that a system is compromised or unhealthy. Results depend on the available system information, permissions, and commands.

## Related Modules

- [Module 02 — Users, Groups & Permissions](../02-users-permissions/README.md)
- [Module 03 — Services & Process Management](../03-services-processes/README.md)
- [Module 04 — Security Log Analysis](../04-security-logs/README.md)
- [Module 05 — Network Troubleshooting](../05-network-troubleshooting/README.md)
