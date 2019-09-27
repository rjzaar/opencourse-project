#!/bin/bash
#start timer
SECONDS=0
. $script_root/_inc.sh;
folder=$(basename $(dirname $script_root))
folderpath=$(dirname $script_root)
webroot="docroot"
parse_oc_yml
sn="$sites_localprod"

import_site_config $sn

# Help menu
print_help() {
cat <<-HELP
This script is used to overwrite localprod with the actual external production site.
The choice of localprod is set in oc.yml under sites: localprod:
The external site details are also set in oc.yml under prod:
Note: once localprod has been locally backedup, then it can just be restored from there if need be.
HELP
exit 0
}
#if [ "$#" = 0 ]
#then
#print_help
#exit 1
#fi

#First backup the current localprod site.
backup $sn

#pull db and all files from prod
echo -e "\e[34mpull proddb\e[39m"
Name="prod-$(date +"%Y-%m-%d").sql"
Lname="prod-(date +%Y%m%d\T%H%M%S)"
cd
ssh $github_user "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
ssh $github_user "./backupprod.sh"
ssh $github_user "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo -e "\e[34mgetting $Name\e[39m"
scp $github_user:"ocbackup/$Name" "$folderpath/sitesbackup/prod/$Lname.sql"
echo -e "\e[34mgetting all files.\e[39m"
scp $github_user:ocbackup/ocall.tar.gz "$folderpath/sitesbackup/prod/$Lname.tar.gz"

restore prod localprod 1

tar -zxf ocbackup/prodallfiles/ocall.tar.gz
mv opencat.org $ofolder
echo -e "\e[34mmove settings back\e[39m"
mv $ofolder.$(date +"%Y-%m-%d")/opencourse/docroot/sites/default/settings.local.php $ofolder/opencourse/docroot/sites/default/settings.local.php

echo -e "\e[34mMove opencourse git back\e[39m"
cp -rf $ofolder.$(date +"%Y-%m-%d")/opencourse/.git $ofolder/opencourse/.git

echo -e "\e[34mFix permissions, requires sudo\e[39m"
sudo bash ./$ofolder/scripts/d8fp.sh --drupal_user=$user --drupal_path=$ofolder/opencourse/docroot

#import proddb
cd
echo -e "\e[34mdrop database\e[39m"
mysqladmin -u $dbuser -p$dbpass -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $dbuser -p$dbpass -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
mysql -u $dbuser -p$dbpass $db < ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

#updatedb
cd $ofolder/opencourse/docroot
drush sset system.maintenance_mode FALSE
drush cr

cd
cd $ofolder/opencourse
#remove any extra options. Since each reinstall may add an extra one.
echo -e "\e[34mpatch .htaccess\e[39m"
sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess


#restore db
db_defaults
restore_db


#test



