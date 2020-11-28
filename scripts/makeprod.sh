#!/bin/bash
################################################################################
#                       make dev mode For Pleasy Library
#  This script is used to turn off dev mode and uninstall dev modules.  You
#  just need to state the sitename, eg stg.
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
#  Core Maintainer:  Rob Zar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-makeprod'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Turn production mode on and remove dev modules
Usage: pl makeprod [OPTION] ... [SITE]
This script is used to turn off dev mode and uninstall dev modules.  You just
need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
END HELP
HEREDOC

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
    echo "please do 'pl makeprod --help' for more options"
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

echo -e "\e[34m Give site $1 prod mode and remove dev modules \e[39m"
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

#turn on prod settings
#this should work, but it doesn't.....
#drupal --target=$uri site:mode prod

echo "Turn on prod mode on --target=$uri"
cd $site_path/$sitename_var/$webroot
drupal  site:mode prod

#uninstall dev modules
echo "uninstall dev modules"
drush @$sitename_var pm-uninstall -y $dev_modules

# turn off dev modules (composer)

cd $site_path/$sitename_var
echo "Composer install with no dev modules."
if [[ -f $site_path/$sitename_var/composer.lock ]]; then
rm $site_path/$sitename_var/composer.lock
fi
if [[ "$verbose" == "debug" ]] ; then
plcomposer install --no-dev
else
plcomposer install --no-dev --quiet
fi

# don't know why --no-dev uninstalls config_update, so add it.
plcomposer require drupal/config_update
# remove old cmi and re-export
if [[ -d $site_path/$sitename_var/cmi ]]; then
  echo "remove cmi contents"
  ls $site_path/$sitename_var/cmi
if find "$site_path/$sitename_var/cmi" -mindepth 1 -print -quit 2>/dev/null | grep -q .; then
    rm $site_path/$sitename_var/cmi/* -rf
fi

else
  mkdir $site_path/$sitename_var/cmi
fi
ocmsg "Export config" debug
drush @$sitename_var cex -y

# rebuild permissions
echo "Rebuild permissions, might require sudo."
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
set_site_permissions

#clear cache
echo "Clear cache"
drush @$sitename_var cr

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
