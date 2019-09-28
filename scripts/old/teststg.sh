#!/bin/bash
#teststg

#start timer
SECONDS=0
#This will backup everyting including opencourse-project, pull down the prod db and test it.
db="oc"
user="rob"
#backup whole site
echo -e "\e[34mbackup whole stg site\e[39m"
cd
cd opencat/opencourse/docroot
drush ard --destination=~/ocbackup/site/oc.tar --overwrite
#drush archive-restore ./example.tar.gz --db-url=mysql://root:pass@127.0.0.1/dbname

#export cmi
echo -e "\e[34mexport cmi\e[39m"
drush cex --destination=../../cmi -y


#backup db
echo -e "\e[34mbackup stgdb\e[39m"
cd
cd opencat/opencourse/docroot
Name="OC-"$(date +"%Y-%m-%d-%H%M")".sql"
drush sql-dump > ~/ocbackup/localdb/$Name

#pull db and private files from prod
echo -e "\e[34mpull proddb\e[39m"
cd
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
ssh cathnet "./backoc.sh"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo -e "\e[34mgetting /ocbackup/OC-"$(date +"%Y-%m-%d")".sql\e[39m"
scp cathnet:ocbackup/OC-$(date +"%Y-%m-%d").sql ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql
echo -e "\e[34mgetting private files.\e[39m"
scp cathnet:ocbackup/private.tar.gz ocbackup/private/private.tar.gz
rm -rf opencat/private
cd opencat
tar -zxf ../ocbackup/private/private.tar.gz

echo -e "\e[34mFix permissions, requires sudo\e[39m"
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
sudo chown :www-data private -R


#push opencat
echo -e "\e[34mpush opencat\e[39m"
cd
ssh-add .ssh/github
cd opencat
git add .
git commit -m "Test STG."
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

#import proddb
cd
echo -e "\e[34mdrop database\e[39m"
mysqladmin -u $db -p$db -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $db -p$db -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
mysql -u $db -p$db $db < ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

#updatedb
cd opencat/opencourse/docroot
drush cr
echo -e "\e[34m update database\e[39m"
drush updb -y
echo -e "\e[34m fra\e[39m"
drush fra -y
echo -e "\e[34m import config\e[39m"
drush cim --source=../../cmi -y
echo -e "\e[34m get out of maintenance mode\e[39m"
drush sset system.maintenance_mode FALSE
drush cr



# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
#test



