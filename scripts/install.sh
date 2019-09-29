#!/bin/bash

# Get the helper functions etc.
. $script_root/_inc.sh;

#. $script_root/lib/common.inc.sh;
#. $script_root/lib/db.inc.sh;
#. $script_root/scripts/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to install a variety of drupal flavours particularly opencourse
This will use opencourse-project as a wrapper. It is presumed you have already cloned opencourse-project.
You just need to specify the site name as a single argument.
All the settings for that site are in oc.yml
If no site name is given then the default site is created.

HELP
exit 0
}

#auto="y"
#folder=$(basename $(dirname $script_root))
#webroot="docroot" # or could be web or html
#project="rjzaar/opencourse:8.7.x-dev"
## For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
## there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and
#sn="dev"
#profile="varbase"
#dev="y"

parse_oc_yml

#Import oc.yml settings
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

if [ "$#" = 0 ]
then
sn="default"
else
# Check to see if recipe is present
# Get the sitename
for i in "$@"
do
case $i in
    *[^[:alnum:]]*)
    ;;
    *)
    sn=$i
    ;;
esac
done
echo "Looking for recipe $sn"
if [[ $recipes != *"$sn"* ]]
then
echo "No recipe for $sn! Current recipes include $recipes. Please add a recipe to oc.yml for $sn"
fi
fi

import_site_config $sn

#db_defaults

echo "Installing $sn"
site_info

# Check to see if folder already exits.
if [ -d "$folderpath/$sn" ]; then
    read -p "$sn exists. If you proceed, $sn will first be deleted. Do you want to proceed?(Y/n)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    rm -rf $sn
fi

if [ "$install_method" = "git" ]
then
    echo "Adding git credentials"
     ssh-add /home/$user/.ssh/$github_key
     cd $folderpath
     git clone $project $sn

    echo "move to project folder $folder"
    if [ "$git_upstream" != "" ]
    then
      cd $folderpath/$sn
      echo "$sn has upstream git so adding $git_upstream"
      git remote add upstream $git_upstream
    fi

elif [ "$install_method" = "composer" ]
    then
    if [ "$dev" = "y" ]
    then
        echo "Setting composer install to dev."
        devs="--stability dev"
    else
        devs=""
    fi

    echo "Run composer create project: $project"
     composer create-project $project $sn $devs --no-interaction
elif [ "$install_method" = "file" ]
    then
    if [ ! -d "$folderpath/downloads" ]
    then
    mkdir "$folderpath/downloads"
    fi
    cd "$folderpath/downloads"
    Name="$sn.tar.gz"
    wget -O $Name $project
    tar -xf $Name -C "$folderpath/$sn"

    else
    echo "No install method specified. You need to at least edit the default recipe in oc.yml and specify \"install_method\"."
    exit 1
    fi
fi

cd $folderpath/$sn

composer install

fix_site_settings

echo "Create private files directory"
if [ ! -d $private ]; then
  mkdir $private
fi
chmod 770 -R $private

set_site_permissions

echo "install drupal site $sn"
cd $folderpath/$sn/$webroot

# drush status
# drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
 drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$sn"
#don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.

#sudo bash ./d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user #shouldn't need this, since files don't need to be changed.
#chmod g+w -R $folder/$webroot/modules/custom

if [ "$oc" = "y" ]
then
  #install all required modules
  echo "Install modules for opencourse"
  #drush en -y oc_theme
  #for some reason does not set it as default!
  drupal theme:install  oc_theme --set-default
  #drush cr #is this needed here?
  drush

  if [ "$dev" = "y" ]
  then
  drush en -y oc_dev
  #uninstall the wrapper. Will leave all dependencies installed.
  drush pm-uninstall -y oc_dev
  else
  drush en -y oc_prod
  fi

  drush pm-uninstall -y oc_prod
  cd
  if [ "$install" = "y" ]
  then
  echo "fix permissions, requires sudo"
  # This is only if the install hasn''t been run before. All files should have correct permissions.
  sudo bash ./$folder/scripts/d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user
  chmod g+w -R $folder/$webroot/modules/custom
  chmod g+w $folder/private -R
  fi
  cd $sn/$folder/$webroot
  drush config-set system.theme default oc_theme -y
fi
cd
cd $sn/$folder/$webroot
if [ "$dev" = "y" ]
then
echo "Setting to dev mode"
 drupal site:mode dev
 drush php-eval 'node_access_rebuild();'
fi
if [ "$migrate" = "y" ] && [ "$oc" = "y" ]
then
    echo "Run migrations"
    cd
    cd $sn/$folder/$webroot
    ../../scripts/resoc.sh install
    #Now run the script to embed the videos, external and internal links into the body.
    echo "Incorporate video and links into ocdoc body."
    drush scr ../../scripts/updoc.php
fi
#try again
###drush config-set system.theme default oc_theme -y
echo "Trying to go to URL $uri"
 drush uli --uri=$uri

