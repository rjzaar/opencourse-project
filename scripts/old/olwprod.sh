#!/bin/bash
# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_oc_yml
sitename_var="$sites_localprod"
echo "Importing production site into $sitename_var"

import_site_config $sitename_var

# Help menu
print_help() {
cat <<-HELP
This script is used to overwrite localprod with the actual external production site.
The choice of localprod is set in oc.yml under sites: localprod:
The external site details are also set in oc.yml under prod:
Note: once localprod has been locally backedup, then it can just be restored from there if need be.
HELP
exit 0
}


#First backup the current localprod site.
pl backup $sitename_var

#pull db and all files from prod
drush -y rsync @prod @$sitename_var -O
pl fixss $sitename_var
drush -y rsync @prod:%private @$sitename_var:%private -O  --delete
drush -y rsync @prod:../cmi @$sitename_var:../cmi -O  --delete

# Make sure the hash is present so drush sql will work.
# copy hash from settings.php.old to settings.local.php
if [ -f "$folderpath/$sitename_var/$webroot/sites/default/settings.php.old" ]
then
hlinenum=$(awk 'match($0,v){print NR; exit}' v="hash_salt'] = '" "$folderpath/$sitename_var/$webroot/sites/default/settings.php.old")
hline=$(sed "${hlinenum}q;d" "$folderpath/$sitename_var/$webroot/sites/default/settings.php.old")
echo $hline >> "$folderpath/$sitename_var/$webroot/sites/default/settings.local.php"
fi

# Now get the database
#This command wasn't fully working.
# This one does
Namepath="$folderpath/sitebackups/localprod"
Name="$folderpath/sitebackups/localprod/prod$(date +%Y%m%d\T%H%M%S-).sql"
drush @prod sql-dump  --gzip > "$Name.gz"
gzip -d "$Name.gz"


#Now import it
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $Name 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Production database imported into database $db using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi

drush @localprod cr

# Make sure url is setup and open it!
pl sudoeuri localprod
pl open localprod
# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
rm "$Name.gz"
exit 0



echo -e "\e[34mpull proddb\e[39m"
Name="prod-$(date +"%Y-%m-%d").sql"
Lname="prod-(date +%Y%m%d\T%H%M%S)"
cd
ssh $github_user "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"
ssh $github_user "./backupprod.sh"
ssh $github_user "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"
echo -e "\e[34mgetting $Name\e[39m"
scp $github_user:"ocbackup/$Name" "$folderpath/sitesbackup/prod/$Lname.sql"
echo -e "\e[34mgetting all files.\e[39m"
scp $github_user:ocbackup/ocall.tar.gz "$folderpath/sitesbackup/prod/$Lname.tar.gz"

restore prod localprod 1

tar -zxf ocbackup/prodallfiles/ocall.tar.gz
mv opencat.org $ofolder
echo -e "\e[34mmove settings back\e[39m"
mv $ofolder.$(date +"%Y-%m-%d")/opencourse/docroot/sites/default/settings.local.php $ofolder/opencourse/docroot/sites/default/settings.local.php

echo -e "\e[34mMove opencourse git back\e[39m"
cp -rf $ofolder.$(date +"%Y-%m-%d")/opencourse/.git $ofolder/opencourse/.git

echo -e "\e[34mFix permissions, requires sudo\e[39m"
sudo bash ./$ofolder/scripts/d8fp.sh --drupal_user=$user --drupal_path=$ofolder/opencourse/docroot

#import proddb
cd
echo -e "\e[34mdrop database\e[39m"
mysqladmin -u $dbuser -p$dbpass -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $dbuser -p$dbpass -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
mysql -u $dbuser -p$dbpass $db < ocbackup/proddb/OC-$(date +"%Y-%m-%d").sql

#updatedb
cd $ofolder/opencourse/docroot
drush sset system.maintenance_mode FALSE
drush cr

cd
cd $ofolder/opencourse
#remove any extra options. Since each reinstall may add an extra one.
echo -e "\e[34mpatch .htaccess\e[39m"
sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess


#restore db
db_defaults
restore_db


#test



