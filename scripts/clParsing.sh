##############################################################################
# Command Line Parsing (clParsing) for bash
#   enables debug      if -d flag is set
#   enables check only if -c flag is set
#   list task          if -t flag is set
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.0
# Date: October 16, 2025
##############################################################################
declare -a args
debugFlag=""
testOnly=""
if [ $# -gt 0 ]; then
  for cmdItem in "$@"
  do
    if [ $cmdItem == "-d" ]; then
      debugFlag="debugFlag=1"
      continue
    fi
    if [ $cmdItem == "-c" ]; then
      testOnly+=" --check"
      continue
    fi
    if [ $cmdItem == "-t" ]; then
      testOnly+=" --list-tasks"
      continue
    fi
    args[${#args[@]}]="$cmdItem"
  done
fi
