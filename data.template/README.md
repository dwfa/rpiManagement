<!--
##############################################################################
# Private Data Directory - Configuration and Credentials
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 3.0
# Date: January 06, 2025
##############################################################################
-->

# Private Data Directory

This directory contains private configuration, credentials, SSH keys, and host-specific data for the Ansible RPi Management Framework. It was created from the `data.template/` directory in the main repository.

## Purpose

The `data/` directory holds all sensitive and environment-specific configuration separate from the public automation code. This follows a **separation of concerns** architecture:
- **Main repository** (rpiMgmnt): Public automation code (version controlled with git)
- **Data directory** (data/): Private credentials and configuration (this directory)

## Directory Structure

| Directory/File | Purpose | Documentation |
|----------------|---------|---------------|
| **.ssh/** | SSH keys and known hosts | [.ssh/README.md](.ssh/README.md) |
| **credentials/** | Encrypted user credential files | [credentials/README.md](credentials/README.md) |
| **images/** | Raspberry Pi OS image storage | [images/README.md](images/README.md) |
| **rpi/** | Boot partition initialization files | [rpi/README.md](rpi/README.md) |
| **inventory.yaml** | Ansible inventory: hosts and groups | See inline documentation |

## Configuration Checklist

Ensure you complete these configuration steps:

1. **Review subdirectory READMEs** → Each directory has detailed setup instructions
2. **Configure inventory.yaml** → Define your hosts and groups

## Optional: Version Control

If you want to track changes to your configuration over time, you can initialize this directory as a git repository:

```bash
cd data/
git init
git add .
git commit -m "Initial data directory setup"
```

If using git, consider adding a private remote repository (GitHub/Bitbucket) to back up your configuration.

## Security Note

This directory contains sensitive information (credentials, SSH keys, network configuration). It is excluded from the main repository via `.gitignore` and should **never** be committed to the public rpiMgmnt repository.

If you choose to use git for version control of your `data/` directory, maintain it as a separate private repository.

---

For questions or issues, refer to the individual subdirectory READMEs or the main project documentation.
