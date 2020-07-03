#!/bin/bash

# Help menu
print_help() {
  cat <<-HELP
This script is used to fix permissions of a Drupal installation
you need to provide the following arguments:

  1) Path to your Drupal installation.
  2) Username of the user that you want to give files/directories ownership.
  3) HTTPD group name (defaults to www-data for Apache).

Usage: (sudo) bash ${0##*/} --drupal_path=PATH --drupal_user=USER --httpd_group=GROUP
Example: (sudo) bash ${0##*/} --drupal_path=/usr/local/apache2/htdocs --drupal_user=john --httpd_group=www-data
HELP
  exit 0
}

# Don't need sudo since should already have user control
#if [ $(id -u) != 0 ]; then
#  printf "**************************************\n"
#  printf "* Error: You must run this with sudo or root*\n"
#  printf "**************************************\n"
#  print_help
#  exit 1
#fi

drupal_path=${1%/}
drupal_user=${2}
httpd_group="${3:-www-data}"
dev="n"

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
  --drupal_path=*)
    drupal_path="${1#*=}"
    ;;
  --drupal_user=*)
    drupal_user="${1#*=}"
    ;;
  --httpd_group=*)
    httpd_group="${1#*=}"
    ;;
  --dev)
    dev="y"
    ;;
  --help) print_help ;;
  *)
    printf "***********************************************************\n"
    printf "* Error: Invalid argument, run --help for valid arguments. *\n"
    printf "***********************************************************\n"
    exit 1
    ;;
  esac
  shift
done
echo "path $drupal_path user $drupal_user group $httpd_group dev $dev"
if [ -z "${drupal_path}" ] || [ ! -d "${drupal_path}/sites" ] || [ ! -f "${drupal_path}/core/modules/system/system.module" ] && [ ! -f "${drupal_path}/modules/system/system.module" ]; then
  printf "*********************************************\n"
  printf "* Error: Please provide a valid Drupal path. *\n"
  printf "*********************************************\n"
  print_help
  exit 1
fi

if [ -z "${drupal_user}" ] || [[ $(id -un "${drupal_user}" 2>/dev/null) != "${drupal_user}" ]]; then
  printf "*************************************\n"
  printf "* Error: Please provide a valid user. *\n"
  printf "*************************************\n"
  print_help
  exit 1
fi

cd $drupal_path
cd ..
chown -R ${drupal_user}:${httpd_group} .
chmod g+w private -R
chmod g+w cmi -R

cd $drupal_path
printf "Changing ownership of all contents of "${drupal_path}":\n user => "${drupal_user}" \t group => "${httpd_group}"\n"
chown -R ${drupal_user}:${httpd_group} .

printf "Changing permissions of all directories inside "${drupal_path}" to "rwxr-x---"...\n"
find . -type d -exec chmod u=rwx,g=rx,o= '{}' \;

printf "Changing permissions of all files inside "${drupal_path}" to "rw-r-----"...\n"
find . -type f -exec chmod u=rw,g=r,o= '{}' \;

printf "Changing permissions of "files" directories in "${drupal_path}/sites" to "rwxrwx---"...\n"
cd sites

find . -type d -name files -exec chmod ug=rwx,o= '{}' \;

printf "Changing permissions of all files inside all "files" directories in "${drupal_path}/sites" to "rw-rw----"...\n"
printf "Changing permissions of all directories inside all "files" directories in "${drupal_path}/sites" to "rwxrwx---"...\n"
for x in ./*/files; do
  find ${x} -type d -exec chmod ug=rwx,o= '{}' \;
  find ${x} -type f -exec chmod ug=rw,o= '{}' \;
done

# If argument passed presume it is
if [ $dev = "y" ]; then
  echo "dev options actioned."
  if [ ! -d $drupal_path/modules/custom ]; then
    echo "mkdir $drupal_path/modules/custom"
    mkdir "$drupal_path/modules/custom"
  fi
  chmod g+w $drupal_path/modules/custom -R
  if [ ! -d $drupal_path/themes/custom ]; then
    echo " mkdir $drupal_path/themes/custom"
    mkdir "$drupal_path/themes/custom"
  fi
  chmod g+w $drupal_path/themes/custom -R
fi

#also make sure private and cmi folders have correct permissions
echo "Setting ownership on private and cmi folders"
chown -R ${drupal_user}:${httpd_group} $drupal_path/../private
chown -R ${drupal_user}:${httpd_group} $drupal_path/../cmi

echo "Set Drush permissions if drush is installed"
if [[ -f $drupal_path/vendor/drush/drush/drush ]]; then
echo "Setting Drush permissions."
 chmod a+rx $drupal_path/vendor/drush/drush/drush
  chmod a+rx $drupal_path/vendor/drush/drush/drush.php
fi

echo "Set Drupal console permissions if drupal console is installed"
if [[ -f $drupal_path/vendor/drupal/console/bin/drupal ]]; then
 echo "Setting console permissions."
  chmod a+rx $drupal_path/vendor/drupal/console/bin/drupal
  chmod a+rx $drupal_path/vendor/drupal/console/bin/drupal.php
fi

echo "Done setting proper permissions on files and directories"
