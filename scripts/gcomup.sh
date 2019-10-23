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


#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "gcomup" ] && [ -z "$2" ]
  then
  sn="$sites_dev"
  elif [ -z "$2" ]
  then
    sn=$1
    msg="Updating."
   else
    sn=$1
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
if [ "$#" = 0 ]
then
print_help
exit 1
fi

parse_pl_yml
import_site_config $sn

ocmsg "Composer update"
cd $folderpath/$sn
composer update

ocmsg "Run db updates"
drush @$sn dbup

ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $folderpath/$sn -R
chmod g+w $folderpath/$sn/cmi -R
drush @$sn cex --destination=../cmi -y

# Check?

echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m msg

ocmsg "Backup site $sn with msg $msg"
backup_site $sn $msg



