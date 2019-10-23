#!/bin/bash
#teststg

#start timer
SECONDS=0
. $script_root/_inc.sh;
parse_pl_yml

if [ $1 == "importdev" ] && [ -z "$2" ]
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

echo "Importing from site $from to site $sn"
import_site_config $sn

#This will backup stg site and import dev into stage.

#backup whole site
echo -e "\e[34mbackup whole $sn site\e[39m"
#backup_site $sn

#export cmi
echo -e "\e[34mexport cmi will need sudo\e[39m"
#sudo chown $user:www-data $folderpath/$sn -R
#chmod g+w $folderpath/$sn/cmi -R
#drush @$from cex --destination=../cmi -y

#copy files from localprod to stg
echo -e "\e[34mcopy files from localprod may need sudo\e[39m"
if [ -d $folderpath/$sn ]
then
sudo chown $user:www-data $folderpath/$sn -R
chmod +w $folderpath/$sn -R
rm -rf $folderpath/$sn
fi
cp -rf "$folderpath/localprod" "$folderpath/$sn"

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
for file in "$folderpath/sitebackups/localprod"/*; do
  [[ $file -nt $latest ]] && latest=$file
done
Name=$(basename $latest)

bk="localprod"
restore_db localprod stg
drush @$sn cr


#uninstall modules on stg
echo "uninstalling $install_modules from $sn"
drush @$sn pm-uninstall $install_modules -y


#copy files over
copy_site_files $from $sn
set_site_permissions
fix_site_settings

#updatedb
drush @$sn cr
drush @$sn sset system.maintenance_mode TRUE
echo -e "\e[34m update database\e[39m"

#install modules
echo "installing modules $recipes_loc_install_modules on $sn"
drush @$sn en -y $recipes_loc_install_modules

drush @$sn updb -y
#echo -e "\e[34m fra\e[39m"
#drush @$sn fra -y
echo -e "\e[34m import config\e[39m"
drush @$sn cim --source=../cmi -y
echo -e "\e[34m get out of maintenance mode\e[39m"
drush @$sn sset system.maintenance_mode FALSE
drush cr



# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
#test



