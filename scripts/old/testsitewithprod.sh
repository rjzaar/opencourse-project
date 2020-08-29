#!/bin/bash

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
. $script_root/_inc.sh;
parse_pl_yml

if [ $1 == "testsitewithprod" ] && [ -z "$2" ]
  then
sitename_var="$sites_stg"
devs="$sites_dev"
prods="$sites_localprod"
elif [ -z "$2" ]
  then
    sitename_var="$sites_stg"
    devs=$1
    prods="$sites_localprod"
   else
    sitename_var=$2
    devs=$1
    prods="$sites_localprod"
fi

import_site_config $sitename_var

echo "This will backup the current stg site: $sitename_var, then remove it. Copy the files from dev: $devs, import the prod database $prods and then update it."


# Help menu
print_help() {
    echo \
"This script will test the current loc in the stg instance using either the production site (default) or the localprod.
}
It will backup the current stg site: \$sitename_var, then remove it. Copy the files from dev, copy the private folder from prod,
import the prod database and then update it.
Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:"
}

backup_site $sitename_var

echo -e "\e[34mexport cmi\e[39m"
#sudo chown $user:www-data $folderpath/$sitename_var -R
#chmod g+w $folderpath/$sitename_var/cmi -R
drush @$devs cex -y #--destination=../cmi

echo -e "\e[34mcopy files from $devs\e[39m"
copy_site_files $devs $sitename_var

echo -e "\e[34mcopy site folder from $prods\e[39m"
copy_site_folder $prods $sitename_var

# composer install
echo -e "\e[34mcomposer install\e[39m"
cd $folderpath/$sitename_var
composer require drush/drush:~9.0
composer install
set_site_permissions
fix_site_settings

#import localprod db
# First find newest backup
unset -v latest
for file in "$folderpath/sitebackups/$prods"/*; do
  [[ $file -nt $latest ]] && latest=$file
done
Name=$(basename $latest)

bk="localprod"
restore_db $prods $sitename_var
drush @$sitename_var cr
drush @$sitename_var sset system.maintenance_mode TRUE

#uninstall modules on stg
echo "uninstalling $install_modules from $sitename_var"
drush @$sitename_var pm-uninstall $install_modules -y

#install modules
echo "installing modules $install_modules on $sitename_var"
drush @$sitename_var en -y $install_modules

echo -e "\e[34m update database\e[39m"
drush @$sitename_var updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sitename_var fra -y
echo -e "\e[34m import config\e[39m"
drush @$sitename_var cim -y #--source=../cmi
echo -e "\e[34m get out of maintenance mode\e[39m"
drush @$sitename_var sset system.maintenance_mode FALSE
drush cr

# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
