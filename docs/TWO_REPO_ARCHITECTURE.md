<!--
##############################################################################
# Two-Repository Architecture Guide
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: February 03, 2026
##############################################################################
-->

# Two-Repository Architecture

This document explains an optional advanced pattern for users who want to
version-control their data directory separately from the main repository.

## When to Use This Pattern

Consider this approach if you want to:

- **Share your automation code publicly** while keeping credentials private
- **Maintain separate version history** for code vs. configuration
- **Use different backup strategies** for code and sensitive data
- **Collaborate on automation** while each user maintains their own config

## How It Works

```
project-workspace/
├── rpiMgmt/              # Public git repo (this repository)
│   ├── roles/
│   ├── tasks/
│   ├── playbooks/
│   ├── data/             # Symlink to private repo (or gitignored directory)
│   └── ...
└── my-rpi-data/          # Private git repo (your configuration)
    ├── credentials/
    ├── ssh/
    ├── inventory.yaml
    └── ...
```

## Setup Steps

### 1. Clone the main repository

```bash
git clone https://github.com/YOUR_USERNAME/ansible-rpi-management.git rpiMgmt
cd rpiMgmt
```

### 2. Create your private data repository

```bash
# Create from template
cp -r data.template ../my-rpi-data

# Initialize as git repository
cd ../my-rpi-data
git init
git add .
git commit -m "Initial data directory setup"

# Optional: Add remote (use a private repository!)
git remote add origin git@github.com:YOUR_USERNAME/my-rpi-data-private.git
git push -u origin main
```

### 3. Link data directory

```bash
cd ../rpiMgmt
# Remove the gitignored data directory if it exists
rm -rf data

# Create symlink to your private repo
ln -s ../my-rpi-data data
```

### 4. Configure credentials and inventory

Follow the standard setup process - the symlink makes `data/` point to your
private repository.

## Benefits

- **Security**: Sensitive data never touches the public repository
- **Portability**: Clone main repo anywhere, link to your data repo
- **Collaboration**: Share automation improvements without exposing credentials
- **Backup**: Different backup/sync strategies for code vs. secrets

## Considerations

- Requires managing two git repositories
- Symlinks may not work identically on all systems
- Must remember to commit changes in both repos when applicable

## Alternative: Single Repository (Default)

For personal use where you don't plan to share the automation code, the
simpler approach is:

1. Copy `data.template/` to `data/`
2. The `data/` directory is already in `.gitignore`
3. Optionally back up `data/` separately (rsync, cloud sync, etc.)

This is the default setup described in the main README.