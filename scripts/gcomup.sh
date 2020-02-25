#!/bin/bash
# This will composer update and git commit changes and backup
# This follows the suggested sequence by bircher in https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al at 29:36
# That is a combination of (always presume sharing and do a backup first):
#
#  The safe sequence for updating
#  Update code: composer update
#  Run updates: drush updb
#  Export updated config: drush cex
#  Commit git add && git commit
#  Push: git push
#


# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml

if [ $1 == "gcomup" ] && [ -z "$2" ]
  then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]
  then
    sitename_var=$1
    msg="Updating."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will update to the latest composer code, commit and backup"

# Help menu
print_help() {
cat <<-HELP
This script follows the correct path to git commit changes
You just need to state the sitename, eg dev.
HELP
exit 0
}
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



