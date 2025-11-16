#!/bin/bash
##############################################################################
# Create encrypted Ansible credentials file interactively
#
# USAGE:
#   ./scripts/setupCredentials.sh [OPTIONS]
#
# DESCRIPTION:
#   Prompts for SSH credentials and creates an encrypted credentials file
#   using Ansible Vault. Passwords are encrypted using ansible-vault
#   encrypt_string, keeping usernames in plain text for visibility.
#
# OPTIONS:
#   --user <name>         Set SSH username and credential filename
#                         (default: prompts for username)
#   --vault-file <path>   Vault password file path (default: ~/.ansibleVaultPWD)
#   -q, --quiet           Suppress informational messages
#   --help                Display this help message
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
#   - Creates ~/.ansibleVaultPWD if it doesn't exist
#     (or custom path if specified)
#   - When --vault-file is specified, creates file without prompting
#   - With -q/--quiet flag, suppresses informational messages
#   - Backs up existing credentials file before overwriting
#   - Passwords are hidden during input (read -s)
#   - Can be run from any directory (auto-navigates to project root)
#   - Uses printf for macOS bash compatibility
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.3
# Date: November 11, 2025
##############################################################################

##############################################################################
# Source colour definitions
##############################################################################
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${scriptDir}/colours.sh"

##############################################################################
# Parse command line arguments
##############################################################################
credUser="default"
vaultPWDFile="$HOME/.ansibleVaultPWD"
vaultFileExplicit=false
quietMode=false
showHelp=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --user)
      credUser="$2"
      shift 2
      ;;
    --vault-file|--vault-password-file)
      vaultPWDFile="$2"
      vaultFileExplicit=true
      shift 2
      ;;
    -q|--quiet)
      quietMode=true
      shift
      ;;
    --help)
      showHelp=true
      shift
      ;;
    *)
      printf "%b" \
             "${RED_COLOUR}[ERROR] *** Unknown option: $1${NORMAL_COLOUR}\n"
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
  ./scripts/setupCredentials.sh [OPTIONS]

OPTIONS:
  --user <name>         Set SSH username and credential filename
                        (default: prompts for username)
  --vault-file <path>   Vault password file path (default: ~/.ansibleVaultPWD)
  -q, --quiet           Suppress informational messages
  --help                Display this help message

DESCRIPTION:
  Creates encrypted credentials file by prompting for username and passwords.
  Uses Ansible Vault to encrypt password values while keeping structure
  readable.

EXAMPLES:
  ./scripts/setupCredentials.sh
    # Create default.yaml (prompts for SSH username)

  ./scripts/setupCredentials.sh --user installer
    # Create installer.yaml with SSH username 'installer' (no prompt)

  ./scripts/setupCredentials.sh --vault-file /path/to/vault
    # Use custom vault password file (creates if missing)

  ./scripts/setupCredentials.sh -q
    # Run in quiet mode (minimal output)

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
# Verify ansible-vault command available
##############################################################################
if ! command -v ansible-vault &> /dev/null; then
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** ansible-vault command not found\n" \
         "${YELLOW_COLOUR}[INFO] *** Please install Ansible: " \
         "pip install ansible${NORMAL_COLOUR}\n"
  exit 101
fi

##############################################################################
# Check for vault password file
##############################################################################
if [ ! -f "$vaultPWDFile" ]; then
  # Determine if we should prompt user
  # Prompt only if: using default file AND not in quiet mode
  # AND vault file not explicitly specified
  shouldPrompt=false
  if [ "$vaultFileExplicit" = false ] && [ "$quietMode" = false ]; then
    shouldPrompt=true
  fi

  # Show warning/info messages only if we're going to prompt
  if [ "$shouldPrompt" = true ]; then
    printf "\n%b\n%b\n\n%b" \
           "${YELLOW_COLOUR}[WARNING] *** Vault password file not found: " \
           "${vaultPWDFile}" \
           "${GREEN_COLOUR}[INFO] *** This file is needed to encrypt/decrypt " \
           "credentials" \
           "${GREEN_COLOUR}Create vault password file now? " \
           "(y/n): ${NORMAL_COLOUR}"
    read createVault

    if [[ ! "$createVault" =~ ^[Yy]$ ]]; then
      printf "%b" \
             "${RED_COLOUR}[ERROR] *** Vault password file required to " \
             "continue\n" \
             "${YELLOW_COLOUR}[INFO] *** Create ${vaultPWDFile} manually and " \
             "re-run this script${NORMAL_COLOUR}\n"
      exit 102
    fi
  else
    # Vault file explicitly specified or quiet mode - just inform and proceed
    if [ "$quietMode" = false ]; then
      printf "%b" \
             "${GREEN_COLOUR}[INFO] *** Creating vault password file: " \
             "${vaultPWDFile}${NORMAL_COLOUR}\n"
    fi
  fi

  # Collect vault password
  printf "%b" \
         "${GREEN_COLOUR}Enter vault password (will be saved to " \
         "${vaultPWDFile}): ${NORMAL_COLOUR}"
  read -s vaultPassword
  printf "\n%b" "${GREEN_COLOUR}Confirm vault password: ${NORMAL_COLOUR}"
  read -s vaultPasswordConfirm
  printf "\n"

  if [ "$vaultPassword" != "$vaultPasswordConfirm" ]; then
    printf "%b" \
           "${RED_COLOUR}[ERROR] *** Passwords do not match${NORMAL_COLOUR}\n"
    exit 102
  fi

  # Create vault password file
  printf "%s" "$vaultPassword" > "$vaultPWDFile"
  chmod 600 "$vaultPWDFile"

  if [ "$quietMode" = false ]; then
    printf "%b\n" \
           "${GREEN_COLOUR}[SUCCESS] *** Created vault password file: " \
           "${vaultPWDFile}${NORMAL_COLOUR}"
  fi
