#!/bin/bash
#testqa
#This will delete qa, then pull down the whole prod site and set it up as qa.
db="oc"
user="rob"
#backup whole site
echo -e "\e[34mbackup whole qa site\e[39m"
cd
cd opencat/opencourse/docroot
drush ard --destination=~/ocbackup/site/oc.tar --overwrite
#drush archive-restore ./example.tar.gz --db-url=mysql://root:pass@127.0.0.1/dbname


#pull db and all files from prod
echo -e "\e[34mpull proddb\e[39m"
cd
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
ssh cathnet "./backocall.sh"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo -e "\e[34mgetting /ocbackup/OC-"$(date +"%Y-%m-%d")".sql\e[39m"
scp cathnet:ocbackup/OC-$(date +"%Y-%m-%d").sql ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql
echo -e "\e[34mgetting all files.\e[39m"
scp cathnet:ocbackup/ocall.tar.gz ocbackup/prodallfiles/ocall.tar.gz
mv  opencat opencat.$(date +"%Y-%m-%d")
mv  opencat.org opencat.org.$(date +"%Y-%m-%d")

tar -zxf ocbackup/prodallfiles/ocall.tar.gz
mv opencat.org opencat
echo -e "\e[34mmove settings back\e[39m"
mv opencat.$(date +"%Y-%m-%d")/opencourse/docroot/sites/default/settings.local.php opencat/opencourse/docroot/sites/default/settings.local.php

echo -e "\e[34mMove opencourse git back\e[39m"
cp -rf opencat.$(date +"%Y-%m-%d")/opencourse/.git opencat/opencourse/.git

echo -e "\e[34mFix permissions, requires sudo\e[39m"
sudo bash ./opencat/scripts/d8fp.sh --drupal_user=$user --drupal_path=opencat/opencourse/docroot

#import proddb
cd
echo -e "\e[34mdrop database\e[39m"
mysqladmin -u $db -p$db -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $db -p$db -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
mysql -u $db -p$db $db < ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

#updatedb
cd opencat/opencourse/docroot
drush sset system.maintenance_mode FALSE
drush cr

cd opencat/opencourse
#remove any extra options. Since each reinstall may add an extra one.
echo -e "\e[34mpatch .htaccess\e[39m"
sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

#test



