#!/bin/bash
################################################################################
#                      Install Drupal For Pleasy Library
#
#  This script is used to install a variety of drupal flavours particularly
#  opencourse This will use opencourse-project as a wrapper. It is presumed you
#  have already cloned opencourse-project.  You just need to specify the site name
#  as a single argument.  All the settings for that site are in pl.yml If no site
#  name is given then the default site is created.
#
#  Change History
#  2019 - 2020 Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
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

# Set script name for general file use
scriptname='pl-install'
verbose="none"

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Installs a drupal site
Usage: pl install site [OPTION]
This script is used to install a variety of drupal flavours particularly
opencourse This will use opencourse-project as a wrapper. It is presumed you
have already cloned opencourse-project.  You just need to specify the site name
as a single argument.  All the settings for that site are in pl.yml If no site
name is given then the default site is created.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -f --files              Only install site files. No database
  -s --step=[INT]         Restart at the step specified.
  -b --build-step=[INT]   Restart the build at step specified (step=6)
  -d --debug              Provide debug information when running this script.
  -t --test               This option is only for test environments like Travis, eg there is no mysql root password.
  -e --extras             Install extra features like yarn and bower

Examples:
pl install d8
pl install ins -b=6 #To start from installing the modules.
pl install loc -s=3 #start from composer install
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
args=$(getopt -o hyfdb:s:te -l help,yes,files,debug,build-step:,step:,test,extras --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl install --help' for more options"
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
# build_step is for the rebuild steps
build_step=1
flag_buildstep=0
# step is for the install steps
step=1
# Check for options
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 3 # pass
    ;;
  -y | --yes)
    flag_yes=1
    shift; ;;
  -f | --files)
    flag_files=1
    shift; ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -b | --build-step)
    flag_buildstep=1
    shift
    build_step=${1:1}
    shift; ;;
   -t | --test)
    pltest="y"
    shift; ;;
   -e | --extras)
    extras="y"
    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

ocmsg "12: >$1< >$2< step:$step< buildstep:$bstep<" debug

if [[ "$1" == "install" ]] && [[ -z "$2" ]]; then
 echo "No site specified."
elif [[ "$1" == "install" ]] ; then
   sitename_var=$2
elif [[ -z "$1" ]]; then
 echo "No site specified."
else
  sitename_var=$1
fi
ocmsg "sitename _var: $sitename_var" debug

if [[ flag_buildstep == 1 ]] ; then
  step=6
  bstep=$build_step # rebuild requires bstep so make it equal to build_step.
  echo "Buildstep $bstep requires step set to 6"
  fi


#auto="y"
#folder=$(basename $(dirname $script_root))
#webroot="docroot" # or could be web or html
#project="rjzaar/opencourse:8.7.x-dev"
## For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
## there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and
#sitename_var="dev"
#profile="varbase"
#dev="y"

parse_pl_yml

#Import pl.yml settings
# Create a list of recipes
for f in $recipes_; do recipes="$recipes,${f#*_}"; done
recipes=${recipes#","}

# Check to see if recipe is present
echo "Looking for recipe $sitename_var"

if [[ $recipes != *"$sitename_var"* ]]; then
  echo "No recipe for $sitename_var! Current recipes include $recipes. Please add a recipe to pl.yml for $sitename_var"
  exit 1
fi

import_site_config $sitename_var


#db_defaults

echo "Installing $sitename_var"
site_info
if [ $step -gt 1 ]; then
  echo "Starting from step $step"
fi

# Check to see if folder already exits.
if [ $step -lt 2 ]; then
  echo -e "$Cyan step 1: checking if folder $sitename_var exists $Color_Off"

  if [ -d "$site_path/$sitename_var" ]; then
    if [ "$flag_yes" != "1" ] ; then
      read -p "$sitename_var exists. If you proceed, $sitename_var will first be deleted. Do you want to proceed?(Y/n)" question
      case $question in
      n | c | no | cancel)
        echo exiting immediately, no changes made
        exit 1
        ;;
      esac
    fi
    #first change permissions on sites/default
    result=$(
      chown $user:www-data $site_path/$sitename_var -R 2>/dev/null | grep -v '+' | cut -d' ' -f2
      echo ": ${PIPESTATUS[0]}"
    )
    if [ "$result" = ": 0" ]; then
      echo "Changed ownership of $sitename_var to $user:www-data"
    else
      echo "Had errors changing ownership of $sitename_var to $user:www-data so will need to use sudo"
      sudo chown $user:www-data $site_path/$sitename_var -R
    fi
    if [ -f $site_path/$sitename_var/$webroot/sites/default ]; then
      sudo chmod 770 $site_path/$sitename_var/$webroot/sites/default -R
    fi
    sudo rm -rf "$site_path/$sitename_var"
  fi
fi

