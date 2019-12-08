#!/bin/bash

# See help

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "testi" ] && [ -z "$2" ]
  then
  sn="$sites_stg"
  from="$sites_dev"
elif [ -z "$2" ]
  then
    sn=$1
    from="$sites_dev"
   else
    from=$1
    sn=$2
fi

import_site_config $sn

echo "This will copy the custom theme and modules folder from $from to $sn and then try to rebuild the database"

# Help menu
print_help() {
cat <<-HELP
This script is used in the scenario that you are working with features and there is a problem of dependencies.
In other words there may be a dependency loop between features modules. A fresh install would stop at the modules being installed
since the modules can't be installed due to dependency issues. To quickly debug this, we need to just have a duplicate site
with a fresh database install, but it stopped at installing the custom modules (amongst possible others).
So we just want to copy the new files from the dev site to the stg site to test it out.
That is copy custom over and then try to install the custom modules to see if it works or what the issue is.
If no argument is given, it will go from dev to stg
If one argument is given it will go from dev to the site specified
If two arguments are give it will go from the first to the second.
HELP
exit 0
}

rm -rf "$site_path/$sn/$webroot/modules/custom"
rm -rf "$site_path/$sn/$webroot/themes/custom"
cp -rf "$site_path/$from/$webroot/modules/custom" "$site_path/$sn/$webroot/modules/custom"
cp -rf "$site_path/$from/$webroot/themes/custom" "$site_path/$sn/$webroot/themes/custom"

chown $user:www-data $site_path/$sn/$webroot/modules/custom -R
chown $user:www-data $site_path/$sn/$webroot/themes/custom -R
chmod g+w $site_path/$sn/$webroot/modules/custom -R
chmod g+w $site_path/$sn/$webroot/themes/custom -R

rebuild_site

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

