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
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
# Implement message function - DONE
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='backup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Backup site and database
Usage: pl backup [OPTION] ... [SOURCE] [MESSAGE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev and an optional message.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -g --git                Also create a git backup of site.

Examples:
pl backup -h
pl backup dev
pl backup tim 'First tim backup'
END HELP"
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
args=$(getopt -o hdg -l help,debug,git: --name "$scriptname" -- "$@")
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
    print_help;
    exit 3 # pass
    ;;
  -d | --debug)
  verbose="debug"
  shift
  ;;
  -g | --git)
  flag_git=1
  shift
  ;;
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
elif [[ -z "$2" ]]; then
  sitename_var=$1
 echo "No message specified."
else
  sitename_var=$1
  msg="$*"
fi

echo -e "\e[34mbackup $1 \e[39m"

################################################################################
# Read variables from pl.yml
################################################################################
parse_pl_yml

if [[ "$sitename_var" == "prod" ]] ; then
  # Backup prod
  backup_prod $msg
else
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
fi
#This isn't needed (yet?)
# backup_git $msg

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
