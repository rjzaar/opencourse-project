#!/bin/bash
################################################################################
#                 Backup db and files For Pleasy Library
#
#  This script is used to backup a particular site's files and database.
#  You just need to state the sitename, eg dev
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
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
# Implement message function
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-backup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl backup [OPTION] ... [SOURCE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -m --message='msg'      Enter an optional message to accompany the backup

Examples:
pl backup -h
pl backup dev
pl backup tim -m 'First tim backup'
pl backup --message='Love' love
END HELP"
exit 0
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
args=$(getopt -o hm: -l help,message: --name "$scriptname" -- "$@")
# echo "$args"

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
    print_help; exit 0; ;;
  -m | --message)
    shift
    msg="$(echo "$1" | sed 's/^=//g')"
    echo "Msg = $msg"
    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done


# No arguments
################################################################################
# if no argument found exit and display error. User must input directory for
# backup else this script will fail.
################################################################################
if [[ "$1" == "backup" ]] && [[ -z "$2" ]]; then
 echo "No site specified."
elif [[ "$1" == "backup" ]] ; then
   sitename_var=$2
elif [[ -z "$1" ]]; then
 echo "No site specified."
else
  sitename_var=$1
fi


# (what do these do?)
echo -e "\e[34mbackup $1 \e[39m"
. $script_root/_inc.sh;

################################################################################
# Read variables from pl.yml
################################################################################
parse_pl_yml

################################################################################
# Import the site config for chosen site
################################################################################
import_site_config $sitename_var
if [[ ! -d "$site_path/$sitename_var" ]]; then
  echo "Cannot find directory for "$sitename_var", please try again or use --help for more options"
fi
################################################################################
# Now backup the site
################################################################################
backup_site $msg

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
