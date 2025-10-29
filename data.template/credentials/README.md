<!--
##############################################################################
# Ansible Connection Credentials
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 28, 2025
##############################################################################
-->

# Ansible Connection Credentials

This directory contains credential files used by Ansible for SSH connections to managed hosts.

## Quick Setup (Recommended)

The easiest way to create encrypted credentials is to use the interactive setup script:

```bash
./scripts/setupCredentials.sh
```

The script will:
1. Prompt for your SSH username (stored in plain text)
2. Prompt for your SSH password (encrypted using Ansible Vault)
3. Prompt for your sudo password (encrypted, defaults to SSH password if blank)
4. Create or prompt for vault password file (`~/.ansible_vault_pass`)
5. Generate `data/credentials/default.yaml` with encrypted passwords
6. Set restrictive permissions (chmod 600)

**Example:**
```bash
$ ./scripts/setupCredentials.sh

========================================
Ansible Credentials Setup
========================================

Enter SSH username: pi
Enter SSH password: [hidden]
Enter sudo password (or press Enter for same as SSH password): [hidden]

Create vault password file now? (y/n): y
Enter vault password (will be saved to ~/.ansible_vault_pass): [hidden]
Confirm vault password: [hidden]

✓ Created ~/.ansible_vault_pass
✓ Created data/credentials/default.yaml (passwords encrypted)
```

After setup, you can run playbooks normally - Ansible automatically decrypts passwords using the vault password file.

## File Structure

Credential files are YAML format with the following structure:

```yaml
userData:
  uid: <username>
  pwd: <password>
  sudoPWD: <sudo_password>
```

## Files in This Directory

**default.yaml**
- Default credentials used when no specific user is specified
- Loaded by the `common` role as the default connection credentials
- **Action required:** Customize with your actual credentials

**<username>.yaml** (optional)
- User-specific credential files
- Loaded when `user` variable is set (e.g., `-e user=admin` loads `admin.yaml`)
- Allows different credentials for different operations

## How Credentials Are Used

Credentials are loaded by the `common` role and used to set Ansible connection variables:

- `ansible_user`: SSH username (from `userData.uid`)
- `ansible_ssh_pass`: SSH password (from `userData.pwd`)
- `sudoPWD`: Password for sudo operations (from `userData.sudoPWD`)

## Security Considerations

**CRITICAL: These files contain sensitive information!**

1. **Never commit to git**
   - Ensure `credentials/` is in your `.gitignore`
   - Keep in private `data/` repository only

2. **File permissions**
   - Set restrictive permissions: `chmod 600 *.yaml`
   - Only owner should read/write

3. **Password storage**
   - Consider using Ansible Vault for additional encryption
   - Or use SSH key authentication instead (see `../keys/` directory)

## SSH Key Authentication (Recommended)

For better security, consider using SSH key authentication instead of passwords:

1. Generate SSH key pair (see `../keys/README.md`)
2. Copy public key to target hosts
3. Remove `ansible_ssh_pass` from playbook usage
4. Ansible will use `ansible_ssh_private_key_file` from `common` role

## Customization Steps

1. **Copy and customize default.yaml**
   ```bash
   # Edit default.yaml with your credentials
   vi default.yaml
   ```

2. **Set proper permissions**
   ```bash
   chmod 600 *.yaml
   ```

3. **Test connection**
   ```bash
   ansible -m ping <hostname>
   ```

4. **(Optional) Create user-specific credential files**
   ```bash
   cp default.yaml admin.yaml
   # Edit admin.yaml with admin-specific credentials
   ```

## External Documentation

- **Ansible Connection Variables:** https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html#connection-variables
- **Ansible Vault:** https://docs.ansible.com/ansible/latest/user_guide/vault.html
- **SSH Key Setup:** See `../keys/README.md`
