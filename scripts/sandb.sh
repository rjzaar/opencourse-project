#!/bin/bash
# This script will sanitize the database ready for sharing.

#start timer
SECONDS=0
#This will backup everyting including opencourse-project, pull down the prod db and test it.
db="oc"
user="rob"

cd
cd opencat/opencourse/docroot
drush scr ../../scripts/sandb.script
drush upwd admin --password=admin


#backup db
echo -e "\e[34mbackup db\e[39m"
Name="OC-"$(date +"%Y-%m-%d-%H%M")".sql"
drush sql-dump > ~/ocbackup/opencatdb/$Name

#now share the db
cd
cd ocbackup/opencatdb
addc
git add .
git commit -m "DB updated."
git push


echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))


