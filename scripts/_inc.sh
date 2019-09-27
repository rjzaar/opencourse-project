#!/bin/bash

# oc includes
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

import_site_config () {
	sn=$1
# Collect the details from oc.yml if they exist
rp="recipes_${sn}_project" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then project=${!rp} ; fi
rp="recipes_${sn}_dev" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dev=${!rp} ; fi
rp="recipes_${sn}_webroot" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then webroot=${!rp} ; fi
rp="recipes_${sn}_sitename" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then sitename=${!rp} ; fi
rp="recipes_${sn}_auto" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then auto=${!rp} ; fi
rp="recipes_${sn}_apache" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then apache=${!rp} ; fi
rp="recipes_${sn}_dbuser" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbuser=${!rp} ; fi
rp="recipes_${sn}_profile" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then profile=${!rp} ; fi
rp="recipes_${sn}_db" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then db=${!rp} ; fi
rp="recipes_${sn}_dbpass" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then dbpass=${!rp} ; fi
rp="recipes_${sn}_uri" ; rpv=${!rp}; if [ "$rpv" !=  "" ] ; then uri=${!rp} ; fi
}

parse_oc_yml () {
# Import yaml
# presumes $script_root is set

. $script_root/scripts/parse_yaml.sh "oc.yml" $script_root
# Update all database credentials in case the user changed any.
folder_path=$(dirname $script_root)
user_home=$(dirname $folder_path)

# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

# Store the site name to restore it later
storesn=$sn

#Collect the drush location: messy but it works!
drush status > drush.tmp
dline=$(awk 'match($0,v){print NR; exit}' v="Drush script" drush.tmp)
dlinec=$(sed "${dline}q;d" drush.tmp)
dlined="/$(echo "${dlinec#*/}")"
drushloc=${dlined::-11}
rm drush.tmp

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
echo -e "\e[34msetting correct permissions on $sn - will require sudo password\e[39m"
chown $user:www-data opencat -R
./$folder/scripts/d8fp.sh --drupal_path="$folder/$sn/$webroot" --drupal_user=$user
chmod g+w $folder/$sn/private -R
}

restore_db () {
#presumes that the correct information is already set
# $Name backup sql file
# $db
# $dbuser
# $dbpass
echo "restore db start"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "use $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
# result 1 if error
echo "res >$result<"
if [ "$result" != ": 0" ]
 then
  echo "The database $db does not exist. I will try to create it."

  if ! mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; then
  # This script actually just tries to create the user since the database will be created later anyway.
  echo "Unable to create the database $db. Check the mysql root credentials in mysql.cnf"
  exit 1
  else
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Created user $dbuser"; else echo "Could not create user $dbuser"; fi
  result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '"$dbuser"'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" = ": 0" ]; then echo "Granted user $dbuser permissions on $db"; else echo "Could not grant user $dbuser permissions on $db"; fi
  fi
  else
  echo "Database $db exits"
fi

echo -e "\e[34mdrop current database\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/$sn.mysql" -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" != ": 0" ]
then
echo "Could not drop $db using user $dbuser"
# Might not have user or credentials
echo "adding credentials"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Created user $dbuser  using root"; else echo "Could not create user $dbuser  using root"; fi

#mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "CREATE USER $dbuser@localhost IDENTIFIED BY '"$dbpass"';"
echo "adding permissions"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" -e "GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON $db.* TO '"$dbuser"'@'localhost' IDENTIFIED BY '"$dbpass"';" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Granted user $dbuser permissions on $db using root"; else echo "Could not grant user $dbuser permissions on $db using root"; fi
result=$(mysql --defaults-extra-file="$folderpath/$sn.mysql" -e "DROP DATABASE $db;" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
  if [ "$result" != ": 0" ]
  then
  echo "Could not drop database $db using user $dbuser."
  fi
else
  echo "Dropped database $db using root"
fi
echo -e "\e[34mrecreate database\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/$sn.mysql" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"; 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Created database $db using user $dbuser"; else echo "Could not create database $db using user $dbuser"; fi
#mysql --defaults-extra-file="$folderpath/$sn.mysql" -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
echo -e "\e[34mrestore stg database using $folderpath/sitebackups/$bk/$Name\e[39m"
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" $db < "$folderpath/sitebackups/$bk/$Name" 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Backup database $Name imported into database $db using $dbuser"; else echo "Could not import $Name into database $db using $dbuser"; fi

#mysql --defaults-extra-file="$folderpath/mysql.cnf" $db < "$folderpath/sitebackups/$bk/$Name"
}

test_site () {
echo $sn, $db, $dbuser, $dbpass
}

db_defaults () {
# Database defaults
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
