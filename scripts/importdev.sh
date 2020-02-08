#!/bin/bash
#teststg

#start timer
SECONDS=0
. $script_root/_inc.sh;
parse_pl_yml

if [ $1 == "importdev" ] && [ -z "$2" ]
  then
  sitename_var="$sites_stg"
  from="$sites_dev"
elif [ -z "$2" ]
  then
    sitename_var=$1
    from="$sites_dev"
   else
    from=$1
    sitename_var=$2
fi

echo "Importing from site $from to site $sitename_var"
import_site_config $sitename_var

#This will backup stg site and import dev into stage.

#backup whole site
echo -e "\e[34mbackup whole $sitename_var site\e[39m"
#backup_site $sitename_var

#export cmi
echo -e "\e[34mexport cmi will need sudo\e[39m"
#sudo chown $user:www-data $site_path/$sitename_var -R
#chmod g+w $site_path/$sitename_var/cmi -R
#drush @$from cex --destination=../cmi -y

#copy files from localprod to stg
echo -e "\e[34mcopy files from localprod may need sudo\e[39m"
if [ -d $site_path/$sitename_var ]
then
sudo chown $user:www-data $site_path/$sitename_var -R
chmod +w $site_path/$sitename_var -R
rm -rf $site_path/$sitename_var
fi
cp -rf "$site_path/localprod" "$site_path/$sitename_var"

# composer install
echo -e "\e[34mcomposer install\e[39m"
cd $site_path/$sitename_var
composer require drush/drush:~9.0
composer install
set_site_permissions
fix_site_settings

#import localprod db
# First find newest backup
unset -v latest
for file in "$folderpath/sitebackups/localprod"/*; do
  [[ $file -nt $latest ]] && latest=$file
done
Name=$(basename $latest)

bk="localprod"
restore_db localprod stg
drush @$sitename_var cr


#uninstall modules on stg
echo "uninstalling $install_modules from $sitename_var"
drush @$sitename_var pm-uninstall $install_modules -y


#copy files over
copy_site_files $from $sitename_var
set_site_permissions
fix_site_settings

#updatedb
drush @$sitename_var cr
drush @$sitename_var sset system.maintenance_mode TRUE
echo -e "\e[34m update database\e[39m"

#install modules
echo "installing modules $recipes_loc_install_modules on $sitename_var"
drush @$sitename_var en -y $recipes_loc_install_modules

drush @$sitename_var updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sitename_var fra -y
echo -e "\e[34m import config\e[39m"
drush @$sitename_var cim --source=../cmi -y
echo -e "\e[34m get out of maintenance mode\e[39m"
drush @$sitename_var sset system.maintenance_mode FALSE
drush cr



# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
#test



