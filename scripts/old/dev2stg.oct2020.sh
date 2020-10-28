#!/bin/bash
################################################################################
#                      Move dev to stage For Pleasy Library
#
#  This script will use git to update the files from dev repo (ocdev) on the stage
#  site dev to stg. If one argument is given it will copy dev to the site
#  specified. If two arguments are give it will copy the first to the second.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  15/02/2020 James Lim  Getopt parsing implementation, script documentation
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
################################################################################
#                             Commenting with model
#
# NAME OF COMMENT (USE FOR RATHER SIGNIFICANT COMMENTS)
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-dev-2-stage'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Uses git to update a stage site with the dev files.
Usage: pl dev2stg [OPTION] ... [SOURCE]
This script will use git to update the files from dev repo (ocdev) on the stage
site dev to stg. If one argument is given it will copy dev to the site
specified. If two arguments are give it will copy the first to the second.
Presumes the dev git has already been pushed. Git is used for this rather than
simple file transfer so it follows the requirements in .gitignore.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:"

}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl copyf --help' for more options"
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
    print_help
    exit 2 # works
    ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done


# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml


################################################################################
# Unsure what this is for, and how to parse this properly
################################################################################
if [ $1 == "dev2stg" ] && [ -z "$2" ]
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

echo "This will update the stage site $sitename_var with the latest from $from"
import_site_config $from
from_site_path=$site_path
    if [ ! -d "$from_site_path/$from/.git" ]; then
      echo "There is no git in the dev site $from. Aborting."
      exit 0
    fi
from_site_path=$site_path
import_site_config $sitename_var



#copy_site_files $from $sitename_var


# move stg git out the way
  if [ ! -d "$folderpath/sitebackups/stg" ]; then
    mkdir "$folderpath/sitebackups/stg"
  fi
  #remove old git
  rm -rf $folderpath/sitebackups/stg/.git
  rm -rf $folderpath/sitebackups/stg/.gitignore
  if [  -d "$site_path/$sitename_var/.git" ]; then
    # store stg git.
    mv $site_path/$sitename_var/.git $folderpath/sitebackups/stg/.git
    mv $site_path/$sitename_var/.gitignore $folderpath/sitebackups/stg/.gitignore
  fi

# copy dev git to stg
# Have already checked that dev git exists.
    # store stg git.
    mv $from_site_path/$from/.git $site_path/$sitename_var/.git
    mv $from_site_path/$from/.gitignore $site_path/$sitename_var/.gitignore

# pull in the git hard, ie no merge.
cd $site_path/$sitename_var
git fetch
git reset --hard HEAD

# Now move the stg git back
rm $from_site_path/$from/.git
rm $from_site_path/$from/.gitignore
mv $folderpath/sitebackups/stg/.git $site_path/$sitename_var/.git
mv $folderpath/sitebackups/stg/.gitignore $site_path/$sitename_var/.gitignore

set_site_permissions


# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

