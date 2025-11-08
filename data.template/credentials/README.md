<!--
##############################################################################
# Ansible Connection Credentials
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.3
# Date: January 06, 2025
##############################################################################
-->

# Ansible Connection Credentials

This directory contains credential files for SSH connections to managed hosts.

## Files in This Directory

### default.yaml

- Default credentials used when no specific user is specified
- Must be customized with your actual credentials

### <username>.yaml (optional)

- User-specific credential files
- Loaded when `user` variable is set (e.g., `-e user=admin`)

## File Structure

```yaml
userData:
  uid: <username>
  pwd: <password>
  sudoPWD: <sudo_password>
```

## Quick Setup

### Automated (Recommended)

```bash
./scripts/setupCredentials.sh
```

This script creates encrypted credentials using Ansible Vault.

### Manual

1. Edit `default.yaml` with your credentials
2. Set permissions: `chmod 600 *.yaml`

## How Credentials Are Used

Loaded by the `common` role to set Ansible connection variables:

- `ansible_user`: SSH username (from `userData.uid`)
- `ansible_ssh_pass`: SSH password (from `userData.pwd`)
- `ansible_become_password`: Sudo password (from `userData.sudoPWD`)

## Security Note

These files contain sensitive information:

- Never commit to git (ensure in `.gitignore`)
- Set restrictive permissions: `chmod 600 *.yaml`
- Consider using Ansible Vault for encryption
- For SSH key authentication, see `../.ssh/README.md`
