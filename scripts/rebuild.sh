#!/bin/bash
################################################################################
#                       make dev mode For Pleasy Library
#
#  This script is used to rebuild a particular site's database. You just need
#  to state the sitename, eg loc.
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
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-rebuild'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Usage: pl rebuild [OPTION] ... [SITE]
This script is used to rebuild a particular site's database. You just need to
state the sitename, eg loc.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
HEREDOC
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
args=$(getopt -o h -l help --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl rebuild --help' for more options"
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
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done
# This task must be run by pl "task name" arguments
if [ -z $folder ]; then
  echo "This task must be run by putting pl before it and no .sh, eg pl rebuild loc"
  exit 1
fi

#restore site and database
# $1 is the backup
# $2 if present is the site to restore into
# $sitename_var is the site to import into
# $bk is the backed up site.

if [ $1 == "rebuild" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 1
fi
sitename_var=$1

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

rebuild_site

# Could check here is url is set or not.

echo "Trying to go to URL $uri"
drush uli --uri=$uri

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
echo



