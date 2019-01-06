#!/bin/bash

#this script will overwrite the production site with qa. All data on production will be lost.
# this is good for a first setup of production.

#push opencat
echo -e "\e[34mpush opencat\e[39m"
cd
ssh-add .ssh/github
cd opencat
git add .
git commit -m "Test QA."
git push

#push opencourse-project
echo -e "\e[34mpush opencourse-project\e[39m"
rm ocgitstore/ocsitegit/.git -rf
mv .git ocgitstore/ocsitegit/.git
cp .gitignore.ocproj .gitignore
mv ocgitstore/ocprojectgit/.git .git
git add .
git commit -m "Scripts update."
git push
cp .gitignore.ocsite .gitignore
mv .git ocgitstore/ocprojectgit/.git
cp ocgitstore/ocsitegit/.git .git -rf

cd
Name=$(date +"%Y-%m-%d")
#move what's there
Bname="OC-"$(date +"%Y-%m-%d")".sql"
echo backup external database externally
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sql-dump > ../../../ocbackup/$Bname"
echo cp settings.local.php to backup
ssh cathnet "cd opencat.org/opencourse/docroot/sites/default/ && cp settings.local.php ~/ocbackup/settings.local.php"
echo move external files to backup name
ssh cathnet mv opencat.org opencat.$Name

#git clone
echo git clone opencat
ssh cathnet eval `ssh-agent -s`
ssh cathnet ssh-add ~/.ssh/github
ssh cathnet git clone git@github.com:rjzaar/opencat.git
echo composer install
ssh cathnet "cd opencat/opencourse && composer install --no-dev"
echo copy settings.local.php to new server
ssh cathnet cp ocbackup/settings.local.php opencat/opencourse/docroot/sites/default/settings.local.php
echo copy localdb to external
cd
cd opencat/opencourse/docroot
drush sql-dump > ~/ocbackup/localdb/OC-$(date +"%Y-%m-%d").sql
scp ocbackup/localdb/OC-$(date +"%Y-%m-%d").sql cathnet:ocbackup/localdb/OC-$(date +"%Y-%m-%d").sql
echo fix file permissions, requires sudo on external server
ssh cathnet -t "sudo bash ./fix-p.sh --drupal_user=puregift --drupal_path=opencat.org/opencourse/docroot"
echo "The restoring the database requires sudo on the external server."
ssh cathnet -t "sudo ./restoredb.sh"
echo "clearing cache"
ssh cathnet "cd opencat/opencourse/docroot && drush cr"
echo "renaming folder to opencat.org to make it live"
ssh cathnet mv opencat opencat.org





