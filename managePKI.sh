#! /bin/bash

##############################################################################
# Wrapper script for internal PKI management (create or renew CA + wildcard)
#
# USAGE:
#   ./managePKI.sh                            # idempotent create-or-renew
#   ./managePKI.sh -e forceRenew=true         # force wildcard re-issue
#
# Localhost-only — no target node required. The "node" variable is set
# to localhost so runAnsible.sh's nodes=... extra-var has a value, but
# the playbook itself targets hosts: localhost regardless.
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: May 7, 2026
##############################################################################
source ./scripts/init.sh

playbook="playbooks/managePKI-pb.yaml"
node="${node:-localhost}"

source ./scripts/runAnsible.sh