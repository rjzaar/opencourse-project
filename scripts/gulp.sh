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
#
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
Usage: pl $scriptname [OPTION] ... [SITE]
This script is used to set upl gulp browser sync for a particular page. You
just need to state the sitename, eg loc and the page, eg opencat.loc

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl $scriptname
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

}
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


# This code could be better integrated.
sed -i "1s|.*|var page = \"$2\";|" "$site_path/$sitename_var/$webroot/themes/custom/$theme/gulpfile.js"
cd "$site_path/$sitename_var/$webroot/themes/custom/$theme/"
gulp & #This will start the scss syncing.
browser-sync start --proxy "$2" --files "**/*.twig, **/*.css, **/*.js" --reload-delay 1000 & # This will start browser sync.
echo "gulp and browser-sync started."

# to check for processes so background ones can be killed:
# ps -ef | grep "sync"
# ps -ef | grep "gulp"
