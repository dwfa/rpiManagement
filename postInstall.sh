#! /bin/bash

##############################################################################
# Wrapper script for creating RPi SD card image
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.1
# Date: February 15, 2026
##############################################################################
source ./scripts/init.sh

playbook="playbooks/postInstall-pb.yaml"
node="${node:-preinstaller}"

source ./scripts/runAnsible.sh