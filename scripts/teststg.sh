#!/bin/bash

#start timer
SECONDS=0
. $script_root/_inc.sh;
parse_pl_yml

if [ $1 == "teststg" ] && [ -z "$2" ]
  then
sn="$sites_stg"
devs="$sites_dev"
prods="$sites_localprod"
elif [ -z "$2" ]
  then
    sn=$1
    devs="$sites_dev"
    prods="$sites_localprod"
   else
    sn=$1
    devs="$sites_dev"
    prods="$sites_localprod"
fi

import_site_config $sn

echo "This will backup the current stg site: $sn, then remove it. Copy the files from dev: $devs, import the prod database $prods and then update it."

# Help menu
print_help() {
cat <<-HELP
This script will test the current loc in the stg instance using either the production site (default) or the localprod.
It will backup the current stg site: $sn, then remove it. Copy the files from dev, copy the private folder from prod,
import the prod database and then update it.
HELP
exit 0
}

backup_site $sn

echo -e "\e[34mexport cmi\e[39m"
#sudo chown $user:www-data $folderpath/$sn -R
#chmod g+w $folderpath/$sn/cmi -R
drush @$devs cex -y #--destination=../cmi

echo -e "\e[34mcopy files from $devs\e[39m"
copy_site_files $devs $sn

echo -e "\e[34mcopy site folder from $prods\e[39m"
copy_site_folder $prods $sn

# composer install
echo -e "\e[34mcomposer install\e[39m"
cd $folderpath/$sn
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
restore_db $prods $sn
drush @$sn cr
drush @$sn sset system.maintenance_mode TRUE

#uninstall modules on stg
echo "uninstalling $install_modules from $sn"
drush @$sn pm-uninstall $install_modules -y

#install modules
echo "installing modules $install_modules on $sn"
drush @$sn en -y $install_modules

echo -e "\e[34m update database\e[39m"
drush @$sn updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sn fra -y
echo -e "\e[34m import config\e[39m"
drush @$sn cim -y #--source=../cmi
echo -e "\e[34m get out of maintenance mode\e[39m"
drush @$sn sset system.maintenance_mode FALSE
drush cr

# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))