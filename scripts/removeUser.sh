#!/usr/bin/env bash
##############################################################################
# Remove a user and its home directory from a Linux host
#
# USAGE:
#   Run on the host, as root (sudo), from a different account than the
#   one being removed. Asks for the user name to be typed again before
#   removing it.
#
# EXAMPLE:
#   sudo ./removeUser.sh <userName>
#
# NOTES:
#   - Debian / Ubuntu only (userdel)
#   - Removes the home directory and mail spool (userdel --remove)
#   - Refuses to remove the account that ran sudo, or one that still
#     has running processes -- log that user out first
#   - A user that does not exist is reported, not an error
#
# Copyright 2026 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 15, 2026
##############################################################################

set -euo pipefail

if [[ $# -ne 1 ]]; then
  printf '%b' "[ERROR] *** Usage: sudo $0 <userName>\n" >&2
  exit 1
fi

userName="$1"

if [[ ${EUID} -ne 0 ]]; then
  printf '%b' "[ERROR] *** Run as root: sudo $0 ${userName}\n" >&2
  exit 1
fi

if ! id "${userName}" >/dev/null 2>&1; then
  printf '%b' "[INFO] *** User [${userName}] does not exist -- nothing to do\n"
  exit 0
fi

if [[ "${SUDO_USER:-}" == "${userName}" ]]; then
  printf '%b' "[ERROR] *** Cannot remove [${userName}] -- it ran sudo." \
              " Log in as another user (e.g. installer) and re-run\n" >&2
  exit 1
fi

if pgrep --uid "${userName}" >/dev/null; then
  printf '%b' "[ERROR] *** [${userName}] still has running processes." \
              " Log it out first:\n$(pgrep --list-name --uid "${userName}")\n" >&2
  exit 1
fi

read -r -p "Type [${userName}] to remove it and its home directory: " confirmName
if [[ "${confirmName}" != "${userName}" ]]; then
  printf '%b' "[INFO] *** Not confirmed -- [${userName}] kept\n"
  exit 0
fi

userdel --remove "${userName}"
printf '%b' "[INFO] *** User [${userName}] removed\n"
