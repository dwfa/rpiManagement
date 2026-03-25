<!--
##############################################################################
# README for Ansible RPi Management Framework
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.2
# Date: February 03, 2026
##############################################################################
-->

# Ansible RPi Management Framework

A comprehensive Ansible automation framework for managing Raspberry Pi
devices, with specialized support for Unix based systems, starting with MacOS.
This project automates the complete lifecycle of RPi deployment from OS image
preparation to application and network configuration.

## Features

- **Automated RPi OS Image Management**: Download, verify, and manage Raspberry
  Pi OS images with checksum validation
- **Device Imaging**: Interactive detection and automated image writing workflows
- **Custom Ansible Modules**: Specialized modules for filesystem operations and
  drive detection
- **Secure Configuration**: Separates automation code from private credentials
  and network data
- **Flexible Deployment**: Shell script wrappers for common operations with
  debug/check modes

## Architecture

This project separates automation code from configuration:

- **This directory**: Ansible roles, playbooks, custom modules, and scripts
- **data/ directory**: Your credentials, SSH keys, inventory, and host configs

The `data/` directory is excluded from version control (via `.gitignore`) and
created from `data.template/` during setup. This keeps your sensitive
configuration private.

**Optional**: For advanced users who want to version-control their data
directory separately (e.g., to share automation code publicly while keeping
credentials private), see [docs/TWO_REPO_ARCHITECTURE.md](docs/TWO_REPO_ARCHITECTURE.md)

## Prerequisites

- Python 3.x
- Ansible 2.9 or later
- Unix-based system (macOS or Linux)
- Git
- `sshpass` — required for password-based SSH to fresh RPi hosts
  (before SSH keys are deployed)
  - macOS: `brew install hudochenkov/sshpass/sshpass`
  - Linux: install via your package manager (e.g., `apt install sshpass`)

## Quick Start

1. **Clone this repository:**

   ```bash
   git clone https://github.com/YOUR_USERNAME/ansible-rpi-management.git
   cd ansible-rpi-management
   ```

2. **Create your data directory from template:**

   ```bash
   cp -r data.template data
   ```

3. **Set up credentials** (creates encrypted credential file):

   ```bash
   ./scripts/setupCredentials.sh
   ```

4. **Configure your inventory** - Edit `data/inventory.yaml` with your hosts:

   ```yaml
   all:
     children:
       rpi:
         hosts:
           mypi:
             ansible_host: 192.168.1.100
   ```

5. **Run a playbook:**

   ```bash
   ./createImage.sh      # Write RPi image to target device
   ```

See [data.template/README.md](data.template/README.md) for detailed
data directory configuration.

## What You Can Do

- **Create RPi images**: Write OS images to target devices (SD cards, USB
  drives) with pre-configured settings (SSH enabled, user credentials)
- **Automate deployment**: Consistent, repeatable RPi setup across your fleet

## License

This project is licensed under the Apache License 2.0 - see
[LICENSE.md](LICENSE.md) for details.

## Author

**Douglas WF Acheson**
Email: dwfa@dwfa.ca
Copyright 2025 Douglas WF Acheson

## Notice

Claude code is used to generate comments, automate git actions, commit
messages and other small tasks that are time consuming.

---

Licensed under the Apache License, Version 2.0. See LICENSE.md for full
license text.
