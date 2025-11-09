<!--
##############################################################################
# Raspberry Pi Initial Boot Configuration
#
# This directory contains configuration files copied to the RPi boot
# partition during image creation.
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.1
# Date: January 06, 2025
##############################################################################
-->

# Files in This Directory

## Configuration Files

### metadata.yaml

- Defines which initialization files to copy to boot partition
- Configure the `_initFiles` section to control which files are copied
- See file comments for structure

### cmdline-txt-mods.yaml

- Defines modifications to `/boot/cmdline.txt` (kernel boot parameters)
- Uses regex patterns for idempotent modifications
- See file comments for available operations

## Initialization Files

### ssh

- Empty file that enables SSH service on first boot
- Leave as-is (empty file)

### userconf.txt

- Contains encrypted user credentials for first boot
- Format: `username:encrypted_password`
- See instructions in the template file for password encryption

## Customization Steps

1. **Configure metadata.yaml** → Review `_initFiles` section
2. **Customize userconf.txt** → Replace TODO with your username and encrypted password
3. **Customize cmdline-txt-mods.yaml** → Review video console settings

## External Documentation

- [RPi First Boot Configuration](https://www.raspberrypi.com/documentation/computers/configuration.html)
- [Kernel Command Line](https://www.raspberrypi.com/documentation/computers/config_txt.html#kernel-command-line-cmdline-txt)
