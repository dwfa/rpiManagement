<!--
##############################################################################
# Raspberry Pi Boot Partition Configuration
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 28, 2025
##############################################################################
-->

# Raspberry Pi Boot Configuration Files

This directory contains configuration files and initialization files that are copied to the RPi boot partition during image creation.

## Files in This Directory

### Configuration Files (Used by Ansible)

**metadata.yaml**
- Defines which initialization files to copy to the boot partition
- Specifies source and destination directories
- Configure the `initFiles` section to control which files are copied
- See file comments for detailed structure

**cmdline-txt-mods.yaml**
- Defines modifications to apply to `/boot/cmdline.txt` (kernel boot parameters)
- Contains kernel command-line arguments like video resolution settings
- Uses regex patterns for idempotent modifications
- See file comments for available operations

### Initialization Files (Copied to Boot Partition)

**ssh**
- Empty file that enables SSH on first boot
- Raspberry Pi OS checks for this file and enables SSH service if present
- **Action required:** Leave as-is (empty file)

**userconf.txt**
- Contains encrypted user credentials for first boot
- Format: `username:encrypted_password`
- **Action required:** Customize with your username and encrypted password
- See instructions in the template file for password encryption

## Customization Steps

1. **Review metadata.yaml**
   - Verify which files should be copied to boot partition
   - Add or remove files from `initFiles` section as needed

2. **Customize cmdline-txt-mods.yaml**
   - Review video console settings (or comment out if not needed)
   - Add any additional kernel boot parameters

3. **Create userconf.txt**
   - Replace TODO markers with your username
   - Generate encrypted password using `openssl passwd -6`
   - Format: `username:encrypted_password_hash`

## External Documentation

- **Raspberry Pi First Boot Configuration:** https://www.raspberrypi.com/documentation/computers/configuration.html
- **Kernel Command Line (cmdline.txt):** https://www.raspberrypi.com/documentation/computers/config_txt.html#kernel-command-line-cmdline-txt
- **Password Encryption:** Run `openssl passwd -6` or `mkpasswd -m sha-512`
