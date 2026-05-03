#! /bin/bash

##############################################################################
# Wrapper script for post-create setup of a freshly imaged RPi
# (normalize static IP, create main user, remove installer)
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 2.0
# Date: April 29, 2026
##############################################################################
source ./scripts/init.sh

playbook="playbooks/postCreate-pb.yaml"
node="${node:-preinstaller}"

source ./scripts/runAnsible.sh