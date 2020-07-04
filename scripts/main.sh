#!/bin/bash
################################################################################
#                           Main For Pleasy Library
#
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
scriptname='pleasy-main'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Turn maintenance mode on or off
Usage: pl main [OPTION] ... [SITE] [MODULES]
This script will turn maintenance mode on or off. You will need to specify the
site first than on or off, eg pl main loc on

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl main loc on
pl main dev off
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
args=$(getopt -o h -l help --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl main --help' for more options"
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
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

if [ $1 == "main" ] && [ -z "$2" ]; then
  echo "You need to specify the site and on/off in that order"
  print_help
fi
if [ -z "$2" ]; then
  echo "You have only given one argument. You need to specify the site and the module in that order"
  print_help
else
  sitename_var=$1
  main=$2
fi

echo "This will turn $main maintenance mode on the $sitename_var site."
# Don't need to parse site since all we need is in the command, though we presume site name is correct.
#parse_pl_yml
#import_site_config $sitename_var

for i in "$2"; do
  case $i in
  on)
    drush @$1 state:set system.maintenance_mode 1 --input-format=integer
    drush @$1 cache:rebuild
    shift # past argument=value
    ;;
  off)
    drush @$1 state:set system.maintenance_mode 0 --input-format=integer
    drush @$1 cache:rebuild
    shift # past argument=value
    ;;
  *)
    echo "You need to state on or off."
    shift # past argument=value
    ;;
  esac
done

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

