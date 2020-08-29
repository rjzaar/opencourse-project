#!/bin/bash
################################################################################
#                            ImportDev For Pleasy Library
#
#  @ROB add description to this script and to the print_help function!
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  29/02/2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='importdev'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Copy localprod to stg, then import dev to stg
Usage: pl $scriptname [OPTION] ... [SOURCE-SITE] [DEST-SITE]
@ROB add description please

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname 
END HELP"

}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help, --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do '$scriptname --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help; exit 0; ;;
  --)
  shift; break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

################################################################################

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
