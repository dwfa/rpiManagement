#!/bin/bash
##############################################################################
# Create encrypted Ansible credentials file interactively
#
# USAGE:
#   ./scripts/setupCredentials.sh [--user <username>] [--help]
#
# DESCRIPTION:
#   Prompts for SSH credentials and creates an encrypted credentials file
#   using Ansible Vault. Passwords are encrypted using ansible-vault
#   encrypt_string, keeping usernames in plain text for visibility.
#
# OPTIONS:
#   --user <name>   Create credentials for specific user (default: default)
#   --help          Display this help message
#
# WORKFLOW:
#   1. Verify ansible-vault command available
#   2. Check for vault password file (prompt to create if missing)
#   3. Prompt for username, password, sudo password
#   4. Encrypt password values using ansible-vault encrypt_string
#   5. Generate credentials YAML file
#   6. Set restrictive permissions (chmod 600)
#
# EXIT CODES:
#   0   - Success (credentials file created)
#   101 - ansible-vault command not found
#   102 - Vault password file creation failed
#   103 - Password encryption failed
#   104 - Failed to write credentials file
#
# NOTES:
#   - Requires Ansible to be installed (for ansible-vault command)
#   - Creates ~/.ansible_vault_pass if it doesn't exist
#   - Backs up existing credentials file before overwriting
#   - Passwords are hidden during input (read -s)
#   - Can be run from any directory (auto-navigates to project root)
#   - Uses printf for macOS bash compatibility
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
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
credUser="default"
showHelp=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --user)
      credUser="$2"
      shift 2
      ;;
    --help)
      showHelp=true
      shift
      ;;
    *)
      printf "%b" "${RED_COLOUR}[ERROR] *** Unknown option: $1${NORMAL_COLOUR}\n"
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
  printf "  ./scripts/setupCredentials.sh [--user <username>] [--help]\n"
  printf "\n"
  printf "OPTIONS:\n"
  printf "  --user <name>   Create credentials for specific user (default: default)\n"
  printf "  --help          Display this help message\n"
  printf "\n"
  printf "DESCRIPTION:\n"
  printf "  Creates encrypted credentials file by prompting for username and passwords.\n"
  printf "  Uses Ansible Vault to encrypt password values while keeping structure readable.\n"
  printf "\n"
  printf "EXAMPLES:\n"
  printf "  ./scripts/setupCredentials.sh              # Create default.yaml\n"
  printf "  ./scripts/setupCredentials.sh --user admin # Create admin.yaml\n"
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
# Verify ansible-vault command available
##############################################################################
if ! command -v ansible-vault &> /dev/null; then
  printf "%b" "${RED_COLOUR}[ERROR] *** ansible-vault command not found${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** Please install Ansible: pip install ansible${NORMAL_COLOUR}\n"
  exit 101
fi

##############################################################################
# Check for vault password file
##############################################################################
VAULT_PASSWORD_FILE="$HOME/.ansible_vault_pass"

if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
  printf "\n"
  printf "%b" "${YELLOW_COLOUR}[WARNING] *** Vault password file not found: ${VAULT_PASSWORD_FILE}${NORMAL_COLOUR}\n"
  printf "%b" "${GREEN_COLOUR}[INFO] *** This file is needed to encrypt/decrypt credentials${NORMAL_COLOUR}\n"
  printf "\n"

  # Prompt to create vault password file
  printf "%b" "${GREEN_COLOUR}Create vault password file now? (y/n): ${NORMAL_COLOUR}"
  read createVault

  if [[ "$createVault" =~ ^[Yy]$ ]]; then
    printf "%b" "${GREEN_COLOUR}Enter vault password (will be saved to ${VAULT_PASSWORD_FILE}): ${NORMAL_COLOUR}"
    read -s vaultPassword
    printf "\n"

    printf "%b" "${GREEN_COLOUR}Confirm vault password: ${NORMAL_COLOUR}"
    read -s vaultPasswordConfirm
    printf "\n"

    if [ "$vaultPassword" != "$vaultPasswordConfirm" ]; then
      printf "%b" "${RED_COLOUR}[ERROR] *** Passwords do not match${NORMAL_COLOUR}\n"
      exit 102
    fi

    # Create vault password file
    printf "%s" "$vaultPassword" > "$VAULT_PASSWORD_FILE"
    chmod 600 "$VAULT_PASSWORD_FILE"

    printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Created vault password file: ${VAULT_PASSWORD_FILE}${NORMAL_COLOUR}\n"
    printf "\n"
  else
    printf "%b" "${RED_COLOUR}[ERROR] *** Vault password file required to continue${NORMAL_COLOUR}\n"
    printf "%b" "${YELLOW_COLOUR}[INFO] *** Create ${VAULT_PASSWORD_FILE} manually and re-run this script${NORMAL_COLOUR}\n"
    exit 102
  fi
