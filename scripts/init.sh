##############################################################################
# Initialization script for Ansible wrapper scripts
#
# USAGE:
#   Source this at the beginning of wrapper scripts to load common
#   dependencies: console colours, command line parsing, and Ansible
#   environment defaults.
#
# EXAMPLE:
#   source ./scripts/init.sh
#   playbook="playbooks/myPlaybook-pb.yaml"
#   node="${node:-myDefaultNode}"
#   source ./scripts/runAnsible.sh
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: February 15, 2026
##############################################################################
source ./scripts/colours.sh         # define console colours
source ./scripts/clParsing.sh       # parse command line
source ./scripts/ansibleDefaults.sh # set ansible environment