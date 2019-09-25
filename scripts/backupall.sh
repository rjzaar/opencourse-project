#!/bin/bash
#backupdb

#start timer
SECONDS=0
#This will backup everyting including opencourse-project, pull down the prod db and test it.
db="oc"
user="rob"

#backup db
Name="OC-"$(date +"%Y-%m-%d-%H%M")".sql"
echo -e "\e[34mbackup db $Name\e[39m"
cd
cd opencat/opencourse/docroot
drush sql-dump > ~/ocbackup/localdb/$Name

#backupfiles
Name2=${Name::-4}".tar.gz"
echo -e "\e[34mbackup files $Name2\e[39m"
cd
tar -czf ocbackup/devallfiles/$Name2 opencat

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



