#!/bin/bash
#prod2stg
#There should be NO changes to CMI on live. if there are, they will be in sql and therefore moved down with the database to stg, but could be overwritten with feature import from dev to stg.

# Files option: setup all the files as well.
# clone opencat.
#  opencourse non dev files are already included.
# set up database
# set up settings and settings.local

# On prod: export sql
cd
echo "set prod maintenance mode"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
echo "backup prod"
ssh cathnet "./backoc.sh"
echo "prod prod mode"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo "getting /ocbackup/OC-"$(date +"%Y-%m-%d")".sql"
scp cathnet:ocbackup/OC-$(date +"%Y-%m-%d").sql ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql
echo getting private files from prod
scp cathnet:ocbackup/private.tar.gz ocbackup/private/private.tar.gz
echo Installing private files
cd opencat
rm -rf private
tar -zxf ../ocbackup/private/private.tar.gz
echo "Fix permissions, requires sudo"
sudo chown :www-data private -R
#backup whole site
echo backing up whole site.
cd
cd opencat/opencourse/docroot
drush ard --destination=~/ocbackup/site/oc.tar --overwrite
#drush archive-restore ./example.tar.gz --db-url=mysql://root:pass@127.0.0.1/dbname

#backup db
echo backup localdb
cd
cd opencat/opencourse/docroot
drush sql-dump > ~/ocbackup/localdb/oc.sql

#drop database and import the new one
drush sql-drop -y
drush sql-cli < ../../../ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

# test