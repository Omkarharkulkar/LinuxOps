# Module 04: Security Log Analysis

## Overview

This module provides Bash-based tools for analyzing Linux authentication logs and identifying suspicious SSH authentication patterns. It demonstrates practical skills in Linux log analysis, text processing, basic security detection, report generation, and automated testing.

## Objectives

- Analyze SSH authentication events.
- Identify failed password attempts, invalid-user events, and successful authentications.
- Group failed SSH attempts by source IP address.
- Flag repeated failed attempts using a configurable threshold.
- Generate readable reports for security review.
- Validate detection logic using automated tests and sample log data.

## Tools and Scripts

### 1. Authentication Log Analyzer

**Script:** `scripts/auth_log_analyzer.sh`

Analyzes authentication logs and reports:

- Failed SSH password attempts.
- SSH attempts involving invalid usernames.
- Successful SSH password or public-key authentications.
- Matching log events for further investigation.

**Run against the system authentication log:**

```bash
bash scripts/auth_log_analyzer.sh
```

**Run against the sample test log:**

```bash
bash scripts/auth_log_analyzer.sh tests/fixtures/sample_auth.log
```

### 2. SSH Source Analyzer

**Script:** `scripts/ssh_source_analyzer.sh`

Analyzes failed SSH password attempts and groups them by source IP address. It also evaluates each source against a threshold to highlight repeated failures.

Current threshold: **2 failed attempts per source IP**.

Example findings:

```text
ALERT: 2 failed attempts from 192.0.2.10 (threshold: 2)
INFO: 1 failed attempt(s) from 198.51.100.20; below threshold.
```

These addresses are reserved for documentation and examples; they do not identify real public hosts.

**Run against the system authentication log:**

```bash
bash scripts/ssh_source_analyzer.sh
```

**Run against the sample test log:**

```bash
bash scripts/ssh_source_analyzer.sh tests/fixtures/sample_auth.log
```

## Sample Data

The test fixture is located at:

`tests/fixtures/sample_auth.log`

It contains representative examples of failed SSH logins, an invalid username, a successful login, and a `sudo` event.

The fixture supports repeatable testing without requiring real attack activity.

## Automated Testing

Run the authentication log analyzer tests:

```bash
./tests/test_auth_log_analyzer.sh
```

Run the SSH source analyzer tests:

```bash
./tests/test_ssh_source_analyzer.sh
```

The SSH source analyzer test suite validates:

- Required files and Bash syntax.
- Successful script execution and report generation.
- Expected failed-attempt counts for source IP addresses.
- Exclusion of successful logins from failed-attempt counts.
- Presence of the threshold findings section.
- Correct alerting at the threshold.
- Correct informational output below the threshold.
- Cautious interpretation of security alerts.

**Latest SSH source analyzer test result:** 11 passed, 0 failed.

## Security Considerations

- A threshold alert is an indicator for investigation, not proof of malicious activity.
- Failed logins can result from mistyped passwords, misconfigured services, or legitimate administrative activity.
- Authentication logs may contain sensitive information and should be handled appropriately.
- Sample log data is used for repeatable testing.
- These scripts support initial triage; they do not replace a full SIEM, correlation engine, or analyst investigation.

## Skills Demonstrated

- Linux authentication log analysis.
- Bash scripting and command-line text processing.
- Regular expressions, `grep`, `awk`, `sort`, and `uniq`.
- Source-IP aggregation and threshold-based detection.
- Report generation and basic security triage.
- Automated shell-script testing.
- Security-conscious interpretation of findings.

## Project Structure

```text
linuxops/
├── modules/
│   └── 04-security-logs/
│       └── README.md
├── reports/
├── scripts/
│   ├── auth_log_analyzer.sh
│   └── ssh_source_analyzer.sh
└── tests/
    ├── fixtures/
    │   └── sample_auth.log
    ├── test_auth_log_analyzer.sh
    └── test_ssh_source_analyzer.sh
```

*Note: This structure shows the main files relevant to this module, not every file in the LinuxOps repository.*
