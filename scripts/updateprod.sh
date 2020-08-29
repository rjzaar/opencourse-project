#!/bin/bash
################################################################################
#                Git Push and Merge Production For Pleasy Library
#
#  This will pgit share changes, ie merge with master. Used for when improving the
#  current code
#  This follows the suggested sequence by bircher in
#  https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
#  at 29:36
#  That is a combination of (always presume sharing and do a backup first):
#  PSEUDOCODE
#  The safe sequence for sharing
#  Export configuration: drush cex
#  Commit: git add && git commit
#  Merge: git pull
#  Update dependencies: composer install
#  Run updates: drush updb
#  Import configuration: drush cim
#  Push: git push
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
scriptname='gpmprod'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Git push after master merge
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
This will git commit changes with msg after merging with master. You just
need to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname -h
pl $scriptname dev (relative dev folder)
pl $scriptname tim 'First tim backup'"

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
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl gcomsh --help' for more options"
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
    shift; break; ;;
  *)
    "Programming error, this should not show up!"; ;;
  esac
done

parse_pl_yml

if [ $1 == "gcomsh" ] && [ -z "$2" ]; then
  sitename_var="$sites_dev"
elif [ -z "$2" ]; then
  sitename_var=$1
  msg="Sharing."
else
  sitename_var=$1
  msg=$2
fi

echo "This will git commit changes on site $sitename_var with msg $msg after merging with master."

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

parse_pl_yml

echo "Add credentials."
add_git_credentials

# backup latest on prod
gitprodpush


#Check changes

