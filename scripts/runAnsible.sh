##############################################################################
# Playbook execution script for Ansible wrapper scripts
#
# USAGE:
#   Wrapper scripts source this after setting the `playbooks` array.
#   Each entry is "<playbookPath> <defaultNode>" (space-separated).
#   A single-entry array runs one playbook; multi-entry runs a chain
#   and bails on first non-zero ansible-playbook rc.
#
# REQUIRED VARIABLES:
#   - playbooks: bash array of "<playbookPath> <defaultNode>" entries
#
# VARIABLES FROM init.sh / clParsing.sh:
#   - debugFlag:  "" or "debugFlag=1"        (-d)
#   - testOnly:   --check / --syntax-check / --list-tasks flags  (-c, -s, -t)
#   - syntaxCheck: "1" when -s passed
#   - node:       "" or override from -n <node>
#   - args:       additional positional arguments
#   - GREEN_COLOUR, NORMAL_COLOUR, RED_COLOUR: console colours
#
# NODE RESOLUTION:
#   For each iteration, the effective node is $node (from -n <node>)
#   if set, otherwise the per-entry default baked into the array.
#   In chain mode -n applies to EVERY entry (global override).
#
# EXAMPLE (single playbook):
#   source ./scripts/init.sh
#   playbooks=("playbooks/myPlaybook-pb.yaml myDefaultNode")
#   source ./scripts/runAnsible.sh
#
# EXAMPLE (chain):
#   source ./scripts/init.sh
#   playbooks=(
#     "playbooks/postCreate-pb.yaml       preinstaller"
#     "playbooks/createDNSServer-pb.yaml  dns"
#   )
#   source ./scripts/runAnsible.sh
#
# LOGGING:
#   Each playbook is tee'd to logs/<basename>-YYYYMMDD-HHMMSS.log.
#   Override the directory with $LOG_DIR.
#
# NOTES:
#   - Uses `return` (not `exit`) so wrappers can include additional
#     code after sourcing this if they need to.
#   - Chain mode bails on first failure -- no point provisioning
#     services on a host that didn't get bootstrapped.
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 3.0
# Date: May 16, 2026
##############################################################################

##############################################################################
# Sanity check -- wrapper must have set $playbooks as a bash array
##############################################################################
if ! declare -p playbooks 2>/dev/null | grep -q "declare \-a"; then
  echo -e "${RED_COLOUR}ERROR${NORMAL_COLOUR}: \$playbooks array not set by wrapper"
  return 1
fi

##############################################################################
# Iterate the playbooks array
##############################################################################
for _raEntry in "${playbooks[@]}"; do
  read -r _raPlaybook _raDefaultNode <<< "$_raEntry"
  _raNode="${node:-$_raDefaultNode}"             # -n overrides per-entry default

  ##########################################################################
  # Fail loud if no node could be resolved -- empty nodes= would silently
  # match zero hosts, which is the worst kind of "succeeded"
  ##########################################################################
  if [ -z "$_raNode" ]; then
    echo -e "${RED_COLOUR}ERROR${NORMAL_COLOUR}: no node for [$_raPlaybook] -- array entry has no default and -n <node> was not given"
    return 1
  fi

  ##########################################################################
  # Reset extra-vars each iteration so chain runs do not accumulate
  ##########################################################################
  ansibleVariables="${debugFlag}"
  ansibleVariables+=" nodes=${_raNode}"

  ##########################################################################
  # Syntax-check shim: --syntax-check parses each play independently
  # and tries to resolve `hosts:` at parse time. Plays that reference
  # hostvars['localhost'].newTarget (set at runtime by getTargetHostIP)
  # would fail before they ever ran. Inject a dummy newTarget so parse
  # resolution succeeds; never reaches a real run.
  ##########################################################################
  if [ "$syntaxCheck" == "1" ]; then
    ansibleVariables+=" newTarget=localhost"
  fi

  ##########################################################################
  # Per-playbook log file under $LOG_DIR (default ./logs)
  ##########################################################################
  logDir="${LOG_DIR:-./logs}"
  mkdir -p "$logDir"
  logFile="${logDir}/$(basename "$_raPlaybook" .yaml)-$(date +%Y%m%d-%H%M%S).log"

  ##########################################################################
  # Run the playbook -- tee to logFile, preserve ansible's exit code
  ##########################################################################
  if [ ! -f "$_raPlaybook" ]; then
    echo -e "${RED_COLOUR}ERROR${NORMAL_COLOUR}: file not found [$_raPlaybook]!"
    return 1
  fi

  echo -e "Running ${GREEN_COLOUR}$(basename "$_raPlaybook" .yaml)${NORMAL_COLOUR} playbook ..."
  echo -e "Logging to ${GREEN_COLOUR}${logFile}${NORMAL_COLOUR}"
  ansible-playbook $testOnly --extra-vars "${ansibleVariables}" ${args[@]} "${_raPlaybook}" 2>&1 \
    | tee "$logFile"
  _raRc="${PIPESTATUS[0]}"

  if [ "$_raRc" -ne 0 ]; then
    echo -e "${RED_COLOUR}FAILED${NORMAL_COLOUR}: $(basename "$_raPlaybook" .yaml) (exit ${_raRc}); aborting."
    return "$_raRc"
  fi
done

return 0