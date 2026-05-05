#! /bin/bash

##############################################################################
# Wrapper script for DNS server creation / refresh
# (createUsers today; bind / pihole / isc-dhcp roles to follow)
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: May 3, 2026
##############################################################################
source ./scripts/init.sh

playbook="playbooks/createDNSServer-pb.yaml"
node="${node:-dns}"

source ./scripts/runAnsible.sh