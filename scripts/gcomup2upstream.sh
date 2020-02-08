#!/bin/bash
# This will update to the upstream git
# It presupposes you have already merged branch with master
#
#  git checkout master
#  git pull origin master
#  git merge feature/[my-existing-branch]
#  git push origin master
#

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "gcomup2upstream" ] && [ -z "$2" ]
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

echo "This will merge branch with master"
# Help menu
print_help() {
cat <<-HELP
This will merge branch with master
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
#This script will update opencourse to the varbase-project upstream
cd
cd $site_path/$sitename_var
echo "Add credentials."
ssh-add ~/.ssh/$github_key

#Do a commit first?
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
git merge upstream/8.7.x

#Now overide the upstream readme.
echo "Now move readme back"
mv README.md1 README.md

ocmsg "Update dependencies: composer install"
# Should I remove the lock first?
rm composer.lock
composer install

ocmsg "Run db updates"
drush @$sitename_var updb

ocmsg "Import configuration: drush cim"
drush @$sitename_var cim

pl gcom $sitename_var "Updated to lastest varbase"



