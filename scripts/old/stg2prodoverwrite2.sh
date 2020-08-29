#!/bin/bash
#stg2prodoverwrite
#This will backup prod, and overwrite prodution with stg.
#This presumes teststg.sh worked, therefore opencat git is upto date with cmi export and all files.

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml

#prod settings are in pl.yml

if [ $1 == "stg2prodoverwrite2" ] && [ -z "$2" ]
  then
  sitename_var="$sites_stg"
elif [ -z "$2" ]
  then
    sitename_var=$1
fi

import_site_config $sitename_var

# Help menu
print_help() {
cat <<-HELP
This script will overwrite production with stg
It will first backup prod
The external site details are also set in pl.yml under prod:
HELP
exit 0
}


#First backup the current stg site.
#pl backup $sitename_var
#alternatively could use pl olwprod

#put prod in maintenance mode
echo "maintenance mode"
drush @prod sset system.maintenance_mode TRUE
echo "docroot"
drush -y rsync @$sitename_var @prod -- -O  --delete
echo "cmi"
drush -y rsync @$sitename_var:../cmi @prod:../cmi -- -O  --delete
echo "vendor"
drush -y rsync @$sitename_var:../vendor @prod:../vendor -- -O  --delete
echo "bin"
drush -y rsync @$sitename_var:../bin @prod:../bin -- -O  --delete
echo "composer.json"
drush -y rsync @$sitename_var:../composer.json @prod:../composer.json -- -O  --delete
echo "composer.lock"
drush -y rsync @$sitename_var:../composer.lock @prod:../composer.lock -- -O  --delete

# Now sync the database
drush sql:sync @$sitename_var @prod

drush @prod cr
drush @prod sset system.maintenance_mode FALSE

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0



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
