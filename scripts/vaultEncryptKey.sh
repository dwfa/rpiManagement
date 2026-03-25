#!/bin/bash
##############################################################################
# Vault-encrypt an SSH key for inclusion in user.yaml
#
# USAGE:
#   cat data/ssh/ssh_key | ./scripts/vaultEncryptKey.sh
#   ./scripts/vaultEncryptKey.sh -ik data/ssh/ssh_key
#   ./scripts/vaultEncryptKey.sh
#     (prompts for file path interactively)
#
# DESCRIPTION:
#   Reads an SSH key (typically private key) from stdin, -ik option,
#   or interactive prompt, then encrypts it using ansible-vault
#   encrypt_string. Outputs the encrypted YAML block to stdout or
#   to a file via -ok, ready for inclusion in a user.yaml sshKeys
#   section.
#
# OPTIONS:
#   -ik, --input-key <path>    Path to key file to encrypt
#   -ok, --output-key <path>   Write encrypted output to file
#   --vault-file <path>        Vault password file path
#                              (default: ~/.ansibleVaultPWD)
#   --name <varname>           YAML variable name for encrypted block
#                              (default: 'key')
#   -q, --quiet                Suppress informational messages
#   --help                     Display this help message
#
# INPUT PRECEDENCE (highest to lowest):
#   1. Named option:  ./scripts/vaultEncryptKey.sh -ik path/to/key
#   2. Stdin pipe:    cat ssh_key | ./scripts/vaultEncryptKey.sh
#   3. Interactive:   Script prompts for file path
#
# EXIT CODES:
#   0   - Success (encrypted output produced)
#   101 - ansible-vault command not found
#   102 - Vault password file not found
#   103 - Input file not found or not readable
#   104 - No input provided (empty stdin or empty file)
#   105 - ansible-vault encryption failed
#   106 - Failed to write output file
#
# NOTES:
#   - All informational messages go to stderr (stdout reserved
#     for encrypted output unless -ok is used)
#   - Uses printf '%s' (not echo) to preserve key content exactly
#   - Encrypts any text content; no format validation performed
#   - Output indentation matches ansible-vault default; adjust
#     manually for nested YAML placement
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.1
# Date: March 19, 2026
##############################################################################

##############################################################################
# Source colour definitions
##############################################################################
scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${scriptDir}/colours.sh"

##############################################################################
# Utility functions
##############################################################################

# infoMsg - Print info message to stderr (respects quiet mode)
#
# Parameters:
#   $@ - Message strings (concatenated by printf)
infoMsg() {
  if [ "${quietMode}" = false ]; then
    printf "%b" "$@" >&2
  fi
}

# errorMsg - Print error message to stderr (always)
#
# Parameters:
#   $@ - Message strings (concatenated by printf)
errorMsg() {
  printf "%b" "$@" >&2
}

