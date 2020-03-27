#!/bin/bash
################################################################################
#                       Git Commit For Pleasy Library
#
#  This will git commit changes and run an backup to capture it.
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
#  Core Maintainer:  Rob Zar
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

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Set script name for general file use
scriptname='pleasy-gcom'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl gcom [OPTION] ... [SITE] [MESSAGE]
This script follows the correct path to git commit changes You just need to
state the sitename, eg loc.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -b --backup             Backup site after commit

Examples:"
exit 0
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
    echo "please type 'pl gcom --help' for more options"
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
    exit 0
    ;;
   -b | --backup)
    print_help
    exit 0
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


parse_pl_yml

if [ $1 == "gcom" ] && [ -z "$2" ]; then
  sitename_var="$sites_dev"
elif [ -z "$2" ]; then
  sitename_var=$1
  msg="Commit."
else
  sitename_var=$1
  msg=$2
fi

echo "This will git commit changes on site $sitename_var with msg $msg and run an backup to capture it."
# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

parse_pl_yml
import_site_config $sitename_var

echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m msg
git push


ocmsg "Backup site $sitename_var with msg $msg"
backup_site $sitename_var $msg
