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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/colours.sh"

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
      printf "%b" "${RED_COLOUR}[ERROR] *** Unknown option: $arg${NORMAL_COLOUR}\n"
      showHelp=true
      shift
      ;;
  esac
done

##############################################################################
# Display help
##############################################################################
if [ "$showHelp" = true ]; then
  printf "\n"
  printf "USAGE:\n"
  printf "  ./scripts/setupDataDir.sh [--dry-run] [--help]\n"
  printf "\n"
  printf "OPTIONS:\n"
  printf "  --dry-run   Show what would be created without actually creating\n"
  printf "  --help      Display this help message\n"
  printf "\n"
  printf "DESCRIPTION:\n"
  printf "  Initializes data/ directory from data.template/ with all necessary\n"
  printf "  configuration files and directory structure for Ansible automation.\n"
  printf "\n"
  printf "EXAMPLES:\n"
  printf "  ./scripts/setupDataDir.sh              # Create data/ directory\n"
  printf "  ./scripts/setupDataDir.sh --dry-run    # Preview what would be created\n"
  printf "\n"
  exit 0
fi

##############################################################################
# Change to project root (parent of scripts/ directory)
##############################################################################
PROJECT_ROOT="$(dirname "${SCRIPT_DIR}")"
cd "${PROJECT_ROOT}" || {
  printf "%b" "${RED_COLOUR}[ERROR] *** Failed to change to project root: ${PROJECT_ROOT}${NORMAL_COLOUR}\n"
  exit 101
}

##############################################################################
# Check if data.template/ exists
##############################################################################
if [ ! -d "data.template" ]; then
  printf "%b" "${RED_COLOUR}[ERROR] *** data.template/ directory not found${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** Expected to find: data.template/ in project root${NORMAL_COLOUR}\n"
  exit 102
fi

##############################################################################
# Check if data/ already exists
##############################################################################
if [ -d "data" ]; then
  printf "%b" "${YELLOW_COLOUR}[WARNING] *** data/ directory already exists${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** This script will NOT overwrite existing data/ directory${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** To reinitialize, manually remove or rename data/ first${NORMAL_COLOUR}\n"
  exit 0
fi

##############################################################################
# Display operation mode
##############################################################################
if [ "$dryRun" = true ]; then
  printf "%b" "${CYAN_COLOUR}[DRY-RUN] *** Showing what would be created (no changes will be made)${NORMAL_COLOUR}\n"
  printf "\n"
fi

##############################################################################
# Copy data.template/ to data/
##############################################################################
printf "%b" "${GREEN_COLOUR}[INFO] *** Initializing data/ directory from template${NORMAL_COLOUR}\n"
printf "\n"

if [ "$dryRun" = true ]; then
  printf "%b" "${CYAN_COLOUR}[DRY-RUN] *** Would create: data/${NORMAL_COLOUR}\n"
  printf "%b" "${CYAN_COLOUR}[DRY-RUN] *** Would copy: data.template/ → data/${NORMAL_COLOUR}\n"

  # Show directory tree that would be created
  printf "\n"
  printf "%b" "${CYAN_COLOUR}[DRY-RUN] *** Directory structure that would be created:${NORMAL_COLOUR}\n"
  tree -a -L 2 data.template/ 2>/dev/null || find data.template/ -maxdepth 2 -print | sed 's|data.template/|data/|g'

else
  # Actually copy the directory
  cp -r data.template/ data/

  if [ $? -eq 0 ]; then
    printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Created data/ directory from template${NORMAL_COLOUR}\n"
  else
    printf "%b" "${RED_COLOUR}[ERROR] *** Failed to copy data.template/ to data/${NORMAL_COLOUR}\n"
    exit 103
  fi
fi

##############################################################################
# Set restrictive permissions on sensitive files
##############################################################################
printf "\n"
printf "%b" "${GREEN_COLOUR}[INFO] *** Setting permissions on sensitive files${NORMAL_COLOUR}\n"

sensitiveFiles=(
  "data/credentials/default.yaml"
  "data/keys/ssh.key"
)

for file in "${sensitiveFiles[@]}"; do
  if [ "$dryRun" = true ]; then
    printf "%b" "${CYAN_COLOUR}[DRY-RUN] *** Would set chmod 600 on: $file${NORMAL_COLOUR}\n"
  else
    if [ -f "$file" ]; then
      chmod 600 "$file"
      printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Set chmod 600 on: $file${NORMAL_COLOUR}\n"
    fi
  fi
done

##############################################################################
# Display summary
##############################################################################
printf "\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}Data Directory Initialization Complete${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "\n"

if [ "$dryRun" = false ]; then
  printf "Directory structure created:\n"
  tree -a -L 2 data/ 2>/dev/null || find data/ -maxdepth 2 -print
  printf "\n"
fi

##############################################################################
# Display next steps
##############################################################################
printf "%b" "${YELLOW_COLOUR}Next Steps:${NORMAL_COLOUR}\n"
printf "\n"
printf "1. Add SSH private key:\n"
printf "   cp ~/.ssh/your_key data/keys/ssh.key\n"
printf "   chmod 600 data/keys/ssh.key\n"
printf "\n"
printf "2. Create encrypted credentials (interactive):\n"
printf "   ./scripts/setupCredentials.sh\n"
printf "\n"
printf "3. Customize RPi configuration:\n"
printf "   vi data/rpi/metadata.yaml          # File copy configuration\n"
printf "   vi data/rpi/cmdline-txt-mods.yaml  # Kernel boot parameters\n"
printf "   vi data/rpi/userconf.txt           # First boot user (see file for password encryption)\n"
printf "\n"
printf "4. Update inventory:\n"
printf "   vi data/inventory.yaml             # Add your RPi hosts\n"
printf "\n"
printf "5. Download RPi OS image (automatic):\n"
printf "   ansible-playbook playbooks/updateImage-pb.yaml\n"
printf "\n"
printf "6. Ready to create RPi images:\n"
printf "   ./scripts/createImage.sh\n"
printf "\n"
printf "%b" "${YELLOW_COLOUR}For detailed instructions, see README.md files in each data/ subdirectory.${NORMAL_COLOUR}\n"
printf "\n"
