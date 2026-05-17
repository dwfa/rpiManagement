#! /bin/bash

##############################################################################
# Wrapper script for reconfiguring an already-provisioned DNS server.
# Pushes fresh bind9 / isc-dhcp-server / pi-hole configuration without
# reinstalling anything. Use after editing data/network/inventory.xlsx
# or any data/packages/<svc>/metadata.yaml.
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: May 16, 2026
##############################################################################
source ./scripts/init.sh

playbooks=("playbooks/reconfigureDNSServer-pb.yaml dns")

source ./scripts/runAnsible.sh