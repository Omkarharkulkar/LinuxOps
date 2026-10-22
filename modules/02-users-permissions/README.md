# Module 02: Users, Groups & Permissions

## Overview

This module demonstrates Linux user and group administration, file ownership, permission management, and basic security auditing using Bash.

The lab uses a dedicated test user and group to demonstrate how Linux access controls protect shared directories and their contents.

## Objectives

- Inspect user identities, group memberships, and sudo privileges.
- Create and manage Linux users and groups.
- Configure shared-directory ownership and permissions.
- Understand supplementary groups and the setgid directory bit.
- Apply `chmod`, `chown`, and `chgrp` to manage access.
- Automate permission checks using a read-only Bash audit script.
- Validate expected behavior with automated tests.

## Lab Environment

- OS: Ubuntu 24.04 LTS
- Platform: VirtualBox
- Shell: Bash
- Project directory: `~/linuxops`

## Implementation

### 1. User and group administration

Created a dedicated lab group, `linuxops_lab`, and a test user, `linuxops_test`. Added the test user to the lab group as a supplementary group.

### 2. Shared-directory access controls

Configured `/opt/linuxops-lab/shared` with:

- Owner: `root`
- Group: `linuxops_lab`
- Permissions: `2770`

The setgid bit ensures that new files and subdirectories inherit the directory's group. Permissions `770` allow the owner and group full access while denying access to others.

### 3. File permission management

Created a test file as the lab user and applied permissions `660`, allowing the owner and group to read and write the file while denying access to others.

Practiced using `chmod`, `chown`, and `chgrp` to manage permissions and ownership.

### 4. User and permission audit

Implemented `scripts/user_audit.sh`, a read-only Bash script that:

- Checks whether a specified user and group exist.
- Displays the target directory's owner, group, and permissions.
- Warns when the directory is writable by others.
- Reports whether other users have directory traversal permission.
- Supports optional user, group, and directory arguments.

Example:

```bash
./scripts/user_audit.sh
./scripts/user_audit.sh root root /tmp
```

### 5. Automated testing

Implemented `tests/test_user_audit.sh` to validate user and group detection, expected directory permissions, security warnings, and handling of nonexistent users, groups, and directories.

Run the tests with:

```bash
./tests/test_user_audit.sh
```

## Key Linux Concepts Demonstrated

- Linux users, primary groups, and supplementary groups
- File and directory ownership
- Symbolic and numeric permissions
- Setgid directory permissions
- Directory write and traversal permissions
- Bash scripting, conditional logic, and exit-status checking
- Automated functional testing

## Security Considerations

The lab uses a dedicated test account and group rather than modifying the primary account. The audit script reports potential permission concerns but does not automatically change system permissions.

The `/tmp` directory is used as a test case for world-writable directory detection. Its sticky bit helps protect files from deletion or renaming by other ordinary users.

## Outcome

This module demonstrates practical Linux account administration, access-control configuration, Bash automation, and basic security auditing in a controlled virtual-machine environment.
