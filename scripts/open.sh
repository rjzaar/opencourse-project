#!/bin/bash
################################################################################
#                      Open site For Pleasy Library
#
#  This script will open the specified site
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
scriptname='open'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Opens the specified site
Usage: pl open [OPTION] ... [SOURCE]
This script will open the specified site.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl open loc"

}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl open --help' for more options"
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
parse_pl_yml

if [ $1 == "open" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sitename_var=$1
echo "about to open $sitename_var"
drush @$sitename_var uli &


