#!/bin/bash

# See help

#start timer
SECONDS=0
parse_oc_yml

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

echo "This will copy the site from $from to $sn and set permissions and site settings"

# Help menu
print_help() {
cat <<-HELP
This script will copy one site to another site. It will copy only the files but will set up the site settings.
If no argument is given, it will copy dev to stg
If one argument is given it will copy dev to the site specified
If two arguments are give it will copy the first to the second.
HELP
exit 0
}

copy_site_files $from $sn

import_site_config $sn
set_site_permissions
fix_site_settings

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

