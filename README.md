<!--
##############################################################################
# README for Ansible RPi Management Framework
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 16, 2025
##############################################################################
-->

# Ansible RPi Management Framework

A comprehensive Ansible automation framework for managing Raspberry Pi devices, with specialized support for Unix based systems, starting with MacOS. This project automates the complete lifecycle of RPi deployment from OS image preparation to application and network configuration.

## Features

- **Automated RPi OS Image Management**: Download, verify, and manage Raspberry Pi OS images with checksum validation
- **Device Imaging**: Interactive detection and automated image writing workflows
- **Custom Ansible Modules**: Specialized modules for filesystem operations, drive detection, and BIND DNS configuration
- **Two-Repository Architecture**: Separates public automation code from private credentials and network data
- **Network Automation**: BIND DNS configuration generation and static IP management
- **Flexible Deployment**: Shell script wrappers for common operations with debug/check modes

## Architecture

This project uses a **two-repository architecture** for security and flexibility:

- **Public Repository** (this repo): Contains all Ansible roles, playbooks, custom modules, and shell script wrappers
- **Private Data Repository**: Your separate git repository containing credentials, SSH keys, network configurations, and inventory files

The `data/` directory is excluded from this repository and must be created separately by each user. This design ensures that:
- Automation code can be shared publicly
- Sensitive data (credentials, network topology, SSH keys) remains private
- Multiple users can use the same codebase with their own configurations

## Prerequisites

- Python 3.x
- Ansible 2.9 or later
- Unix based sysem
- Git

## Quick Start

1. **Clone this repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/ansible-rpi-management.git
   cd ansible-rpi-management
   ```

2. **Create your private data repository** - *More information coming soon*

3. **Set up required data directory structure** - *More information coming soon*

4. **What You Can Do:**
   - Prepare RPi images on writable media (USB drives, SD cards, etc.)
   - Configure DNS servers
   - Initialize installer hosts
   - Manage network configurations

   *Examples coming soon*

## License

This project is licensed under the Apache License 2.0 - see [LICENSE.md](LICENSE.md) for details.

## Author

**Douglas WF Acheson**
Email: dwfa@dwfa.ca
Copyright 2025 Douglas WF Acheson

## Notice

Claude code is used to generate comments, automate git actions, commit messages and other small tasks that are time consuming.

---

Licensed under the Apache License, Version 2.0. See LICENSE.md for full license text.
