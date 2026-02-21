##############################################################################
# Ansible environment defaults for wrapper scripts
#
# USAGE:
#   Source this file in wrapper scripts after clParsing.sh.
#   Sets Ansible environment variables based on parsed command line flags.
#
# REQUIRED VARIABLES:
#   - debugFlag: Set by clParsing.sh (empty or "debugFlag=1")
#
# ENVIRONMENT VARIABLES SET:
#   - ANSIBLE_DISPLAY_SKIPPED_HOSTS: false unless debug mode enabled
#
# EXAMPLE:
#   source ./scripts/colours.sh
#   source ./scripts/clParsing.sh
#   source ./scripts/ansibleDefaults.sh
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: February 15, 2026
##############################################################################

##############################################################################
# Hide skipped tasks unless debug mode is enabled
##############################################################################
if [ -z "$debugFlag" ]; then
  export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false
fi