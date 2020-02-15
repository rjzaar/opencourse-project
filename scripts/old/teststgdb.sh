#!/bin/bash
#teststg

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
#This will backup everyting including opencourse-project, pull down the prod db and test it.
db="oc"
user="rob"


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