if [ $step -lt 3 ]; then
  echo -e "$Cyan step 2: installing with method $install_method $Color_Off"

  if [ "$install_method" == "git" ]; then
    echo "Adding git credentials"
    if [ -f /home/$user/.ssh/$github_key ]; then
      ssh-add /home/$user/.ssh/$github_key
      echo "Cloning $project"
      git clone $project $site_path/$sitename_var
    else
      echo "No github key present. Using https instead"
      #    git config --global user.name $user
      #    git config --global user.email "$user@example.com"
      echo "Cloning ${project/git@github.com:/https:\/\/github.com\/}"
      git clone "${project/git@github.com:/https:\/\/github.com\/}" $site_path/$sitename_var
    fi

    if [ "$git_upstream" != "" ]; then
      if [ -f /home/$user/.ssh/$github_key ]; then
        cd $site_path/$sitename_var
        echo "$sitename_var has upstream git so adding $git_upstream"
        git remote add upstream $git_upstream
      else
        echo "Have not added upstream since no key present."
      fi
    fi

  elif [ "$install_method" == "composer" ]; then
    if [ "$dev" = "y" ]; then
      echo "Setting composer install to dev."
      devs="--stability dev"
    else
      devs="--no-dev"
    fi

    echo "Run composer create project: $project $sitename_var $devs --no-interaction"
    cd $site_path
    composer create-project $project $sitename_var $devs --no-interaction
  elif [ "$install_method" == "file" ]; then
    if [ ! -d "$folderpath/downloads" ]; then
      mkdir "$folderpath/downloads"
    fi
    cd "$folderpath/downloads"
    Name="$sitename_var.tar.gz"
    wget -O $Name $project
        if [ -d "$site_path/$sitename_var" ]; then
        rm "$site_path/$sitename_var" -rf
         fi
    mkdir "$site_path/$sitename_var"
    mkdir "$site_path/$sitename_var/$webroot"

    tar -zxf $Name -C "$site_path/$sitename_var/$webroot" --strip 1
  else
    echo "No install method specified. You need to at least edit the default recipe in pl.yml and specify \"install_method\"."
    exit 1
  fi
fi

if [ $step -lt 4 ]; then
  echo -e "step 3: composer install"

  echo "Dev modules to install: $dev_composer"
compmod="drupal/${dev_composer// / drupal\/}"
  if [[ "$verbose" == "debug" ]] ; then
    if [[ ! "$dev_composer" == "" ]] ; then
plcomposer require $compmod --dev
fi
plcomposer install
else
  if [[ ! "$dev_composer" == "" ]] ; then
plcomposer require $compmod --dev --quiet
fi
plcomposer install --quiet
fi

fi

if [ $step -lt 5 ]; then
  if [[ "$lando" == "y" ]] ; then
    echo -e "$Cyan step 4: Lando install to $site_path/$sitename_var/ $Color_Off"
    # Check there is a lando file
    if [ -f "$site_path/$sitename_var/.lando.yml" ]; then
     # proceed with install
     # replace 'varbase' with site name in lando file
     sed -i "s/varbase/$sitename_var/" "$site_path/$sitename_var/.lando.yml"
     sed -i "s/mysite/$sitename_var/" "$site_path/$sitename_var/.lando.yml"
     fix_site_settings
     lando start

#     drush uli --uri=$uri
     exit 0

    else
      echo "Lando file not present so aborting intstall of $sitename_var."
    fi

  fi
fi


if [ $step -lt 6 ]; then
  echo -e "$Cyan step 5: Setting up folder/file permissions $Color_Off"

  fix_site_settings

  echo "Create private files directory $site_path/$sitename_var/private"
  echo "BTW private is $private"
  if [ ! -d "$site_path/$sitename_var/private" ]; then
    mkdir ""$site_path/$sitename_var/private""
  fi
  chmod 770 "$site_path/$sitename_var/private"

  echo "Create cmi files directory"
  if [ ! -d "$site_path/$sitename_var/cmi" ]; then
    mkdir "$site_path/$sitename_var/cmi"
  fi
  chmod 770 "$site_path/$sitename_var/cmi"
fi

if [ $step -lt 7 ]; then
  echo -e "$Cyan step 6: setting up drush aliases and site permissions $Color_Off"
  plcomposer require drush/drush
  ocmsg "set site permissions" debug
  set_site_permissions

  cd "$site_path/$sitename_var/$webroot"
  ocmsg "Moved to $site_path/$sitename_var/$webroot"
  ocmsg "drush core init" debug
  drush core:init -y

fi

if [ $step -lt 8 ]; then
  echo -e "$Cyan step 7: Now building site. $sitename_var $Color_Off"
  if [ $flag_files ]; then
    echo "Not installing site since only files required"
    else
  rebuild_site $sitename_var
  fi
fi

if [ $step -lt 9 ]; then
  echo -e "$Cyan step 8: Set up uri $uri. This will require sudo $Color_Off"
  pl sudoeuri $sitename_var
fi

if [ $step -lt 10 ]; then
  echo -e "$Cyan Step 9: setup npm for gulp support $uri $Color_Off"
  echo "theme path: $site_path/$sitename_var/$webroot/themes/contrib/$theme"
  source ~/.bashrc # make sure npm will work.
  if [ -d "$site_path/$sitename_var/$webroot/themes/custom/$theme" ]; then
    cd "$site_path/$sitename_var/$webroot/themes/custom/$theme"
    npm install
    if [ "$extras" ]; then
    # https://www.drupal.org/docs/contributed-themes/olivero/development-setup
    yarn install
    #This might need more work.
    # May help: https://github.com/bower/bower/issues/1849
    bower init -y
    bower install
    fi
  elif [ -d "$site_path/$sitename_var/$webroot/themes/contrib/$theme" ]; then
    cd "$site_path/$sitename_var/$webroot/themes/contrib/$theme"
    npm install
    if [ "$extras" ]; then
      yarn install
          #This might need more work.
      bower init -y
      bower
    fi
  else
    echo "There is a problem: The theme $theme has not been installed."
  fi
fi

if [ $step -lt 11 ]; then
  echo -e "$Cyan Step 10: Trying to go to URL $uri $Color_Off"
  if [ $flag_files ]; then
    echo "Note: No database, so you will need to set that up."
  fi
  drush uli --uri=$uri
fi

echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
echo
