#!/bin/bash
################################################################################
#                      Backupdb For Pleasy Library
#
#  Hi Rob, please state what this does, and the difference between this and
#  backup.sh
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  11/02/2020 James Lim  Getopt parsing implementation, script documentation
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
scriptname='pleasy-backupdb'
plcstatus="works"
# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
  echo \
    "Backs up the database only
    Usage: pl backupdb [OPTION] ... [SOURCE]
  This script is used to backup a particular site's database.
  You just need to state the sitename, eg dev.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
    -m --message='msg'      Enter an optional message to accompany the backup

  Examples:
  pl backupdb -h
  pl backupdb dev
  pl backupdb tim -m 'First tim backup'
  pl backupdb --message='Love' love
  END HELP"
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
echo -e "\e[34mbackup $1 \e[39m"

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hm: -l help,message: --name "$scriptname" -- "$@")
#echo "$args"

##########################   BUG ALERT  ########################################
# program quits upon getopt fail, which is unusual to say the least
################################################################################

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
# if no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
  -m | --message)
    shift
    msg="$(echo "$1" | sed 's/^=//g')"
    echo "Msg = $msg"
    shift
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

#echo $0; echo $1; echo "DEBUG EXIT"; exit 0

# No arguments
################################################################################
# if no argument found exit and display error. User must input directory for
# backup else this script will fail.
################################################################################
if [[ "$1" == "backupdb" ]] && [[ -z "$2" ]]; then
  echo "No site specified."
elif [[ "$1" == "backupdb" ]]; then
  sitename_var=$2
elif [[ -z "$1" ]]; then
  echo "No site specified."
else
  sitename_var=$1
fi

parse_pl_yml
import_site_config $sitename_var
if [[ ! -d "$site_path/$sitename_var" ]]; then
  echo "Cannot find directory for >$sitename_var<, please try again or use --help for more options"
  exit 1
fi

backup_db $msg

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
