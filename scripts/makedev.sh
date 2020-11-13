#!/bin/bash
################################################################################
#                       make dev mode For Pleasy Library
#  This script is used to turn on dev mode and enable dev modules.
#  You just need to state the sitename, eg stg.
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
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
scriptname='pleasy-makedev'
verbose="none"
# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Turn dev mode on for a site
Usage: pl makedev [OPTION] ... [SITE]
This script is used to turn on dev mode and enable dev modules.
You just need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl makedev loc
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
args=$(getopt -o hd -l help,debug --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl makedb --help' for more options"
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
    exit 3 # pass
    ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

parse_pl_yml

echo -e "\e[34m Give site $1 dev mode and modules \e[39m"

. $script_root/_inc.sh;

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

sitename_var=$1

#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_pl_yml
import_site_config $sitename_var

# turn on dev modules (composer)

cd $site_path/$sitename_var
echo "Composer install at $site_path/$sitename_var"
#Make sure all dev modules are installed
# create a list of modules to install for dev
# They should already have been set up during install as dev modules...
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

# rebuild permissions
echo "Rebuild permissions, might require sudo."
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
set_site_permissions

#install dev modules
echo "install dev modules"
drush @$sitename_var en -y $dev_modules

#turn on dev settings
echo "Turn on dev mode: drupal --target=$uri site:mode dev"
cd $site_path/$sitename_var/$webroot
drupal site:mode dev

#clear cache
echo "Clear cache"
drush @$sitename_var cr

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
