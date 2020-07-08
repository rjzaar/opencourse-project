#!/bin/bash
################################################################################
#                            stopgulp For Pleasy Library
#
#  This script is used to kill any processes started by gulp.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  29/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='stopgulp'

# Help menu
print_help() {
  cat <<-HELP
This script is used to kill any processes started by gulp. There are no arguments required.
HELP
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help, --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do '$scriptname --help' for more options"
    exit 1
}
################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2 # works
    ;;
  --)
  shift; break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

# Check number of arguments
################################################################################
# No arguments required.
################################################################################

# ps -ef | grep "browser-sync start"
# ps -ef | grep "gulp"
# echo "Now trying to stop the processes"
ps -ef | grep "browser-sync start" | awk '{print $2, $8}' |
  while read i; do
    set $i
    #echo "textn = $2"
    if [ "$2" == "node" ]; then
      echo "stop process $1 for browser-sync"
      kill $1
    fi
  done
# ps -ef | grep "gulp"
ps -ef | grep "gulp" | awk '{print $2, $8}' |
  while read i; do
    set $i
    #echo "textg = $2"
    if [ "$2" == "gulp" ]; then
      echo "stop process $1 for gulp"
      kill $1
    fi
  done
#echo "Check to see if they have been stopped."
# ps -ef | grep "browser-sync start"
# ps -ef | grep "gulp"
