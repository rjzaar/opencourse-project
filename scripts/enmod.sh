#!/bin/bash
################################################################################
#                            Enmod For Pleasy Library
#
#  This script will install a module first using composer, then fix the file/dir
#  ownership and then enable the module using drush automatically.
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
scriptname='pleasy-enmod'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl enmod [OPTION] ... [SITE] [MODULE]
This script will install a module first using composer, then fix the file/dir
ownership and then enable the module using drush automatically.

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
    echo "please do 'pl enmod --help' for more options"
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
# This seems to be a GOD FUNCTION
parse_pl_yml

if [ $1 == "enmod" ]; then
  echo "You need to specify the site and the module in that order"
  print_help
elif [ -z "$2" ]; then
  echo "You have only given one argument. You need to specify the site and the module in that order"
  print_help
else
  sitename_var=$1
  mod=$2
fi

echo "This will install and enable the $mod module for the site $sitename_var using both composer and drush en automatically."
parse_pl_yml
import_site_config $sitename_var

cd $site_path/$sitename_var
echo "Installing module using composer"
composer require drupal/$mod

echo "Fixing site permissions."
sudo chown :www-data $site_path/$sitename_var -R

echo "installing using drush"
drush @$sitename_var en -y $mod

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

