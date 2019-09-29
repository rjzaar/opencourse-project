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
exit 1
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
    rm -rf "$folderpath/$sn"
fi

if [ "$install_method" == "git" ]
then
  echo "Adding git credentials"
  ssh-add /home/$user/.ssh/$github_key
  echo "Cloning $project"
  git clone $project $folderpath/$sn

  if [ "$git_upstream" != "" ]
  then
    cd $folderpath/$sn
    echo "$sn has upstream git so adding $git_upstream"
    git remote add upstream $git_upstream
  fi

elif [ "$install_method" == "composer" ]
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
elif [ "$install_method" == "file" ]
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


cd $folderpath/$sn

composer install

fix_site_settings

echo "Create private files directory"
if [ ! -d $private ]; then
  mkdir $private
fi
chmod 660 -R $private

echo "Create cmi files directory"
if [ ! -d "$folderpath/$sn/cmi" ]; then
  mkdir "$folderpath/$sn/cmi"
fi
chmod 660 -R "$folderpath/$sn/cmi"

set_site_permissions

rebuild_site

echo "Set up uri $uri. This will require sudo"
pl sudoeuri $sn

echo "Trying to go to URL $uri"
drush uli --uri=$uri

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
echo

