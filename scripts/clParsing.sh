##############################################################################
# Command Line Parsing (clParsing) for bash
#   enables debug      if -d flag is set
#   enables check only if -c flag is set
#   override node      if -n <node> is set
#   list task          if -t flag is set
#
# Copyright 2025 Douglas WF Acheson (dwfa@dwfa.ca)
# Licensed under Apache License 2.0. See LICENSE.md for details.
#
# Version: 1.1
# Date: February 15, 2026
##############################################################################
declare -a args
debugFlag=""
node=""
testOnly=""
_expectNode=false
if [ $# -gt 0 ]; then
  for cmdItem in "$@"
  do
    if $_expectNode; then
      node="$cmdItem"
      _expectNode=false
      continue
    fi
    if [ "$cmdItem" == "-c" ]; then
      testOnly+=" --check"
      continue
    fi
    if [ "$cmdItem" == "-d" ]; then
      debugFlag="debugFlag=1"
      continue
    fi
    if [ "$cmdItem" == "-n" ]; then
      _expectNode=true
      continue
    fi
    if [ "$cmdItem" == "-t" ]; then
      testOnly+=" --list-tasks"
      continue
    fi
    args[${#args[@]}]="$cmdItem"
  done
fi
