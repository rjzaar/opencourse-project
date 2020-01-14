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
All the settings for that site are in pl.yml
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

parse_pl_yml

#Import pl.yml settings
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

if [ "$#" = 0 ]
then
sn="default"
else
# Check to see if recipe is present
# Get the sitename
sn=$1
echo "Looking for recipe $sn"
if [[ $recipes != *"$sn"* ]]
then
echo "No recipe for $sn! Current recipes include $recipes. Please add a recipe to pl.yml for $sn"
exit 1
fi
fi

step=1
# Check for options
if [ "$#" -gt 1 ] ; then
for i in "$@"
do
case $i in
    -s=*|--step=*)
    step="${i#*=}"
    shift # past argument=value
    ;;
    -y|--yes)
    yes="y"
    shift
    ;;
    -h|--help) print_help;;
    *)
    shift # past argument=value
    ;;
esac
done

fi

import_site_config $sn


#db_defaults

echo "Installing $sn"
site_info
if [ $step -gt 1 ] ; then
  echo "Starting from step $step"
fi


# Check to see if folder already exits.
if [ $step -lt 2 ] ; then
echo -e "$Cyan step 1: checking if folder $sn exists $Color_Off"

if [ -d "$site_path/$sn" ]; then
    if [ ! "$#" = 2 ]
    then
    read -p "$sn exists. If you proceed, $sn will first be deleted. Do you want to proceed?(Y/n)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    fi
    #first change permissions on sites/default
    result=$(chown $user:www-data $site_path/$sn -R 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
    if [ "$result" = ": 0" ]; then echo "Changed ownership of $sn to $user:www-data"
    else echo "Had errors changing ownership of $sn to $user:www-data so will need to use sudo"
    sudo chown $user:www-data $site_path/$sn -R
    fi
    if [ -f $site_path/$sn/$webroot/sites/default ]
    then
    sudo chmod 770 $site_path/$sn/$webroot/sites/default -R
    fi
    rm -rf "$site_path/$sn"
fi
fi

if [ $step -lt 3 ] ; then
echo -e "$Cyan step 2: installing with method $install_method $Color_Off"

if [ "$install_method" == "git" ]
then
  echo "Adding git credentials"
  if [ -f /home/$user/.ssh/$github_key ]
  then
  ssh-add /home/$user/.ssh/$github_key
    echo "Cloning $project"
  git clone $project $site_path/$sn
  else
    echo "No github key present. Using https instead"
#    git config --global user.name $user
#    git config --global user.email "$user@example.com"
  echo "Cloning ${project/git@github.com:/https:\/\/github.com\/}"
  git clone "${project/git@github.com:/https:\/\/github.com\/}" $site_path/$sn
  fi


  if [ "$git_upstream" != "" ]
  then
      if [ -f /home/$user/.ssh/$github_key ]
      then
    cd $site_path/$sn
    echo "$sn has upstream git so adding $git_upstream"
    git remote add upstream $git_upstream
    else
      echo "Have not added upstream since no key present."
      fi
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
  tar -xf $Name -C "$site_path/$sn"
else
    echo "No install method specified. You need to at least edit the default recipe in pl.yml and specify \"install_method\"."
    exit 1
fi
fi

if [ $step -lt 4 ] ; then
echo -e "step 3: composer install"
cd $site_path/$sn
# Neet to check if composer is installed.
composer install
fi

if [ $step -lt 5 ] ; then
echo -e "$Cyan step 4: Setting up folder/file permissions $Color_Off"

fix_site_settings

echo "Create private files directory $site_path/$sn/private"
echo "BTW private is $private"
if [ ! -d "$site_path/$sn/private" ]; then
  mkdir ""$site_path/$sn/private""
fi
chmod 770 "$site_path/$sn/private"

echo "Create cmi files directory"
if [ ! -d "$site_path/$sn/cmi" ]; then
  mkdir "$site_path/$sn/cmi"
fi
chmod 770 "$site_path/$sn/cmi"
fi

if [ $step -lt 6 ] ; then
echo -e "$Cyan step 5: setting up drush aliases and site permissions $Color_Off"
cd "$site_path/$sn/$webroot"
drush core:init
set_site_permissions
fi

if [ $step -lt 7 ] ; then
echo -e "$Cyan step 6: Now building site. $sn $Color_Off"
rebuild_site $sn
fi

if [ $step -lt 8 ] ; then
echo -e "$Cyan step 7: Set up uri $uri. This will require sudo $Color_Off"
pl sudoeuri $sn
fi

if [ $step -lt 9 ] ; then
echo -e "$Cyan Step 8: setup npm for gulp support $uri $Color_Off"

if [ -d "$site_path/$sn/$webroot/themes/custom/$theme" ]
then
cd "$site_path/$sn/$webroot/themes/custom/$theme"
npm install
elif [ -d "$site_path/$sn/$webroot/themes/contrib/$theme" ]
then
cd "$site_path/$sn/$webroot/themes/contrib/$theme"
npm install
else
echo "There is a problem: The theme $theme has not been installed."
fi
fi

if [ $step -lt 10 ] ; then
echo -e "$Cyan Step 9: Trying to go to URL $uri $Color_Off"
drush uli --uri=$uri
fi

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
echo

