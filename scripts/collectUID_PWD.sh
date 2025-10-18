##############################################################################
# Collect sudo user credentials interactively
#
# USAGE:
#   Source this script to set sudoUID and sudoPWD variables for use in
#   wrapper scripts. Prompts interactively with fallback to environment vars.
#
# CREDENTIAL PRIORITY (for both UID and password):
#   1. Pre-set shell variable (sudoUID/sudoPWD) → uses that value
#   2. Environment variable if set → uses env var as default
#   3. User enters value interactively → uses that value
#   4. User presses Enter with default → uses the default
#   5. No default available → prompts again until value provided
#
# ENVIRONMENT VARIABLES (optional):
#   - ANSIBLE_DEFAULT_UID: Default user ID (e.g., export ANSIBLE_DEFAULT_UID=pi)
#   - ANSIBLE_DEFAULT_PWD: Default password (e.g., export ANSIBLE_DEFAULT_PWD=raspberry)
#
# OUTPUT VARIABLES (set by this script):
#   - sudoUID: User ID for sudo operations
#   - sudoPWD: Password for sudo operations
#
# EXAMPLE:
#   # Option 1: Set environment variables in shell profile (~/.bashrc, ~/.zshrc):
#   export ANSIBLE_DEFAULT_UID=pi
#   export ANSIBLE_DEFAULT_PWD=raspberry
#
#   # Option 2: Set shell variables before sourcing (in wrapper script):
#   sudoUID="pi"
#   sudoPWD="raspberry"
#   source scripts/collectUID_PWD.sh
#
#   # Option 3: Let script prompt interactively:
#   source scripts/collectUID_PWD.sh
#   echo "Using UID: $sudoUID"
#
# NOTES:
#   - Password input is not echoed to console (read -s)
#   - Set environment variables in your shell profile for convenience
#   - Prompt displays current default value or "no default"
#   - Uses printf for macOS bash compatibility
#   - Useful for automation while maintaining interactive flexibility
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.6
# Date: October 17, 2025
##############################################################################
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/colours.sh"

##############################################################################
# Collect UID
#
# Uncomment and set these variables before sourcing to skip interactive prompts:
# sudoUID="your_username"
# sudoPWD="your_password"
##############################################################################

# Determine default UID to display and use
defaultUID="${sudoUID:-${ANSIBLE_DEFAULT_UID:-no default}}"

# Prompt showing the default
printf "%b" "${GREEN_COLOUR}\tEnter the ${PINK_COLOUR}'uid'${GREEN_COLOUR} for sudo user (defaulting to [${defaultUID}]): ${NORMAL_COLOUR}"
read inputUID

# If user typed something, use it; otherwise use the default
sudoUID="${inputUID:-${defaultUID}}"

# If "no default" or empty, loop until we get a real value
while [ -z "$sudoUID" ] || [ "$sudoUID" = "no default" ]; do
    printf "%b" "${GREEN_COLOUR}\tUID required. Please enter uid: ${NORMAL_COLOUR}"
    read sudoUID
done

##############################################################################
# get sudo password from user
##############################################################################

# Determine default password to use
defaultPWD="${sudoPWD:-${ANSIBLE_DEFAULT_PWD}}"

# Create display message (NOT showing actual password)
defaultMsg="${defaultPWD:+default available}"
defaultMsg="${defaultMsg:-no default}"

# Prompt showing IF default exists (not the actual value)
printf "%b" "${GREEN_COLOUR}\tEnter the ${PINK_COLOUR}'${sudoUID}'${GREEN_COLOUR} sudo PWD (${defaultMsg}): ${NORMAL_COLOUR}"
read -s inputPWD
echo

# If user typed something, use it; otherwise use the default
sudoPWD="${inputPWD:-${defaultPWD}}"

# If empty, loop until we get a real value
while [ -z "$sudoPWD" ]; do
    printf "%b" "${GREEN_COLOUR}\tPassword required. Please enter password: ${NORMAL_COLOUR}"
    read -s sudoPWD
    echo
done
