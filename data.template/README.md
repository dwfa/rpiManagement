<!--
##############################################################################
# Private Data Directory - Configuration and Credentials
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 3.1
# Date: January 08, 2025
##############################################################################
-->

# Private Data Directory

This directory contains private configuration, credentials, SSH keys, and
host-specific data for the Ansible RPi Management Framework.

## Purpose

Separates sensitive configuration from public automation code:

- **Main repository** (rpiMgmnt): Public automation code (version controlled)
- **Data directory** (data/): Private credentials and configuration

## Directory Structure

| Directory/File | Purpose | Documentation |
|----------------|---------|---------------|
| **.ssh/** | SSH keys and known hosts | [.ssh/README.md](.ssh/README.md) |
| **credentials/** | Encrypted user credential files | [credentials/README.md](credentials/README.md) |
| **images/** | Raspberry Pi OS image storage | [images/README.md](images/README.md) |
| **rpi/** | Boot partition initialization files | [rpi/README.md](rpi/README.md) |
| **inventory.yaml** | Ansible inventory: hosts and groups | See inline documentation |

## Configuration Checklist

1. **Review subdirectory READMEs** → Each directory has detailed setup instructions
2. **Configure inventory.yaml** → Define your hosts and groups

## Optional: Version Control

Initialize this directory as a git repository to track configuration changes:

```bash
cd data/
git init
git add .
git commit -m "Initial data directory setup"
```

If using git, consider adding a private remote repository
(GitHub/Bitbucket) to back up your configuration.

## Security Note

This directory contains sensitive information (credentials, SSH keys,
network configuration). It is excluded from the main repository via
`.gitignore` and should **never** be committed to the public rpiMgmnt
repository.

If you choose to use git for version control of your `data/`
directory, maintain it as a separate private repository.

---

For questions or issues, refer to the individual subdirectory READMEs
or the main project documentation.