fi

##############################################################################
# Prompt for credentials
##############################################################################
printf "\n%b\n\n" \
       "${GREEN_COLOUR}========================================\n" \
       "Ansible Credentials Setup\n" \
       "========================================${NORMAL_COLOUR}"

# Username (plain text or from --user parameter)
if [ "$credUser" != "default" ]; then
  # Use --user parameter value as SSH username
  sshUsername="$credUser"
  printf "%b" \
         "${GREEN_COLOUR}[INFO] *** Using SSH username: " \
         "${sshUsername}${NORMAL_COLOUR}\n"
else
  # Prompt for SSH username
  printf "%b" "${GREEN_COLOUR}Enter SSH username: ${NORMAL_COLOUR}"
  read sshUsername
fi

# SSH Password (hidden)
printf "%b" "${GREEN_COLOUR}Enter SSH password: ${NORMAL_COLOUR}"
read -s sshPassword
printf "\n"

# Sudo Password (hidden, default to SSH password)
printf "%b" \
       "${GREEN_COLOUR}Enter sudo password (or press Enter for same as " \
       "SSH password): ${NORMAL_COLOUR}"
read -s sudoPassword
printf "\n"

# Use SSH password if sudo password is empty
if [ -z "$sudoPassword" ]; then
  sudoPassword="$sshPassword"
fi

##############################################################################
# Encrypt passwords using ansible-vault
##############################################################################
printf "\n%b\n" \
           "${GREEN_COLOUR}[INFO] *** Encrypting passwords...${NORMAL_COLOUR}"

# Encrypt SSH password
encryptedPwd=$(echo "$sshPassword" | \
  ansible-vault encrypt_string \
    --vault-password-file="$vaultPWDFile" \
    --encrypt-vault-id default \
    --stdin-name 'pwd' 2>&1)
if [ $? -ne 0 ]; then
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** Failed to encrypt SSH password\n" \
         "${YELLOW_COLOUR}[INFO] *** ${encryptedPwd}${NORMAL_COLOUR}\n"
  exit 103
fi

# Encrypt sudo password
encryptedSudoPwd=$(echo "$sudoPassword" | \
  ansible-vault encrypt_string \
    --vault-password-file="$vaultPWDFile" \
    --encrypt-vault-id default \
    --stdin-name 'sudoPWD' 2>&1)
if [ $? -ne 0 ]; then
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** Failed to encrypt sudo password\n" \
         "${YELLOW_COLOUR}[INFO] *** ${encryptedSudoPwd}${NORMAL_COLOUR}\n"
  exit 103
fi

##############################################################################
# Create credentials file
##############################################################################
credFile="data/credentials/${credUser}.yaml"

# Backup existing file
if [ -f "$credFile" ]; then
  printf "%b" \
         "${YELLOW_COLOUR}[WARNING] *** Backing up existing file: " \
         "${credFile}.bak${NORMAL_COLOUR}\n"
  cp "$credFile" "${credFile}.bak"
fi

# Ensure credentials directory exists
mkdir -p "data/credentials"

# Write credentials file
cat > "$credFile" <<EOF
##############################################################################
# Ansible connection credentials for user: ${credUser}
#
# AUTO-GENERATED by scripts/setupCredentials.sh
#
# SECURITY:
#   - Passwords encrypted using Ansible Vault
#   - Username stored in plain text for visibility
#   - Edit encrypted values: ansible-vault edit ${credFile}
#   - View decrypted values: ansible-vault view ${credFile}
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
  printf "%b" \
         "${RED_COLOUR}[ERROR] *** Failed to write credentials file: " \
         "${credFile}${NORMAL_COLOUR}\n"
  exit 104
fi

# Set restrictive permissions
chmod 600 "$credFile"

##############################################################################
# Display summary
##############################################################################
printf "\n%b\n\n%b\n%b\n%b\n%b\n\n%b\n\n" \
       "${GREEN_COLOUR}========================================\n" \
       "Credentials Setup Complete\n" \
       "========================================${NORMAL_COLOUR}" \
       "${GREEN_COLOUR}[SUCCESS] *** Created: ${credFile}${NORMAL_COLOUR}" \
       "${GREEN_COLOUR}[SUCCESS] *** Permissions: 600 " \
       "(read/write owner only)${NORMAL_COLOUR}" \
       "${GREEN_COLOUR}[SUCCESS] *** Username: " \
       "${sshUsername} (plain text)${NORMAL_COLOUR}" \
       "${GREEN_COLOUR}[SUCCESS] *** Passwords: encrypted " \
       "with Ansible Vault${NORMAL_COLOUR}" \
       "${YELLOW_COLOUR}Next Steps:${NORMAL_COLOUR}"

cat <<EOF
1. Verify vault password file: ${vaultPWDFile}
2. Test credentials by running a playbook:
   ansible-playbook playbooks/test-pb.yaml

3. To edit credentials later:
   ansible-vault edit ${credFile}

4. To view decrypted credentials:
   ansible-vault view ${credFile}

EOF