# readKeyFromStdin - Read all stdin into keyContent
#
# Returns:
#   Sets keyContent variable
#   Exit 104 if empty
readKeyFromStdin() {
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<readKeyFromStdin> Reading key from " \
          "stdin${NORMAL_COLOUR}\n"
  keyContent=$(cat)
  if [ -z "${keyContent}" ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** " \
             "<readKeyFromStdin> No key content provided " \
             "(empty stdin)${NORMAL_COLOUR}\n"
    exit 104
  fi
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<readKeyFromStdin> Read " \
          "[$(printf '%s' "${keyContent}" | wc -l | tr -d ' ')] " \
          "lines${NORMAL_COLOUR}\n"
}

# readKeyFromFile - Read key content from file
#
# Parameters:
#   keyPath - Path to key file (must be set)
#
# Returns:
#   Sets keyContent variable
#   Exit 103 if file not found/readable
#   Exit 104 if file empty
readKeyFromFile() {
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<readKeyFromFile> Reading key from " \
          "[${keyPath}]${NORMAL_COLOUR}\n"
  if [ ! -f "${keyPath}" ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** " \
             "<readKeyFromFile> Key file not found: " \
             "[${keyPath}]${NORMAL_COLOUR}\n"
    exit 103
  fi
  if [ ! -r "${keyPath}" ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** " \
             "<readKeyFromFile> Key file not readable: " \
             "[${keyPath}]${NORMAL_COLOUR}\n"
    exit 103
  fi
  keyContent=$(cat "${keyPath}")
  if [ -z "${keyContent}" ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** " \
             "<readKeyFromFile> Key file is empty: " \
             "[${keyPath}]${NORMAL_COLOUR}\n"
    exit 104
  fi
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<readKeyFromFile> Read " \
          "[$(printf '%s' "${keyContent}" | wc -l | tr -d ' ')] " \
          "lines${NORMAL_COLOUR}\n"
}

# encryptKey - Encrypt keyContent using ansible-vault
#
# Parameters:
#   keyContent   - Content to encrypt (must be set)
#   vaultPWDPath - Path to vault password file
#   varName      - YAML variable name for --stdin-name
#
# Returns:
#   Sets encryptedOutput variable
#   Exit 105 on encryption failure
encryptKey() {
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<encryptKey> Encrypting with vault variable " \
          "name [${varName}]${NORMAL_COLOUR}\n"
  encryptedOutput=$(printf '%s' "${keyContent}" | \
    ansible-vault encrypt_string \
      --vault-password-file="${vaultPWDPath}" \
      --encrypt-vault-id default \
      --stdin-name "${varName}" 2>&1)
  if [ $? -ne 0 ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** " \
             "<encryptKey> ansible-vault encryption " \
             "failed${NORMAL_COLOUR}\n"
    errorMsg "${YELLOW_COLOUR}[INFO] *** " \
             "${encryptedOutput}${NORMAL_COLOUR}\n"
    exit 105
  fi
  infoMsg "${GREEN_COLOUR}[INFO] *** " \
          "<encryptKey> Encryption " \
          "successful${NORMAL_COLOUR}\n"
}

##############################################################################
# Parse command line arguments
##############################################################################
keyPath=""
outputPath=""
vaultPWDPath="$HOME/.ansibleVaultPWD"
varName="key"
quietMode=false
showHelp=false

while [[ $# -gt 0 ]]; do
  case $1 in
    -ik|--input-key)
      keyPath="$2"
      shift 2
      ;;
    -ok|--output-key)
      outputPath="$2"
      shift 2
      ;;
    --vault-file|--vault-password-file)
      vaultPWDPath="$2"
      shift 2
      ;;
    --name)
      varName="$2"
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
      errorMsg "${RED_COLOUR}[ERROR] *** Unknown option: " \
               "$1${NORMAL_COLOUR}\n"
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
  cat ssh_key | ./scripts/vaultEncryptKey.sh [OPTIONS]
  ./scripts/vaultEncryptKey.sh [OPTIONS] -ik <key_file>
  ./scripts/vaultEncryptKey.sh [OPTIONS]

OPTIONS:
  -ik, --input-key <path>    Path to key file to encrypt
  -ok, --output-key <path>   Write encrypted output to file
  --vault-file <path>        Vault password file
                             (default: ~/.ansibleVaultPWD)
  --name <varname>           YAML variable name for encrypted
                             block (default: 'key')
  -q, --quiet                Suppress informational messages
  --help                     Display this help message

INPUT PRECEDENCE:
  1. Stdin pipe (highest)
  2. -ik option
  3. Interactive prompt (lowest)

EXAMPLES:
  # Pipe from file
  cat data/ssh/ssh_key | ./scripts/vaultEncryptKey.sh

  # File argument
  ./scripts/vaultEncryptKey.sh -ik data/ssh/ssh_key

  # Custom variable name and output file
  ./scripts/vaultEncryptKey.sh -ik data/ssh/ssh_key \
    --name 'privateKey' -ok encrypted.yaml

  # Redirect to file
  ./scripts/vaultEncryptKey.sh -ik data/ssh/ssh_key > out.yaml

EOF
  exit 0
fi

##############################################################################
# Verify ansible-vault command available
##############################################################################
if ! command -v ansible-vault &> /dev/null; then
  errorMsg "${RED_COLOUR}[ERROR] *** ansible-vault command " \
           "not found\n" \
           "${YELLOW_COLOUR}[INFO] *** Please install Ansible: " \
           "pip install ansible${NORMAL_COLOUR}\n"
  exit 101
fi

##############################################################################
# Verify vault password file exists
##############################################################################
if [ ! -f "${vaultPWDPath}" ]; then
  errorMsg "${RED_COLOUR}[ERROR] *** Vault password file " \
           "not found: [${vaultPWDPath}]\n" \
           "${YELLOW_COLOUR}[INFO] *** Run " \
           "scripts/setupCredentials.sh to create " \
           "one${NORMAL_COLOUR}\n"
  exit 102
fi

##############################################################################
# Read key content (precedence: stdin > -ik > interactive)
##############################################################################
if [ -n "${keyPath}" ]; then
  # -ik option provided (takes precedence over stdin)
  readKeyFromFile
elif [ ! -t 0 ]; then
  # Stdin has data (pipe or redirect)
  readKeyFromStdin
else
  # Interactive prompt
  printf "%b" \
         "${GREEN_COLOUR}Enter path to SSH key file: " \
         "${NORMAL_COLOUR}" >&2
  read keyPath
  if [ -z "${keyPath}" ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** No file path " \
             "provided${NORMAL_COLOUR}\n"
    exit 103
  fi
  readKeyFromFile
fi

##############################################################################
# Encrypt key content
##############################################################################
encryptKey

##############################################################################
# Output encrypted block
##############################################################################
if [ -n "${outputPath}" ]; then
  # Write to file
  printf '%s\n' "${encryptedOutput}" > "${outputPath}"
  if [ $? -ne 0 ]; then
    errorMsg "${RED_COLOUR}[ERROR] *** Failed to write " \
             "output file: " \
             "[${outputPath}]${NORMAL_COLOUR}\n"
    exit 106
  fi
  chmod 600 "${outputPath}"
  infoMsg "${GREEN_COLOUR}[SUCCESS] *** Encrypted output " \
          "written to: " \
          "[${outputPath}]${NORMAL_COLOUR}\n"
else
  # Write to stdout
  printf '%s\n' "${encryptedOutput}"
fi

infoMsg "${GREEN_COLOUR}[INFO] *** Adjust indentation " \
        "when pasting into nested " \
        "YAML${NORMAL_COLOUR}\n"
