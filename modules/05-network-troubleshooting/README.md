# Module 05: Network Troubleshooting

## Overview

This module provides a Bash-based network diagnostics tool for inspecting Linux network interfaces, IP addresses, routing, DNS configuration, listening ports, and route selection.

It demonstrates practical Linux administration and network troubleshooting skills through automated checks and timestamped reports.

## Objectives

- Inspect network interfaces and assigned IP addresses.
- Identify whether a default route is configured.
- Review DNS configuration.
- Test system name resolution.
- Inspect listening TCP and UDP ports.
- Examine the route Linux selects for a destination.
- Generate reports for troubleshooting and documentation.
- Validate the tool with automated tests.

## Diagnostic Script

**Script:** `scripts/network_diagnostics.sh`

The script collects information using standard Linux networking utilities, including:

- `ip` — interface addresses and routing information.
- `resolvectl` — DNS resolver status, when available.
- `getent` — system name-resolution testing.
- `ss` — listening TCP and UDP sockets.
- `tee` — simultaneous terminal output and report generation.

The script is read-only and does not modify network settings or restart services.

## Usage

Run the diagnostic script:

```bash
./scripts/network_diagnostics.sh
```

The report is saved under `reports/` with a timestamped filename, for example:

`reports/network_report_2026-10-25_16-34-26.txt`

The actual timestamp depends on when the script runs.

## Diagnostic Sections

### 1. Network Interfaces

Displays available network interfaces and their addresses.

### 2. IPv4 Addresses

Lists IPv4 addresses assigned to network interfaces.

### 3. Routing Table

Displays the routing table and checks whether a default route exists.

### 4. DNS Configuration

Displays DNS resolver status using `resolvectl`, or falls back to `/etc/resolv.conf` when necessary.

### 5. DNS Resolution Test

Uses `getent ahosts example.com` to check whether the system can resolve a domain name.

A failed lookup can result from DNS configuration, connectivity, or resolver issues. It should be investigated rather than treated as definitive proof of a single cause.

### 6. Listening TCP and UDP Ports

Uses `ss -tuln` to display listening TCP sockets and bound UDP sockets.

A listening port is not automatically a security vulnerability. Its purpose, exposure, and associated service should be investigated.

### 7. Route Selection Test

Uses `ip route get 1.1.1.1` to inspect the route Linux would select for the destination.

This command inspects local routing information; it does not itself verify that the destination is reachable.

## Automated Testing

Test script:

`tests/test_network_diagnostics.sh`

Run the tests:

```bash
./tests/test_network_diagnostics.sh
```

The test suite checks:

- Script existence.
- Bash syntax.
- Executable permissions.
- Successful execution.
- Report generation.
- Presence of key diagnostic sections.

**Latest test result:** 10 passed, 0 failed.

These tests validate the script's basic execution and report structure. They do not simulate every possible network outage or failure condition.

## Skills Demonstrated

- Linux network administration.
- IP addressing and interface inspection.
- Routing-table interpretation.
- DNS troubleshooting fundamentals.
- TCP/UDP listening-port inspection.
- Bash scripting and error handling.
- Automated shell-script testing.
- Timestamped report generation.
- Practical troubleshooting documentation.

## Project Structure

```text
linuxops/
├── modules/
│   └── 05-network-troubleshooting/
│       └── README.md
├── reports/
├── scripts/
│   └── network_diagnostics.sh
└── tests/
    └── test_network_diagnostics.sh
```

*This tree highlights the files relevant to Module 05, rather than the entire repository.*
