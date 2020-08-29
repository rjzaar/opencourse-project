#!/bin/bash
################################################################################
#                 Git commit for updating For Pleasy Library
#
#  This is when you want to update. This will update composer.
#
#  https://events.drupal.org/vienna2017/sessions/
#  advanced-configuration-management-config-split-et-al
#  at 29:36
#  That is a combination of (always presume sharing and do a backup first):
#
#  The safe sequence for updating
#  Update code: composer update
#  Run updates: drush updb
#  Export updated config: drush cex
#  Commit git add && git commit
#  Push: git push
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  29/02/2020 James Lim  Getopt parsing implementation, script documentation
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

# Set script name for general file use
scriptname='gcomup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Git commit and backup
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
Composer update, git commit changes and backup. This script follows the
correct path to git commit changes You just need to state the
sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname -h
pl $scriptname dev (relative dev folder)
pl $scriptname tim 'First tim backup'
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
args=$(getopt -o h -l help, --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do '$scriptname --help' for more options"
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
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

################################################################################

parse_pl_yml

if [ $1 == "gcomup" ] && [ -z "$2" ]; then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]; then
    sitename_var=$1
    msg="Updating."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will update to the latest composer code, commit and backup"

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi


import_site_config $sitename_var

if [[ "$profile" == "varbase" ]] ; then
  echo "You need to use gcomvup, not gcomup on a varbase site. Exiting"
  exit 0
fi

ocmsg "Composer update"
cd $site_path/$sitename_var
composer update

ocmsg "Run db updates"
drush @$sitename_var dbup

ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $site_path/$sitename_var -R
chmod g+w $site_path/$sitename_var/cmi -R
drush @$sitename_var cex --destination=../cmi -y

# Check?

echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m msg

ocmsg "Backup site $sitename_var with msg $msg"
backup_site $sitename_var $msg
