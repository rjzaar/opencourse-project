#!/bin/bash
#backup db and files

#start timer
SECONDS=0
echo -e "\e[34mbackup $1 \e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

sn=$1
folder=$(basename $(dirname $script_root))
webroot="docroot"
parse_oc_yml
import_site_config $sn

#backup db.
#use git: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/set-up-a-local-development-drupal-0-7
cd
# Check if site backup folder exists
if [ ! -d "$folder/sitebackups/$sn" ]; then
  mkdir "$folder/sitebackups/$sn"
fi
cd "$folder/$sn"
#this will not affect a current git present
git init
cd "$webroot"
Name=$(date +%Y%m%d\T%H%M%S-)`git branch | grep \* | cut -d ' ' -f2 | sed -e 's/[^A-Za-z0-9._-]/_/g'`-`git rev-parse HEAD | cut -c 1-8`.sql

echo -e "\e[34mbackup db $Name\e[39m"
drush sql-dump --structure-tables-key=common --result-file="../../sitebackups/$sn/$Name"

#backupfiles
Name2=${Name::-4}".tar.gz"

echo -e "\e[34mbackup files $Name2\e[39m"
cd ../../
tar -czf sitebackups/$sn/$Name2 $sn

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



