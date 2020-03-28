#!/bin/bash
################################################################################
#                           Devpush For Pleasy Library
#  Rob please add description
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
scriptname='pleasy-devpush'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl devpush [OPTION]
Include help Rob!

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:"
exit 0
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
    echo "please do 'pl backup --help' for more options"
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
    exit 0
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

# Should not have arguments atm
################################################################################
# Devpush should not accept arguments, hence check for args
################################################################################
if [ $# -gt 0 ]; then
  echo "Devpush does not accept arguments"
  exit 2
fi

#From: https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
#Export configuration: drush cex
#-----------------------------REMOVE THIS?----------------------------------
#Commit git add && git commit
#Merge: git pull
#Update dependencies: composer install
#run updates: drush updb
#Import configuration: drush cim
#Push: git push
#---------------------------------------------------------------------------

#push opencourse git. No need to move since it is ignored.
echo "push git"
cd
cd opencat/opencourse
#-----------------------------REMOVE THIS?----------------------------------
#remove any extra options. Since each reinstall may add an extra one.
#following line has been fixed with a patch
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess
#---------------------------------------------------------------------------
if [ -f ~/.ssh/github ]; then
    ssh-add ~/.ssh/github
else
    echo "could not add git credentials, recommended to create github credentials in .ssh folder"
fi
git add .
git commit -m "Backup."
git push

#-----------------------------REMOVE THIS?----------------------------------
#mv .git ../ocgitstore/
#---------------------------------------------------------------------------

#turn off composer dev (WHY?)
echo "Turn off composer dev"
cd
cd opencat/opencourse
composer install --no-dev

#-----------------------------REMOVE THIS?----------------------------------
#following line has been fixed with a patch
# patch .htaccess
#echo "patch .htaccess"
#sed -i '4iOptions +FollowSymLinks' docroot/.htaccess
#-------------------------------------------------------------------------------

# rebuild permissions
echo "rebuilding permissions, requires sudo"
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
"sudo ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob"

# clear cache
echo "clear cache"
cd docroot
#don't know why, but for some reason video embed field is not installed when it is in composer and oc_prod.
drush en -y video_embed_field
drush cr

#Note database is the same between dev and stg in the forward direction.

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
