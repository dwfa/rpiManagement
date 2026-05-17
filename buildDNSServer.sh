#! /bin/bash

##############################################################################
# Full DNS server build: chains postCreate + createDNSServer.
#
# Picks up where imaging left off. Run this against a freshly imaged
# RPi sitting at the installer/preinstaller address; the chain:
#   1. postCreate-pb.yaml      -- installer user creates dwfa + wwwAdmin,
#                                 applies static IP, host becomes the
#                                 `dns` inventory entry
#   2. createDNSServer-pb.yaml -- dwfa provisions configureBaseRPi, then
#                                 nginx, bind9, isc-dhcp, pihole, webmin
#
# Chain bails on first failure. Each playbook still logs to its own file
# under logs/. To run only the bootstrap half, use `./postCreate.sh`
# directly. To run only the DNS-services half, comment out the
# postCreate-pb.yaml entry in the playbooks array below.
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.0
# Date: May 17, 2026
##############################################################################
source ./scripts/init.sh

playbooks=(
#  "playbooks/postCreate-pb.yaml      installer"
  "playbooks/createDNSServer-pb.yaml installer"
)

source ./scripts/runAnsible.sh