#!/bin/bash
# This will git share changes, ie merge with master
# This follows the suggested sequence by bircher in https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al at 29:36
# That is a combination of (always presume sharing and do a backup first):
#
#  The safe sequence for sharing
#  Export configuration: drush cex
#  Commit: git add && git commit
#  Merge: git pull
#  Update dependencies: composer install
#  Run updates: drush updb
#  Import configuration: drush cim
#  Push: git push
#
#

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "gcomsh" ] && [ -z "$2" ]
  then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]
  then
    sitename_var=$1
    msg="Sharing."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will git commit changes on site $sitename_var with msg $msg after merging with master."
# Help menu
print_help() {
cat <<-HELP
This will git commit changes with msg after merging with master.
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
import_site_config $sitename_var

ocmsg "Backup site $sitename_var with msg premerge"
backup_site $sitename_var "premerge"

ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $site_path/$sitename_var -R
chmod g+w $site_path/$sitename_var/cmi -R
drush @$sitename_var cex --destination=../cmi -y

echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m msg

ocmsg "Git pull"
git checkout master # Go to the master branch
git pull # Get the latest code base
git checkout feature/[my-existing-branch] # Go back to feature branch
git merge master # If you get any merge conflicts, see next paragraph


ocmsg "Update dependencies: composer install"
composer install

ocmsg "Run db updates"
drush @$sitename_var dbup

ocmsg "Import configuration: drush cim"
drush @$sitename_var cim

ocmsg "Push: git push"
git push # Include latest master commits in remote feature branch