fi

##############################################################################
# Prompt for credentials
##############################################################################
printf "\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}Ansible Credentials Setup${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "\n"

# Username (plain text)
printf "%b" "${GREEN_COLOUR}Enter SSH username: ${NORMAL_COLOUR}"
read sshUsername

# SSH Password (hidden)
printf "%b" "${GREEN_COLOUR}Enter SSH password: ${NORMAL_COLOUR}"
read -s sshPassword
printf "\n"

# Sudo Password (hidden, default to SSH password)
printf "%b" "${GREEN_COLOUR}Enter sudo password (or press Enter for same as SSH password): ${NORMAL_COLOUR}"
read -s sudoPassword
printf "\n"

# Use SSH password if sudo password is empty
if [ -z "$sudoPassword" ]; then
  sudoPassword="$sshPassword"
fi

##############################################################################
# Encrypt passwords using ansible-vault
##############################################################################
printf "\n"
printf "%b" "${GREEN_COLOUR}[INFO] *** Encrypting passwords...${NORMAL_COLOUR}\n"

# Encrypt SSH password
encryptedPwd=$(echo "$sshPassword" | ansible-vault encrypt_string --vault-password-file="$VAULT_PASSWORD_FILE" --stdin-name 'pwd' 2>&1)
if [ $? -ne 0 ]; then
  printf "%b" "${RED_COLOUR}[ERROR] *** Failed to encrypt SSH password${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** ${encryptedPwd}${NORMAL_COLOUR}\n"
  exit 103
fi

# Encrypt sudo password
encryptedSudoPwd=$(echo "$sudoPassword" | ansible-vault encrypt_string --vault-password-file="$VAULT_PASSWORD_FILE" --stdin-name 'sudoPWD' 2>&1)
if [ $? -ne 0 ]; then
  printf "%b" "${RED_COLOUR}[ERROR] *** Failed to encrypt sudo password${NORMAL_COLOUR}\n"
  printf "%b" "${YELLOW_COLOUR}[INFO] *** ${encryptedSudoPwd}${NORMAL_COLOUR}\n"
  exit 103
fi

##############################################################################
# Create credentials file
##############################################################################
CRED_FILE="data/credentials/${credUser}.yaml"

# Backup existing file
if [ -f "$CRED_FILE" ]; then
  printf "%b" "${YELLOW_COLOUR}[WARNING] *** Backing up existing file: ${CRED_FILE}.bak${NORMAL_COLOUR}\n"
  cp "$CRED_FILE" "${CRED_FILE}.bak"
fi

# Ensure credentials directory exists
mkdir -p "data/credentials"

# Write credentials file
cat > "$CRED_FILE" <<EOF
##############################################################################
# Ansible connection credentials for user: ${credUser}
#
# AUTO-GENERATED by scripts/setupCredentials.sh
#
# SECURITY:
#   - Passwords encrypted using Ansible Vault
#   - Username stored in plain text for visibility
#   - Edit encrypted values: ansible-vault edit ${CRED_FILE}
#   - View decrypted values: ansible-vault view ${CRED_FILE}
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: $(date +"%B %d, %Y")
##############################################################################
---

userData:
  uid: ${sshUsername}
  ${encryptedPwd}
  ${encryptedSudoPwd}
EOF

if [ $? -ne 0 ]; then
  printf "%b" "${RED_COLOUR}[ERROR] *** Failed to write credentials file: ${CRED_FILE}${NORMAL_COLOUR}\n"
  exit 104
fi

# Set restrictive permissions
chmod 600 "$CRED_FILE"

##############################################################################
# Display summary
##############################################################################
printf "\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}Credentials Setup Complete${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}========================================${NORMAL_COLOUR}\n"
printf "\n"
printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Created: ${CRED_FILE}${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Permissions: 600 (read/write owner only)${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Username: ${sshUsername} (plain text)${NORMAL_COLOUR}\n"
printf "%b" "${GREEN_COLOUR}[SUCCESS] *** Passwords: encrypted with Ansible Vault${NORMAL_COLOUR}\n"
printf "\n"
printf "%b" "${YELLOW_COLOUR}Next Steps:${NORMAL_COLOUR}\n"
printf "\n"
printf "1. Verify vault password file: ${VAULT_PASSWORD_FILE}\n"
printf "2. Test credentials by running a playbook:\n"
printf "   ansible-playbook playbooks/test-pb.yaml\n"
printf "\n"
printf "3. To edit credentials later:\n"
printf "   ansible-vault edit ${CRED_FILE}\n"
printf "\n"
printf "4. To view decrypted credentials:\n"
printf "   ansible-vault view ${CRED_FILE}\n"
printf "\n"
