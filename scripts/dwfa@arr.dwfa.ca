#!/usr/bin/env bash
##############################################################################
# Create the installer user on a new non-RPi Linux host
#
# USAGE:
#   Run once on the new host, as root (sudo), before the first playbook.
#   Creates the installer user with a home directory and sudo rights,
#   then prompts for its password. Use the password stored in
#   data/users/installer/user.yaml (pwd and sudoPWD).
#
# EXAMPLE:
#   sudo ./createInstallerUser.sh
#
# NOTES:
#   - Debian / Ubuntu only (sudo group, useradd, sshd -T)
#   - Safe to re-run: an existing installer user is kept and only its
#     sudo membership and password are set again
#   - Reports, but does not change, an sshd that refuses password
#     logins -- the installer user logs in with its password
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 15, 2026
##############################################################################

set -euo pipefail

userName="installer"

if [[ ${EUID} -ne 0 ]]; then
  printf '%b' "[ERROR] *** Run as root: sudo $0\n" >&2
  exit 1
fi

if id "${userName}" >/dev/null 2>&1; then
  printf '%b' "[INFO] *** User [${userName}] already exists -- kept\n"
else
  useradd --create-home --shell /bin/bash "${userName}"
  printf '%b' "[INFO] *** User [${userName}] created\n"
fi

usermod --append --groups sudo "${userName}"

printf '%b' "[INFO] *** Set the password for [${userName}]" \
            " (from data/users/installer/user.yaml)\n"
passwd "${userName}"

sshPasswordAuth="$(sshd -T 2>/dev/null \
                   | awk '/^passwordauthentication/ {print $2}')"
if [[ "${sshPasswordAuth}" != "yes" ]]; then
  printf '%b' "[WARN] *** sshd PasswordAuthentication is" \
              " [${sshPasswordAuth:-unknown}] -- the installer user" \
              " cannot log in over SSH until it is yes\n"
fi

printf '%b' "[INFO] *** [${userName}] is ready:" \
            " $(id "${userName}")\n"
