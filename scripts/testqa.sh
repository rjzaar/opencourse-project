#!/bin/bash
#testqa
#This will pull down the prod db and test it.
db="opencourse"
user="rob"
#backup whole site
echo "backup whole qa site"
cd
cd opencat/opencourse/docroot
drush ard --destination=~/ocbackup/site/oc.tar --overwrite
#drush archive-restore ./example.tar.gz --db-url=mysql://root:pass@127.0.0.1/dbname

#export cmi
echo "export cmi"
drush cex --destination=../../cmi -y

#backup db
echo "backup qadb"
cd
cd opencat/opencourse/docroot
drush sql-dump > ~/ocbackup/localdb/oc.sql

#pull db and private files from prod
echo "pull proddb"
cd
ssh puregift "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
ssh puregift "./backoc.sh"
ssh puregift "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo "getting /ocbackup/OC-"$(date +"%Y-%m-%d")".sql"
scp puregift:ocbackup/OC-$(date +"%Y-%m-%d").sql ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql
echo "getting private files."
scp puregift:ocbackup/private.tar.gz ocbackup/private/private.tar.gz
rm -rf opencat/private
cd opencat
tar -zxf ../ocbackup/private/private.tar.gz

echo "Fix permissions, requires sudo"
sudo chown :www-data private -R


#push opencat
echo "push opencat"
cd
ssh-add .ssh/github
cd opencat
git add .
git commit -m "Test QA."
git push

#import proddb
cd
echo "drop database"
mysqladmin -u $db -p$db -f drop $db;
echo "recreate database"
mysql -u $db -p$db -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql -u $db -p$db $db < ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

#updatedb
cd opencat/opencourse/docroot
drush cr
drush updb -y
drush fra -y
drush cim --source=../../cmi -y
drush sset system.maintenance_mode FALSE
drush cr

#test



