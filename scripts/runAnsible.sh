##############################################################################
# Playbook execution script for Ansible wrapper scripts
#
# USAGE:
#   Source this after setting playbook and node variables. Builds
#   Ansible command line variables and executes the playbook.
#
# REQUIRED VARIABLES:
#   - playbook: Path to Ansible playbook file
#   - node: Target node/host group name
#
# VARIABLES FROM init.sh:
#   - debugFlag: Debug mode flag (from clParsing.sh)
#   - testOnly: Check/list-tasks flags (from clParsing.sh)
#   - args: Additional arguments (from clParsing.sh)
#   - GREEN_COLOUR: Console colour (from colours.sh)
#   - NORMAL_COLOUR: Console colour (from colours.sh)
#   - RED_COLOUR: Console colour (from colours.sh)
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

##############################################################################
# Build ansible variables for command line
##############################################################################
ansibleVariables+="${debugFlag}"
ansibleVariables+=" nodes=$node"

##############################################################################
# Run the playbook
##############################################################################
if [ -f "$playbook" ]; then
  echo -e "Running ${GREEN_COLOUR}`basename $playbook .yaml`${NORMAL_COLOUR} playbook ..."
  ansible-playbook $testOnly --extra-vars "${ansibleVariables}" ${args[@]} "${playbook}"
else
  echo -e "${RED_COLOUR}ERROR${NORMAL_COLOUR}: file not found [$playbook]!"
fi