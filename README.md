# LinuxOps — Linux Security Log Analyzer & System Administration Lab

## Project Overview

LinuxOps is a hands-on Linux administration and security log analysis project built in an Ubuntu virtual machine.

The project uses Bash scripting to automate system health checks, collect system information, analyze SSH authentication logs, identify repeated failed login attempts, and generate reports.

It demonstrates practical Linux command-line skills, Bash scripting, log analysis, troubleshooting, and automated testing.

## Objectives

- Automate Linux system information collection.
- Monitor disk and memory usage.
- Identify failed systemd services.
- Analyze SSH authentication events.
- Identify source IP addresses associated with failed SSH login attempts.
- Generate timestamped reports.
- Validate scripts using automated tests.
- Build practical Linux administration and security analysis skills.

## Technology Stack

- Operating System: Ubuntu Linux
- Virtualization: Oracle VirtualBox
- Scripting Language: Bash
- Log Sources: Linux authentication logs
- Testing: Bash-based automated tests
- Version Control: Git and GitHub (planned)

## Project Features

### 1. System Baseline Collection

The system baseline script collects information about the Linux environment, including:

- Hostname and operating system details
- Kernel information
- Current user
- Memory usage
- Disk utilization
- System uptime
- Network interface addresses

The collected information is saved to a timestamped report.

### 2. System Health Monitoring

The system health script checks:

- Disk utilization
- Memory usage
- System uptime and load information
- Failed systemd services

The script generates a readable health report to help identify potential system issues.

### 3. SSH Authentication Log Analysis

The authentication log analyzer examines SSH-related authentication events, including:

- Failed SSH password attempts
- Attempts involving invalid usernames
- Successful SSH authentications

The analysis is limited to matching events present in the available log source.

### 4. SSH Source IP Analysis

The SSH source analyzer identifies IP addresses associated with failed SSH password attempts.

It groups matching events by source IP and counts the number of failed attempts.

Repeated failures may warrant further investigation, but counts alone do not establish malicious activity.

### 5. Automated Testing

The project includes automated tests that validate:

- Required scripts and sample log files
- Bash syntax
- Script execution
- Report generation
- Failed SSH attempt counts
- Exclusion of successful SSH logins from failed-attempt counts

Synthetic authentication logs are used to test the analyzer when the VM's real logs do not contain suitable events.

## Project Structure

```text
linuxops/
├── README.md
├── scripts/
│   ├── system_baseline.sh
│   ├── system_health.sh
│   ├── auth_log_analyzer.sh
│   └── ssh_source_analyzer.sh
├── modules/
│   ├── 01-system-baseline/
│   ├── 02-users-permissions/
│   ├── 03-services-processes/
│   ├── 04-security-logs/
│   └── 05-network-troubleshooting/
├── reports/
├── tests/
│   ├── fixtures/
│   │   └── sample_auth.log
│   ├── test_linuxops.sh
│   └── test_ssh_source_analyzer.sh
└── screenshots/
