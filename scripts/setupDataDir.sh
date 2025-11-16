#!/bin/bash
##############################################################################
# Initialize data directory from template
#
# USAGE:
#   ./scripts/setupDataDir.sh [--dry-run] [--help]
#
# DESCRIPTION:
#   Copies data.template/ directory to data/ to initialize the project
#   configuration structure. Creates all necessary directories and template
#   files for Ansible automation.
#
# OPTIONS:
#   --dry-run   Show what would be created without actually creating
#   --help      Display this help message
#
# WORKFLOW:
#   1. Verify script is run from project root
#   2. Check if data/ directory already exists (exit if present)
#   3. Copy data.template/ to data/
#   4. Set restrictive permissions on sensitive files
#   5. Display summary and next steps
#
# EXIT CODES:
#   0   - Success (directory created or already exists)
#   101 - Failed to navigate to project root
#   102 - data.template/ directory not found
#   103 - Copy operation failed
#
# NOTES:
#   - Will NOT overwrite existing data/ directory (idempotent safety)
#   - Sets chmod 600 on credentials and SSH key files
#   - Can be run from any directory (auto-navigates to project root)
#   - Uses printf for macOS bash compatibility
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.5
# Date: October 28, 2025
##############################################################################

##############################################################################
# Source colour definitions
##############################################################################
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${scriptDir}/colours.sh"

##############################################################################
# Parse command line arguments
##############################################################################
dryRun=false
showHelp=false

for arg in "$@"; do
  case $arg in
    --dry-run)
      dryRun=true
      shift
      ;;
    --help)
      showHelp=true
      shift
      ;;
    *)
      printf "%b" \
             "${RED_COLOUR}[ERROR] *** Unknown option: $arg${NORMAL_COLOUR}\n"
      showHelp=true
      shift
      ;;
  esac
done

##############################################################################
# Display help
##############################################################################
if [ "$showHelp" = true ]; then
  cat <<'EOF'

USAGE:
  ./scripts/setupDataDir.sh [--dry-run] [--help]

OPTIONS:
  --dry-run   Show what would be created without actually creating
  --help      Display this help message

DESCRIPTION:
  Initializes data/ directory from data.template/ with all necessary
  configuration files and directory structure for Ansible automation.

EXAMPLES:
  ./scripts/setupDataDir.sh              # Create data/ directory
  ./scripts/setupDataDir.sh --dry-run    # Preview what would be created

EOF
  exit 0
fi

##############################################################################
# Change to project root (parent of scripts/ directory)
##############################################################################
projectRoot="$(dirname "${scriptDir}")"
cd "${projectRoot}" || {
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** Failed to change to project root: " \
         "${projectRoot}${NORMAL_COLOUR}\n"
  exit 101
}

##############################################################################
# Check if data.template/ exists
##############################################################################
if [ ! -d "data.template" ]; then
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** data.template/ directory not found\n" \
         "${YELLOW_COLOUR}[INFO] *** Expected to find: data.template/ in " \
         "project root${NORMAL_COLOUR}\n"
  exit 102
fi

##############################################################################
# Check if data/ already exists
##############################################################################
if [ -d "data" ]; then
  printf "%b" \
         "${YELLOW_COLOUR}[WARNING] *** data/ directory already exists\n" \
         "[INFO] *** This script will NOT overwrite existing data/ " \
         "directory\n" \
         "[INFO] *** To reinitialize, manually remove or rename data/ " \
         "first${NORMAL_COLOUR}\n"
  exit 0
fi

##############################################################################
# Display operation mode
##############################################################################
if [ "$dryRun" = true ]; then
  printf "%b\n" \
         "${CYAN_COLOUR}[DRY-RUN] *** Showing what would be created (no " \
         "changes will be made)${NORMAL_COLOUR}"
fi

##############################################################################
# Copy data.template/ to data/
##############################################################################
printf "\n%b\n" \
       "${GREEN_COLOUR}[INFO] *** Initializing data/ directory from " \
       "template${NORMAL_COLOUR}"

if [ "$dryRun" = true ]; then
  printf "%b" \
         "${CYAN_COLOUR}[DRY-RUN] *** Would create: data/\n" \
         "[DRY-RUN] *** Would copy: data.template/ → data/${NORMAL_COLOUR}\n"

  # Show directory tree that would be created
  printf "\n%b\n" \
         "${CYAN_COLOUR}[DRY-RUN] *** Directory structure that would be " \
         "created:${NORMAL_COLOUR}"
  tree -a -L 2 data.template/ 2>/dev/null || \
    find data.template/ -maxdepth 2 -print | sed 's|data.template/|data/|g'

else
  # Actually copy the directory
  cp -r data.template/ data/

  if [ $? -eq 0 ]; then
    printf "%b" \
           "${GREEN_COLOUR}[SUCCESS] *** Created data/ directory from " \
           "template${NORMAL_COLOUR}\n"
  else
    printf "%b" \
           "${RED_COLOUR}[ERROR] *** Failed to copy data.template/ to " \
           "data/${NORMAL_COLOUR}\n"
    exit 103
  fi
fi

##############################################################################
# Set restrictive permissions on sensitive files
##############################################################################
printf "\n%b\n" \
       "${GREEN_COLOUR}[INFO] *** Setting permissions on sensitive " \
       "files${NORMAL_COLOUR}"

sensitiveFiles=(
  "data/credentials/default.yaml"
  "data/.ssh/ssh_key"
)

for file in "${sensitiveFiles[@]}"; do
  if [ "$dryRun" = true ]; then
    printf "%b" \
           "${CYAN_COLOUR}[DRY-RUN] *** Would set chmod 600 on: " \
           "$file${NORMAL_COLOUR}\n"
  else
    if [ -f "$file" ]; then
      chmod 600 "$file"
      printf "%b" \
             "${GREEN_COLOUR}[SUCCESS] *** Set chmod 600 on: " \
             "$file${NORMAL_COLOUR}\n"
    fi
  fi
done

##############################################################################
# Display summary
##############################################################################
printf "\n%b\n\n" \
       "${GREEN_COLOUR}========================================\n" \
       "Data Directory Initialization Complete\n" \
       "========================================${NORMAL_COLOUR}"

if [ "$dryRun" = false ]; then
  printf "Directory structure created:\n"
  tree -a -L 2 data/ 2>/dev/null || find data/ -maxdepth 2 -print
  printf "\n"
fi

##############################################################################
# Display next steps
##############################################################################
printf "%b\n" "${YELLOW_COLOUR}Next Steps:${NORMAL_COLOUR}"

cat <<'EOF'
1. Add SSH private key:
   cp ~/.ssh/your_key data/.ssh/ssh_key
   chmod 600 data/.ssh/ssh_key

2. Create encrypted credentials (interactive):
   ./scripts/setupCredentials.sh

3. Customize RPi configuration:
   vi data/rpi/metadata.yaml          # File copy configuration
   vi data/rpi/cmdline-txt-mods.yaml  # Kernel boot parameters
   vi data/rpi/userconf.txt           # First boot user
      # (see file for password encryption)

4. Update inventory:
   vi data/inventory.yaml             # Add your RPi hosts

5. Download RPi OS image (automatic):
   ansible-playbook playbooks/updateImage-pb.yaml

6. Ready to create RPi images:
   ./scripts/createImage.sh

EOF

printf "%b\n" \
       "${YELLOW_COLOUR}For detailed instructions, see README.md files in " \
       "each data/ subdirectory.${NORMAL_COLOUR}"
