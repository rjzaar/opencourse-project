#!/bin/bash
#stg2prod
#This will backup prod, push stg to prod and import.
#This presumes teststg.sh worked, therefore opencat git is upto date with cmi export and all files.

#On prod:
# maintenance mode
echo "prod in maintenance mode"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"

# backup db and private files
echo "backup proddb and private files"
ssh cathnet "./backoc.sh"

# pull opencat
echo "pull opencat"
ssh cathnet "./pull.sh"

#restore private files, just in case some were added between test and deploy
echo "remove prod private files"
ssh cathnet "cd opencat.org && rm -rf private"
echo "restore prod private files"
ssh cathnet "cd opencat.org && tar -zxf ../ocbackup/private.tar.gz"
echo "Fix permissions, requires sudo"
ssh -t cathnet "sudo chown :www-data opencat.org -R"
ssh -t cathnet "sudo ./fix-p.sh --drupal_user=puregift --drupal_path=/home/puregift/opencat.org/opencourse/docroot"

#update drupal
echo "prod drush updb"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush updb -y"
echo "prod drush fra"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush fra -a"
echo "prod drush cr"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush cr"

# update/cmi import
echo "prod cmi import"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush cim --source=../../cmi/ -y"
echo "prod cr"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush cr"

# out of maintenance mode
echo "prod prod mode"
ssh cathnet "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"

echo -e "\e[34mpatch .htaccess on prod\e[39m"
ssh cathnet "cd opencat.org/opencourse/docroot/ && sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess"

#for some reason this is needed again.
echo -e "\e[34mFix ownership may need sudo password.\e[39m"
ssh cathnet "sudo chown :www-data opencat.org -R"




# test again.
