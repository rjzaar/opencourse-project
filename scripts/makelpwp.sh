#!/bin/bash
# Overwrite Localprod With PRODuction

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml
sitename_var="$sites_localprod"
echo "Importing production site into $sitename_var"

import_site_config $sitename_var
step=1
for i in "$@"
do
case $i in
    -s=*|--step=*)
    step="${i#*=}"
    shift # past argument=value
    ;;
    -h|--help) print_help;;
    *)
    shift # past argument=value
    ;;
esac
done


# Help menu
print_help() {
cat <<-HELP
This script is used to overwrite localprod with the actual external production site.
The choice of localprod is set in pl.yml under sites: localprod:
The external site details are also set in pl.yml under prod:
Note: once localprod has been locally backedup, then it can just be restored from there if need be.
HELP
exit 0
}

if [ $step -gt 1 ] ; then
  echo "Starting from step $step"
fi

#First backup the current localprod site if it exists
if [ $step -lt 2 ] ; then
echo "step 1: backup current sitename_var $sitename_var"
pl backup $sitename_var "presync"
fi
#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
#echo "pre rsync"
#drush -y rsync @prod @$sitename_var -- --omit-dir-times --delete

if [ $step -lt 3 ] ; then
echo "step 2: backup production"
# Make sure ssh identity is added
eval `ssh-agent -s`
ssh-add ~/.ssh/$prod_alias
to=$sitename_var
backup_prod
# sql file: $Namesql
# all files: $folderpath/sitebackups/prod/$Name.tar.gz
sitename_var=$to
fi

if [ $step -lt 4 ] ; then
echo "step 3: restore production to $sitename_var"
pl restore prod $sitename_var -y
fi

if [ $step -lt 5 ] ; then
echo -e "$Green step 4: Fix site settings $Color_off"
fix_site_settings
fi

#if [ $step -lt 6 ] ; then
#echo "step 5: rsync private and cmi folders"
#drush -y rsync @prod:../private @$sitename_var:../ -- --omit-dir-times  --delete
#drush -y rsync @prod:../cmi @$sitename_var:../ -- --omit-dir-times  --delete
#fi

if [ $step -lt 6 ] ; then
echo "step 5: Fix site permissions"
set_site_permissions
fi

# Now get the database
#This command wasn't fully working.
# This one does
#echo "Now get the database"
#Name="prod$(date +%Y%m%d\T%H%M%S-).sql"
#Namepath="$folderpath/sitebackups/localprod"
#SFile="$folderpath/sitebackups/localprod/$Name"
## The next 2 commands don't work...
##drush @prod sql-dump  --gzip > "$SFile.gz"
##gzip -d "$SFile.gz"
## So try this instead
#drush @prod sql-dump --gzip --result-file="../../../$Name"
#scp cathnet:"$Name.gz" "$Namepath/$Name.gz"
#gzip -d "$Namepath/$Name.gz"
#
#
#
##Now import it
#result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $SFile 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
#if [ "$result" = ": 0" ]; then echo "Production database imported into database $db using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi

drush @localprod cr

pl backup $sitename_var "postsync"

# Make sure url is setup and open it!
sudoeuri localprod
pl open localprod
# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
