#!/bin/bash
################################################################################
#                       Fix permissions For Pleasy Library
#
#  This will set the correct folder and file permissions for a drupal site.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  15/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
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
#
# NAME OF COMMENT (USE FOR RATHER SIGNIFICANT COMMENTS)
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-fixp'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl fixp [OPTION] ... [SOURCE]
This script is used to fix permissions of a Drupal site You just need to
state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:"

}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hd -l help,debug --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl enmod --help' for more options"
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
    print_help
    exit 2 # works
    ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  echo 'Please give a site source'
  print_help
  exit 0
fi

sitename_var=$1
parse_pl_yml

import_site_config $sitename_var

# This will set the correct permissions
# Persumes the following information is set
# $user
# $folder
# $sitename_var
# $webroot

set_site_permissions



