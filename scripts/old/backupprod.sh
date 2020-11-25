#!/bin/bash
################################################################################
#                      Backup prod For Pleasy Library
#
#  This script is used to backup prod site's files and database. You can
#  add an optional message. The production site details are in pl.yml.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  11/02/2020 James Lim  Getopt parsing implementation, script documentation
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
scriptname='pleasy-backupprod'

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Backs up the production site
Usage: pl backup [OPTION] ... [MESSAGE]
  This script is used to backup prod site's files and database. You can
  add an optional message. The production site details are in pl.yml.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl backupprod -h
  pl backupprod 'First tim backup'"

}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")
#echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl backup --help' for more options"
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

################################   FIX THIS   ##################################
# THIS SCRIPT WILL NOT WORK, I'm not sure what it is trying to do
################################################################################
if [ $1 == "backupprod" ] && [ -z "$2" ]; then
  echo -e "\e[34mbackup prod \e[39m"
elif [ -z "$2" ]; then
  echo -e "\e[34mbackup prod with message $1\e[39m"
  msg=$1
else
  print_help
fi

#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_pl_yml

# What do these do?
################################################################################
#
################################################################################
backup_prod $msg

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
