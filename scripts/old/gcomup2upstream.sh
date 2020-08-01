#!/bin/bash
################################################################################
#               Git commit backup to upstream For Pleasy Library
#
#  This will update to the upstream git, it presupposes you have already merged
#  branch with master
#
#  git checkout master
#  git pull origin master
#  git merge feature/[my-existing-branch]
#  git push origin master
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
scriptname='gcomup2upstream'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Git commit with upstream merge
Usage: pl $scriptname [OPTION] ... [SITE] [MESSAGE]
This will merge branch with master, and update to the upstream git. It
presupposes you have already merged. You just need to state the sitename, eg
dev.
                                    branch with master
Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname -h
pl $scriptname dev (relative dev folder)
pl $scriptname tim 'First tim backup'
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

if [ $1 == "gcomup2upstream" ] && [ -z "$2" ]
  then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]
  then
    sitename_var=$1
    msg="Updating."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will merge branch with master"

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

parse_pl_yml
import_site_config $sitename_var
#This script will update opencourse to the varbase-project upstream
cd
cd $site_path/$sitename_var


#Do a commit first?
ocmsg "Composer install"
composer install

ocmsg "Run db updates"
drush @$sitename_var updb

ocmsg "Export config: drush cex will need sudo"
sudo chown $user:www-data $site_path/$sitename_var -R
chmod g+w $site_path/$sitename_var/cmi -R
drush @$sitename_var cex --destination=../cmi -y
pl gcom $sitename_var "pre-up2upstream commit"

# Move Readme out the way for now.
echo "Move readme out the way"
mv README.md README.md1
echo "Add upstream."
git remote add upstream git@github.com:Vardot/varbase-project.git
echo "Fetch upstream"
git fetch upstream

echo "Now try merge."
git merge upstream/8.8.x

#Now overide the upstream readme.
echo "Now move readme back"
mv README.md1 README.md

ocmsg "Update dependencies: composer install"
# Should I remove the lock first?
rm composer.lock
composer install

ocmsg "Run db updates"
drush @$sitename_var updb

ocmsg "Import configuration: drush cim"
drush @$sitename_var cim

pl gcom $sitename_var "Updated to lastest varbase"



