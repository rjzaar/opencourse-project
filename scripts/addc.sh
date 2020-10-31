#!/bin/bash
################################################################################
#                 Addc (Add ssh credentials) For Pleasy Library
#
#  This script is used to add github credentials
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  09/02/2020 James Lim  Getopt parsing implementation, script documentation
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
#                             Commenting with model
# NAME OF COMMENT
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################
# Set script name for general file use
scriptname='addc'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Add github credentials
Usage: pl addc [OPTION]
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc "
}


# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl addc --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# if no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
  -- )
  shift
  break
  ;;
  *)
  "Programming error, this should not show up!"
  exit 1
  ;;
  esac
done

parse_pl_yml

add_git_credentials
