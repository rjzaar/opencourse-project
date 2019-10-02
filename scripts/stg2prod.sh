#!/bin/bash
#stg2prod
#This will backup prod, push stg to prod and import.
#This presumes teststg.sh worked, therefore opencat git is upto date with cmi export and all files.

# Overwrite Localprod With PRODuction

#start timer
SECONDS=0
parse_oc_yml
sn="$sites_localprod"
echo "Importing production site into $sn"

import_site_config $sn

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
pl backup $sn

#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
drush -y rsync @prod @$sn -O
pl fixss $sn
drush -y rsync @prod:%private @$sn:%private -O  --delete
drush -y rsync @prod:../cmi @$sn:../cmi -O  --delete

# Make sure the hash is present so drush sql will work.
sfile=$(<"$folderpath/$sn/$webroot/sites/default/settings.php")
slfile=$(<"$folderpath/$sn/$webroot/sites/default/settings.local.php")
if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]
then
if [[ ! $slfile =~ (\'hash_salt\'\] = \') ]]
then
  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
echo "\$settings['hash_salt'] = '$hash';" >> "$folderpath/$sn/$webroot/sites/default/settings.local.php"
fi
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
