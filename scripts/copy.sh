#!/bin/bash

# See help

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "copy" ] && [ -z "$2" ]
  then
  sitename_var="$sites_stg"
  from="$sites_dev"
fi
if [ -z "$2" ]
  then
    sitename_var=$1
    from="$sites_dev"
   else
    from=$1
    sitename_var=$2
fi

echo "This will copy the site from $from to $sitename_var and then try to import the database"

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

#We need to work out where each site is.
to=$sitename_var
import_site_config $from
backup_db
from_sp=$site_path
sitename_var=$to
import_site_config $to
to_sp=$site_path

if [ -d $to_sp/$to ]
then
sudo chown $user:www-data $to_sp/$to -R
chmod +w $to_sp/$to -R
rm -rf $to_sp/$to
fi
echo "Move all files from $from to $to"
cp -rf "$from_sp/$from" "$to_sp/$to"

## Now get the name of the backup.
#cd
#cd "$folder/sitebackups/$from"
#options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
#Name=${options[0]:2}

#Note $Name was set in backup_db and will now be used in the restore_db. Nice hey.
set_site_permissions
fix_site_settings

bk=$from
restore_db

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

