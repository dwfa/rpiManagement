<!--
##############################################################################
# Raspberry Pi OS Images
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.0
# Date: January 06, 2025
##############################################################################
-->

# Raspberry Pi OS Images

This directory stores Raspberry Pi OS image files. Images are excluded from git.

## Files in This Directory

### currentRPiImage.img (symlink)

- Points to the active RPi OS image used by createRPiImage role
- Automatically managed by updateRPiImage role

### Image files

Format: `YYYY-MM-DD-raspios-<release>-<arch>-<variant>.img`

## Download Images

```bash
ansible-playbook playbooks/updateImage-pb.yaml
```

The updateRPiImage role downloads, decompresses, and creates the symlink automatically.

## Image Variants

- **Lite**: No desktop (recommended for servers)
- **Desktop**: With desktop environment
- **Full**: Desktop + additional software

Use arm64 for RPi 3/4/5 or armhf for older models.

## Troubleshooting

**Image not found:** Run updateRPiImage role to download

**Broken symlink:** Re-download image or fix symlink target

**Decompression failed:** Delete `.img.xz` and re-download
