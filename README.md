<!--
##############################################################################
# README for Ansible RPi Management Framework
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.3
# Date: August 01, 2026
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

This project uses a **git submodule** to separate public automation code
from private configuration:

- **Main repo** (this one): Ansible roles, playbooks, custom modules, and
  scripts.
- **`data/` submodule**: your private repo containing credentials, SSH
  keys, inventory, and host configs. The main repo pins a specific
  `data/` commit, so automation code and configuration stay paired.

Clone with `--recurse-submodules` (or run `git submodule update --init`
after cloning) to populate `data/`. First-time users without a private
data repo yet can bootstrap from `data.template/` — see Quick Start.

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

1. **Clone this repository (with submodules):**

   ```bash
   git clone --recurse-submodules \
       https://github.com/YOUR_USERNAME/ansible-rpi-management.git
   cd ansible-rpi-management
   ```

   If you already cloned without `--recurse-submodules`, run
   `git submodule update --init` inside the repo.

2. **First-time users only — bootstrap `data/` from the template:**

   The `data/` submodule points to a private repo you own. If you don't
   have one yet:

   ```bash
   cp -r data.template data
   cd data && git init && git add . && git commit -m "Initial data setup"
   # push to your own private remote, then wire it in as the submodule
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
