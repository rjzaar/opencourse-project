#!/bin/bash

# oc includes
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

import_site_config () {
# First load the defaults
rp="recipes_default_project" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; else project=""; fi
rp="recipes_default_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; else dev=""; fi
rp="recipes_default_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; else webroot=""; fi
rp="recipes_default_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; else sitename=""; fi
rp="recipes_default_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ; else auto=""; fi
rp="recipes_default_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; else apache=""; fi
rp="recipes_default_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; else dbuser=""; fi
rp="recipes_default_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; else profile=""; fi
rp="recipes_default_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ; else db=""; fi
rp="recipes_default_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; else dbpass=""; fi
rp="recipes_default_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; else uri=""; fi

sn=$1
uri="$sn.$folder"
private="/home/$user/$folder/$sn/private"
# Collect the details from oc.yml if they exist otherwise make blank
rp="recipes_${sn}_project" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; fi
rp="recipes_${sn}_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; fi
rp="recipes_${sn}_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; fi
rp="recipes_${sn}_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; fi
rp="recipes_${sn}_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ;  fi
rp="recipes_${sn}_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; fi
rp="recipes_${sn}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; fi
rp="recipes_${sn}_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; fi
rp="recipes_${sn}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ;  fi
rp="recipes_${sn}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; fi
rp="recipes_${sn}_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; fi

if [ "$db" == "" ] ; then db="$sn$folder" ; fi
if [ "$dbuser" == "" ] ; then dbuser=$db ; fi
if [ "$dbpass" == "" ] ; then dbpass=$dbuser ;fi

}

parse_oc_yml () {
# Import yaml
# presumes $script_root is set

. $script_root/scripts/parse_yaml.sh "oc.yml" $script_root

# Update all database credentials in case the user changed any.
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

# Store the site name to restore it later
storesn=$sn

#Collect the drush location: messy but it works!
# This command might list some warnings. It is a bug with drush: https://github.com/drush-ops/drush/issues/3226
drush @dev status > "$folderpath/drush.tmp"
dline=$(awk 'match($0,v){print NR; exit}' v="Drush script" "$folderpath/drush.tmp")
dlinec=$(sed "${dline}q;d" "$folderpath/drush.tmp")
dlined="/$(echo "${dlinec#*/}")"
drushloc=${dlined::-11}
rm "$folderpath/drush.tmp"

if [ -f $user_home/.drush/$folder.aliases.drushrc.php ]
then
rm  $user_home/.drush/$folder.aliases.drushrc.php
fi

cat > $user_home/.drush/$folder.aliases.drushrc.php <<EOL
<?php
/**
 * This file has been created by $site_folder/scripts/_inc.sh
 *
 */
 \$aliases['prod'] = array (
  'uri' => '$prod_uri',
  'root' => '$prod_docroot',
  'remote-user' => '$prod_user',
  'remote-host' => '$prod_uri',
);
EOL

# Now go through each site and create settings for each site.
Field_Separator=$IFS
# set comma as internal field separator for the string list
IFS=,
for site in $recipes;
do
# Database defaults
rp="recipes_${site}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdb=${!rp}; else sdb="$site$folder"; fi
rp="recipes_${site}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbuser=${!rp}; else sdbuser=$sdb; fi
rp="recipes_${site}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sdbpass=${!rp}; else sdbpass=$sdbuser; fi

cat > $(dirname $script_root)/$site.mysql <<EOL
[client]
user = $sdbuser
password = $sdbpass
host = localhost
EOL

#Now go through and create a Drush Alias for each site
import_site_config $site

cat >> $user_home/.drush/$folder.aliases.drushrc.php <<EOL
\$aliases['$site'] = array (
  'root' => '$folderpath/$site/$docroot',
  'uri' => 'http://$site.$folder',
  'path-aliases' =>
  array (
    '%drush' => '$drushloc',
    '%site' => 'sites/default/',
  ),
);
EOL

done
IFS=$Field_Separator

#Finish the Drush alias file with
echo "?>" >> "$user_home/.drush/$folder.aliases.drushrc.php"

sn=$storesn
}

ocmsg () {
if [ "$#" = 0 ]
then
exit 0
else
echo $1
fi
}

set_site_permissions () {
# This will set the correct permissions
# Persumes the following information is set
# $user
# $folder
# $sn
# $webroot

cd
echo -e "\e[34msetting correct permissions on $sn - may require sudo password\e[39m"
chown $user:www-data $folder/$sn -R

./$folder/scripts/lib/d8fp.sh --drupal_path="$folder/$sn/$webroot" --drupal_user=$user
chmod g+w $folder/$sn/private -R
chmod g+w $folder/$sn/cmi -R
}

restore_db () {
#presumes that the correct information is already set
# $Name backup sql file
# $db
# $dbuser
# $dbpass
echo "restore db start"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "use $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" != ": 0" ]
 then
  echo "The database $db does not exist. I will try to create it."
  if ! mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; then
    # This script actually just tries to create the user since the database will be created later anyway.
    echo "Unable to create the database $db. Check the mysql root credentials in mysql.cnf"
    exit 1
    else
    echo "Database $db created."
  fi
  else
  echo "Database $db exists so I will drop it."
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Database $db dropped"; else echo "Could not drop database $db: exiting"; exit 1; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created database $db using user root"; else echo "Could not create database $db using user root, exiting"; exit 1; fi
fi

  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created user $dbuser"; else echo "User $dbuser already exists"; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '"$dbuser"'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Granted user $dbuser permissions on $db"; else echo "Could not grant user $dbuser permissions on $db"; fi

echo -e "\e[34mrestore $db database using $folderpath/sitebackups/$bk/$Name\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" $db < "$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Backup database $Name imported into database $db using root"; else echo "Could not import $Name into database $db using root, exiting"; exit 1; fi

}

test_site () {
echo $sn, $db, $dbuser, $dbpass
}

db_defaults () {
# Database defaults
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
if [ -z ${db+x} ]
then
    db="$sn$folder"
fi
if [ -z ${dbuser+x} ]
then
    dbuser=$db
fi
if [ -z ${dbpass+x} ]
then
    dbpass=$dbuser
fi
echo "db defaults: db $db dbuser $dbuser dbpass $dbpass"
}

site_info () {
echo "Project  = $project"
echo "Project folder = $folder"
echo "Site folder = $sn"
echo "webroot = $webroot"
echo "Profile  = $profile"
echo "uri      = $uri"
echo "Dev      = $dev"
echo "Private folder = $private"
echo "Database = $db"
echo "Database user = $dbuser"
echo "Database password = $dbpass"
}
