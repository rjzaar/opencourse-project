#!/bin/bash
#backupdb

#start timer
SECONDS=0
#This will backup everyting including opencourse-project, pull down the prod db and test it.
db="oc"
user="rob"

#backup db
echo -e "\e[34mbackup db\e[39m"
Name="OC-"$(date +"%Y-%m-%d-%H%M")".sql"
cd
cd opencat/opencourse/docroot
drush sql-dump > ~/ocbackup/localdb/$Name

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



