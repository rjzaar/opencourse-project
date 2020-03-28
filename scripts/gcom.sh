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
verbose="none"

# Set script name for general file use
scriptname='pleasy-gcom'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl gcom [SITE] [MESSAGE] [OPTION]
This script will git commit changes to [SITE] with [MESSAGE].\
If you have access rights, you can commit changes to pleasy itself by using "pl" for [SITE].

OPTIONS
  -h --help               Display help (Currently displayed)
  -b --backup             Backup site after commit
  -v --verbose            Provide messages of what is happening
  -d --debug              Provide messages to help with debugging this function

Examples:
pl gcom loc \"Fixed error on blah.\" -bv\
pl gcom pl \"Improved gcom.\""
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
    gcombackup="backup"
    ;;
   -v | --verbose)
    verbose="normal"
    ;;
   -d | --debug)
    verbose="debug"
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

add_git_credentials

plcd $sitename_var
ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m $msg
git push

if [[ "$gcombackup" == "backup" ]] ; then
  ocmsg "Backup site $sitename_var with msg $msg"
  backup_site $sitename_var $msg
fi
