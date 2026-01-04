<!--
##############################################################################
# SSH Configuration Directory
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 5.0
# Date: January 06, 2025
##############################################################################
-->

# SSH Directory

This directory holds all SSH-related files for Ansible automation.

## Files in This Directory

**ssh_key**
- SSH private key for authentication
- Must be replaced with your actual private key
- Requires 600 permissions (owner read/write only)
- See inline instructions in the file for setup steps

**knownHosts**
- Stores SSH host keys from managed RPi devices
- Auto-created on first Ansible connection (no manual setup needed)
- Cleared by `clearLocal` role before re-imaging operations
- Prevents "host key verification failed" errors

## Quick Setup

1. Generate SSH key pair (if needed):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/ansible_rpi
   ```

2. Copy private key to this directory:
   ```bash
   cp ~/.ssh/ansible_rpi data/ssh/ssh_key
   chmod 600 data/ssh/ssh_key
   ```

3. The knownHosts file will be created automatically on first Ansible connection.

**Note:** Ansible currently uses password authentication (configured in `data/credentials/`). SSH key-based authentication to RPi hosts is planned for a future release.

## Before Re-imaging

Run the `clearLocal` role to clear old host keys from knownHosts file.
