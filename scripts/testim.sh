#!/bin/bash
#start timer
SECONDS=0
parse_pl_yml
sitename_var="$sites_stg"
from="$sites_dev"
import_site_config $sitename_var

echo "This will copy the custom theme and modules folder from $from to $sitename_var and then try to install $install_modules"

# Help menu
print_help() {
cat <<-HELP
This script is used in the scenario that you are working with features and there is a problem of dependencies.
In other words there may be a dependency loop between features modules. A fresh install would stop at the modules being installed
since the modules can't be installed due to dependency issues. To quickly debug this, we need to just have a duplicate site
with a fresh database install, but it stopped at installing the custom modules (amongst possible others).
So we just want to copy the new files from the dev site to the stg site to test it out.
That is copy custom over and then try to install the custom modules to see if it works or what the issue is.
HELP
exit 0
}

rm -rf "$site_path/$sitename_var/$webroot/modules/custom"
rm -rf "$site_path/$sitename_var/$webroot/themes/custom"
cp -rf "$site_path/$from/$webroot/modules/custom" "$site_path/$sitename_var/$webroot/modules/custom"
cp -rf "$site_path/$from/$webroot/themes/custom" "$site_path/$sitename_var/$webroot/themes/custom"

chown $user:www-data $site_path/$sitename_var/$webroot/modules/custom -R
chown $user:www-data $site_path/$sitename_var/$webroot/themes/custom -R
chmod g+w $site_path/$sitename_var/$webroot/modules/custom -R
chmod g+w $site_path/$sitename_var/$webroot/themes/custom -R
drush @$sitename_var -y en  $install_modules

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

