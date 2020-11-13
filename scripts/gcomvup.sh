#!/bin/bash
################################################################################
#                 Git commit for updating varbase For Pleasy Library
#
#  This is when you want to update. This will update to latest varbase stable.
#
#  https://events.drupal.org/vienna2017/sessions/
#  advanced-configuration-management-config-split-et-al
#  at 29:36
#  That is a combination of (always presume sharing and do a backup first):
#
#  The safe sequence for updating
#  Update code: varbase update
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
scriptname='gcomvup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Git commit and update to latest varbase stable
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
Varbase update, git commit changes and backup. This script follows the
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

if [ $1 == "gcomvup" ] && [ -z "$2" ]; then
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

parse_pl_yml
import_site_config $sitename_var

# Check to see if already on the latest
latest_varbase=$(git ls-remote --tags git://github.com/Vardot/varbase-project.git | tail -n1 | sed 's/.*\///; s/\^{}//')

#### More work needs to be done here!!! Add in material from gcomup2upstream.sh now in old folder!!!


ocmsg "Composer update"
cd $site_path/$sitename_var
echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Composer install"
composer install

ocmsg "Run db updates"
drush @$sitename_var updb

ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $site_path/$sitename_var -R
chmod g+w $site_path/$sitename_var/cmi -R
drush @$sitename_var cex --destination=../cmi -y
pl gcom $sitename_var "pre-up2upstream commit"

# Move Readme out the way for now.
echo "Move readme out the way"
mv README.md README.md1
echo "Add upstream."
git remote add upstream git@github.com:Vardot/varbase-project.git
echo "Fetch upstream"
git fetch upstream

echo "Now try merge."
git merge upstream/8.8.x

#Now overide the upstream readme.
echo "Now move readme back"
mv README.md1 README.md

ocmsg "Update dependencies: composer install"
# Should I remove the lock first?
rm composer.lock
composer install

##### todo get varbase update working!!!!
varbase update

ocmsg "Run db updates"
drush @$sitename_var updb

## export or import??
ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $site_path/$sitename_var -R
chmod g+w $site_path/$sitename_var/cmi -R
drush @$sitename_var cex --destination=../cmi -y

# Check?


pl gcom $sitename_var "Updated to lastest varbase"

ocmsg "Backup site $sitename_var with msg $msg"
backup_site $sitename_var $msg

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))