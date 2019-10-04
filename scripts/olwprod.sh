#!/bin/bash
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
pl backup $sn "presync"

#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
echo "pre rsync"
drush -y rsync @prod @$sn -- --omit-dir-times --delete
echo "post first rsync"
pl fixss $sn
drush -y rsync @prod:../private @$sn:../private -- --omit-dir-times  --delete
drush -y rsync @prod:../cmi @$sn:../cmi -- --omit-dir-times  --delete

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

pl backup $sn "postsync"

# Make sure url is setup and open it!
pl sudoeuri localprod
pl open localprod
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
