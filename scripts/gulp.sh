#!/bin/bash
################################################################################
#                            Gulp For Pleasy Library
#
#  This script is used to set upl gulp browser sync for a particular page. You
#  just need to state the sitename, eg loc and the page, eg opencat.loc
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
#  Core Maintainer:  Rob Zar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
# todo Needs to deal with yarn. see olivero readme.
# todo Maybe change this function to 'watch' and have it deal with gulp or yarn.
################################################################################
################################################################################

# Set script name for general file use
scriptname='gulp'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Turn on gulp
Usage: pl $scriptname [OPTION] ... [SITE] [URL]
This script is used to set up gulp browser sync for a particular page. You
just need to state the sitename and optionally a particular page
, eg loc and http://pleasy.loc/sar

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname loc
pl $scriptname loc http://pleasy.loc/sar

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
    print_help;
    exit 2 # works
    ;;
  --)
  shift; break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

################################################################################


# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

sitename_var=$1
parse_pl_yml
import_site_config $sitename_var

if [ $1 == "gulp" ] && [ -z "$2" ]; then
  uri=$folder.$sitename_var
elif [ -z "$2" ]; then
  sitename_var=$1
  uri=$folder.$sitename_var
else
  sitename_var=$1
  uri=$2
fi

echo "uri: $uri"
# This code could be better integrated.
# The first line of gulpfile.js should be "var page = "http://pleasy.loc"" or something like it.
sed -i "1s|.*|var page = \"$uri\";|" "$site_path/$sitename_var/$webroot/themes/custom/$theme/gulpfile.js"
cd "$site_path/$sitename_var/$webroot/themes/custom/$theme/"
gulp & #This will start the scss syncing.
# Browser-sync needs to be installed: npm install -g browser-sync. This should have been done in pl init.
browser-sync start --proxy "$uri" --files "**/*.twig, **/*.css, **/*.js" --reload-delay 1000 & # This will start browser sync.
echo "gulp and browser-sync started."

# to check for processes so background ones can be killed:
# ps -ef | grep "sync"
# ps -ef | grep "gulp"
