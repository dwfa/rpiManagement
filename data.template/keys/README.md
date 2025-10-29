<!--
##############################################################################
# SSH Private Keys for Ansible Connections
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 28, 2025
##############################################################################
-->

# SSH Private Keys

This directory contains SSH private keys used by Ansible for passwordless authentication to managed hosts.

## Files in This Directory

**ssh.key**
- Primary SSH private key for Ansible connections
- Referenced in `common` role via `ansible_ssh_private_key_file` variable
- **Action required:** Replace template with your actual SSH private key

## SSH Key Authentication

SSH key authentication is **more secure** than password authentication:

- No password transmitted over network
- Keys can be longer and more complex than passwords
- Can be easily revoked without changing passwords
- Required for automated workflows without interactive password prompts

## Setting Up SSH Key Authentication

### Step 1: Generate SSH Key Pair (if you don't have one)

```bash
# Generate new ED25519 key (recommended, more secure)
ssh-keygen -t ed25519 -C "your_email@example.com" -f ~/.ssh/ansible_rpi

# OR generate RSA key (widely compatible)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/ansible_rpi
```

This creates two files:
- `~/.ssh/ansible_rpi` - Private key (keep secret!)
- `~/.ssh/ansible_rpi.pub` - Public key (copy to target hosts)

### Step 2: Copy Private Key to This Directory

```bash
# Copy your private key to data/keys/
cp ~/.ssh/ansible_rpi /path/to/rpiMgmnt/data/keys/ssh.key

# Set restrictive permissions (required by SSH)
chmod 600 /path/to/rpiMgmnt/data/keys/ssh.key
```

### Step 3: Install Public Key on Target Hosts

```bash
# Method A - Using ssh-copy-id (easiest)
ssh-copy-id -i ~/.ssh/ansible_rpi.pub user@hostname

# Method B - Manual copy
cat ~/.ssh/ansible_rpi.pub | ssh user@hostname 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'

# Method C - For Raspberry Pi first boot (add to userconf)
# Include public key in data/rpi/userconf.txt configuration
```

### Step 4: Test SSH Key Authentication

```bash
# Test direct SSH connection
ssh -i data/keys/ssh.key user@hostname

# Test Ansible connection
ansible -m ping hostname
```

## Security Considerations

**CRITICAL: This directory contains your private key!**

1. **Never commit to git**
   - Ensure `keys/` is in your `.gitignore`
   - Keep in private `data/` repository only

2. **File permissions**
   - Private key MUST be 600 (read/write for owner only)
   - SSH will refuse to use key if permissions are too open
   ```bash
   chmod 600 ssh.key
   ```

3. **Key protection**
   - Use passphrase when generating key (optional but recommended)
   - Ansible can use ssh-agent to avoid re-entering passphrase
   - Never share private key with anyone

4. **Key rotation**
   - Periodically generate new keys and replace old ones
   - Remove old public keys from target hosts

## Ansible Integration

The `common` role automatically configures Ansible to use this key:

```yaml
# From roles/common/vars/main.yaml
ansible_ssh_private_key_file: "{{ dataDir }}/keys/ssh.key"
```

If this file exists and has correct permissions, Ansible will use key authentication instead of password authentication.

## Multiple Keys (Advanced)

If you need different keys for different hosts:

1. Create multiple key files: `ssh.key`, `admin.key`, `backup.key`
2. Override `ansible_ssh_private_key_file` in host/group vars
3. Or use SSH config file (`~/.ssh/config`) to specify keys per host

## Troubleshooting

**"WARNING: UNPROTECTED PRIVATE KEY FILE!"**
- Fix: `chmod 600 ssh.key`

**"Permission denied (publickey)"**
- Verify public key is in `~/.ssh/authorized_keys` on target host
- Check target host's `/var/log/auth.log` for details
- Ensure target host's `~/.ssh` directory is 700 and `authorized_keys` is 600

**"Could not open a connection to your authentication agent"**
- Start ssh-agent: `eval $(ssh-agent)`
- Add key: `ssh-add data/keys/ssh.key`

## External Documentation

- **SSH Keygen Manual:** `man ssh-keygen` or https://man.openbsd.org/ssh-keygen
- **GitHub SSH Guide:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **Ansible SSH Connection:** https://docs.ansible.com/ansible/latest/user_guide/connection_details.html
