#!/bin/bash
################################################################################
#                      Backup prod For Pleasy Library
#
#  This script will copy one site to another site. It will copy all files,
#  set up the site settings and import the database. If no argument is
#  given, it will copy dev to stg If one argument is given it will copy dev
#  to the site specified If two arguments are give it will copy the first
#  to the second.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  11/02/2020 James Lim  Getopt parsing implementation, script documentation
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
scriptname='copy'
verbose="none"
# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
  echo \
    "Copies one site to another site.
    Usage: pl copy [OPTION] ... [SOURCE] [DESTINATION]
This script will copy one site to another site. It will copy all
files, set up the site settings and import the database. If no
argument is given, it will copy dev to stg. If one argument is given it
will copy dev to the site specified. If two arguments are give it will
copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:"

}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hd -l help,debug --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
  echo "please do 'pl copy --help' for more options"
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
    exit 3 # pass
    ;;
  -d | --debug)
    verbose="debug"
    shift
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
ocmsg "Starting to parse pl.yml" debug
parse_pl_yml
ocmsg "Finish parsing pl.yml" debug
# Check number of user arguments
################################################################################
# Depending on number of user arguments, set copy condition
################################################################################
if [ $1 == "copy" ] && [ -z "$2" ]; then
  sitename_var="$sites_stg"
  from="$sites_dev"
elif [ -z "$2" ]; then
  sitename_var=$1
  from="$sites_dev"
else
  from=$1
  sitename_var=$2
fi

echo "This will copy the site from $from to $sitename_var and then try to import the database"

# Working out site locations
################################################################################
# We need to work out where each site is.
################################################################################
to=$sitename_var
import_site_config $from
ocmsg "Backing up from $from" debug
backup_db
from_sp=$site_path
sitename_var=$to
import_site_config $to
to_sp=$site_path

if [ -d $to_sp/$to ]; then
  ocmsg "Removing site $to"
  sudo chown $user:www-data $to_sp/$to -R
  chmod +w $to_sp/$to -R
  rm -rf $to_sp/$to
fi
echo "Move all files from $from to $to"
cp -rf "$from_sp/$from" "$to_sp/$to"

## Now get the name of the backup.
#-------------------------------------------------------------------------------
#cd
#cd "$folder/sitebackups/$from"
#options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
#Name=${options[0]:2}
#-------------------------------------------------------------------------------

################################################################################
# Global variables are very hard to keep track of for newcomers!!!
# Yes - sorry - will need to come up with a naming convention and list of these particular variables.
################################################################################
#Note $Name was set in backup_db and will now be used in the restore_db. Nice hey.

sitename_var=$to
fix_site_settings

#
#echo -e "$Cyan setting up drush aliases and site permissions $Color_Off"
#plcomposer require drush/drush
#if [[ -f $site_path/$sitename_var/$webroot/vendor/drush/drush/drush ]]; then
#chmod a+rx $site_path/$sitename_var/$webroot/vendor/drush/drush/drush
#chmod a+rx $site_path/$sitename_var/$webroot/vendor/drush/drush/drush.php
#fi
#cd "$site_path/$sitename_var/$webroot"
#ocmsg "Moved to $site_path/$sitename_var/$webroot"
#ocmsg "drush core init" debug
#drush core:init -y
#ocmsg "set site permissions" debug

set_site_permissions

bk=$from
restore_db

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS / 3600))' M:'$(($SECONDS % 3600 / 60))' S:'$(($SECONDS % 60))
