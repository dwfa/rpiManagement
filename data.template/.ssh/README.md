<!--
##############################################################################
# SSH Known Hosts Management
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 28, 2025
##############################################################################
-->

# SSH Known Hosts

This directory contains SSH known hosts file managed by Ansible during playbook execution.

## Purpose

Stores SSH host keys for managed Raspberry Pi devices to prevent "host key verification failed" errors and MITM warnings.

## Files in This Directory

**knownHosts**
- SSH known hosts file (similar to `~/.ssh/known_hosts`)
- Automatically created and managed by the `clearLocal` role
- Referenced by `common` role via `ansible_ssh_common_args` variable
- **Do not manually edit this file**

## How This Works

### Ansible Configuration

The `common` role configures Ansible to use this separate known_hosts file:

```yaml
# From roles/common/vars/main.yaml
ansible_ssh_common_args: "-o UserKnownHostsFile={{ dataDir }}/.ssh/knownHosts"
```

This isolates RPi host keys from your personal `~/.ssh/known_hosts` file.

### Host Key Management Workflow

1. **First Connection:**
   - Ansible connects to new RPi host
   - Host key automatically added to `knownHosts` file
   - Future connections verify against stored key

2. **Cleaning (clearLocal role):**
   - Removes all entries from `knownHosts` file
   - Used before re-imaging RPis (host keys will change)
   - Prevents "host key changed" warnings

3. **Re-imaging Workflow:**
   - Before writing new image: `clearLocal` role clears known hosts
   - After first boot: New host key automatically added
   - No manual intervention needed

## When Host Keys Change

Host keys change when you:
- Re-image an SD card
- Reinstall RPi OS
- Change hostname/IP that maps to existing entry

**Symptom:** "WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"

**Solutions:**

**Option A - Use clearLocal role (recommended):**
```bash
# Include in playbook before re-imaging
- hosts: localhost
  roles:
    - clearLocal
```

**Option B - Manually remove specific host:**
```bash
ssh-keygen -f data/.ssh/knownHosts -R hostname
ssh-keygen -f data/.ssh/knownHosts -R 192.168.2.17
```

**Option C - Clear all hosts:**
```bash
rm data/.ssh/knownHosts
# Will be recreated on next connection
```

## Why Separate knownHosts File?

**Benefits:**

1. **Isolation:** RPi host keys separate from personal SSH keys
2. **Clean management:** Easy to clear all RPi keys without affecting personal connections
3. **Version control:** Can track in git without exposing personal known_hosts
4. **Portability:** Project-specific known_hosts travels with the repo

**Personal ~/.ssh/known_hosts remains untouched**

## Git Ignore

This file is dynamically generated and typically excluded from git:

```gitignore
# In data/.gitignore (if using separate data repo)
.ssh/knownHosts
```

However, some projects choose to commit known_hosts for consistency across team members.

## Security Considerations

**Purpose of Known Hosts:**
- Protects against man-in-the-middle (MITM) attacks
- Verifies you're connecting to the same host each time
- Detects if host key changes unexpectedly

**Host Key Verification:**
- First connection: SSH asks to verify host key fingerprint
- Ansible auto-accepts on first connection (StrictHostKeyChecking=accept-new)
- Subsequent connections: SSH verifies against stored key

**When to be concerned:**
- Host key changed warning when you DIDN'T re-image
- Could indicate MITM attack or network issue
- Verify host key fingerprint on the device console before accepting

## File Format

Standard OpenSSH known_hosts format:

```
hostname ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbCdEfGhIjKlMnOpQrStUvWxYz
192.168.2.17 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC...
```

Each line contains:
- Hostname or IP
- Key type (ssh-ed25519, ssh-rsa, ecdsa-sha2-nistp256)
- Base64-encoded public key

## Troubleshooting

**"No such file or directory: knownHosts"**
- File will be created automatically on first Ansible connection
- Or manually: `touch data/.ssh/knownHosts`

**"WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!"**
- Expected after re-imaging
- Run `clearLocal` role or manually remove entry
- Verify host key if you didn't re-image

**Permission denied**
- Ensure directory exists: `mkdir -p data/.ssh`
- Check write permissions

## External Documentation

- **SSH Known Hosts:** `man ssh` (search for "known_hosts")
- **Ansible SSH Configuration:** https://docs.ansible.com/ansible/latest/reference_appendices/config.html#envvar-ANSIBLE_SSH_ARGS
- **SSH Security Best Practices:** https://www.ssh.com/academy/ssh/host-key
