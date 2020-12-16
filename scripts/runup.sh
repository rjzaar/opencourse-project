#!/bin/bash
################################################################################
#                 Run updates For Pleasy Library
#
#  This is when you want to update. This will update composer, config and db.
#
#  https://events.drupal.org/vienna2017/sessions/
#  advanced-configuration-management-config-split-et-al
#  at 29:36
#  That is a combination of (always presume sharing and do a backup first):
#
#  The safe sequence for updating
#  Update code: composer update
#  Run updates: drush updb
#  Export updated config: drush cex
#  Commit git add && git commit
#  Push: git push
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
scriptname='runup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
  echo \
"This script will run any updates on the stg site or the site specified.
Usage: pl runupdates [OPTION] ... [SOURCE]
This script presumes the files including composer.json have been updated in some way and will now run those updates.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl runup loc
pl runup test # This will run the updates on the external test server."

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
args=$(getopt -o hdf -l help,debug,force-config_import --name "$scriptname" -- "$@")
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
    print_help;
    exit 2 # works
    ;;
  -d | --debug)
  verbose="debug"
  shift; ;;
  -f | --force-config-import)
  force_config_import="true"
  shift; ;;
  --)
  shift; break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

################################################################################

parse_pl_yml

if [ $1 == "runup" ] && [ -z "$2" ]
  then
sitename_var="$sites_stg"
elif [ -z "$2" ]
  then
    sitename_var="$1"
fi
import_site_config $sitename_var
runupdates

# Not needed since patched.
#remove any extra options. Since each reinstall may add an extra one.
#cd
#cd opencat/opencourse
#echo -e "\e[34mpatch .htaccess\e[39m"
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))