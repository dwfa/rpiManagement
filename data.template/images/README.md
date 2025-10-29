<!--
##############################################################################
# Raspberry Pi OS Images
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 28, 2025
##############################################################################
-->

# Raspberry Pi OS Images

This directory stores Raspberry Pi OS image files used for SD card creation.

## Purpose

The `updateRPiImage` role automatically downloads and manages RPi OS images in this directory. Images are large files (typically 2-4 GB) and should not be committed to git.

## Files in This Directory

**currentRPiImage.img** (symlink)
- Symlink pointing to the active RPi OS image
- Referenced by `createRPiImage` role via `imagePath` variable
- Automatically created/updated by `updateRPiImage` role

**Example image files:**
- `2025-10-01-raspios-trixie-arm64-lite.img` - Current image (symlink target)
- `2024-01-01-raspios-bookworm-arm64-lite.img` - Older image (kept for rollback)

## How Images Are Managed

### Automatic Download (Recommended)

The `updateRPiImage` role handles image management:

1. Downloads latest RPi OS image from official source
2. Decompresses image (.img.xz → .img)
3. Creates/updates `currentRPiImage.img` symlink
4. Verifies image integrity

**To download latest image:**
```bash
# Run updateRPiImage role (via playbook)
ansible-playbook playbooks/updateImage-pb.yaml

# Or run as part of createImage workflow
./scripts/createImage.sh
```

### Manual Download (If Needed)

If you need to manually download an image:

1. **Download from Raspberry Pi official site:**
   https://www.raspberrypi.com/software/operating-systems/

2. **Place image in this directory:**
   ```bash
   # If compressed (.img.xz)
   cp ~/Downloads/raspios-image.img.xz data/images/
   xz -d data/images/raspios-image.img.xz

   # If already decompressed (.img)
   cp ~/Downloads/raspios-image.img data/images/
   ```

3. **Create symlink:**
   ```bash
   cd data/images/
   ln -sf raspios-image.img currentRPiImage.img
   ```

## Available RPi OS Variants

Choose based on your needs:

- **Lite** (recommended for servers): No desktop environment, minimal size (~500MB compressed)
- **Desktop**: Full desktop environment (~1.5GB compressed)
- **Full**: Desktop + recommended software (~2.5GB compressed)

**Architecture:**
- **arm64** (64-bit): Recommended for RPi 3, 4, 5, 400, CM4, CM5
- **armhf** (32-bit): For older RPi models or 32-bit compatibility

## Image Lifecycle

1. **Download:** `updateRPiImage` role downloads latest image
2. **Decompress:** `.img.xz` → `.img` (automatic)
3. **Symlink:** `currentRPiImage.img` points to latest
4. **Use:** `createRPiImage` role writes image to SD card
5. **Retain:** Old images kept for rollback (manual cleanup)

## Storage Considerations

- **Single image:** ~500MB - 2.5GB (compressed: ~200MB - 1GB)
- **Multiple images:** Can accumulate over time
- **Cleanup:** Manually delete old `.img` files when no longer needed
  ```bash
  # List images by date
  ls -lht data/images/*.img

  # Remove old images
  rm data/images/2024-01-01-raspios-*.img
  ```

## Git Ignore

This directory should be excluded from git (large binary files):

```gitignore
# In data/.gitignore (if using separate data repo)
images/*.img
images/*.img.xz
```

## Verification

To verify your image setup:

```bash
# Check symlink points to valid image
ls -lh data/images/currentRPiImage.img

# Should show symlink and target, e.g.:
# currentRPiImage.img -> 2025-10-01-raspios-trixie-arm64-lite.img

# Verify image file exists and size
ls -lh data/images/*.img
```

## Troubleshooting

**"Image not found" error**
- Run `updateRPiImage` role to download image
- Or manually download and create symlink

**"Symlink broken" (red in ls -l)**
- Target image file deleted
- Re-download image or fix symlink target

**"Decompression failed"**
- Corrupted download
- Delete `.img.xz` and re-download

## External Documentation

- **RPi OS Downloads:** https://www.raspberrypi.com/software/operating-systems/
- **RPi OS Release Notes:** https://www.raspberrypi.com/news/
- **Image Installation Guide:** https://www.raspberrypi.com/documentation/computers/getting-started.html
