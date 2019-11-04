#!/bin/bash

# See help

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "copy" ] && [ -z "$2" ]
  then
  sn="$sites_stg"
  from="$sites_dev"
fi
if [ -z "$2" ]
  then
    sn=$1
    from="$sites_dev"
   else
    from=$1
    sn=$2
fi

echo "This will copy the site from $from to $sn and then try to import the database"

# Help menu
print_help() {
cat <<-HELP
This script will copy one site to another site. It will copy all files, set up the site settings and import the database.
If no argument is given, it will copy dev to stg
If one argument is given it will copy dev to the site specified
If two arguments are give it will copy the first to the second.
HELP
exit 0
}

if [ -d $folderpath/$sn ]
then
sudo chown $user:www-data $folderpath/$sn -R
chmod +w $folderpath/$sn -R
rm -rf $folderpath/$sn
fi
echo "Move all files from $from to $sn"
cp -rf "$folderpath/$from" "$folderpath/$sn"

storesn=$sn
sn=$from
import_site_config $sn
backup_db $from
sn=$storesn
import_site_config $sn
bk=$from
#Note $Name was set in backup_db and will now be used in the restore_db. Nice hey.


fix_site_settings
set_site_permissions
restore_db

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

