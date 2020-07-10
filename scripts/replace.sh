#!/bin/bash
################################################################################
#                       replace For Pleasy Library
#
#  This script is used to copy the files from one site to the other site while keeping
#  the .git from the other site.
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
scriptname='pleasy-replace'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Overwrite localprod with production
Usage: pl replace [OPTION] ... [FROM] [TO]
This script will copy the .git and .gitignore from TO to .prodgit and .prodgitignore
in FROM. It will delete TO. It will copy FROM to TO. It will then move the .git
to .devgit and .gitignore to .devgitignore. It will move .prodgit to .git and
.prodgitignore to .gitignore. Fix up the site settings and file permissions.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl replace loc stg
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

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl replace --help' for more options"
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
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help;
    exit 2 # works
    ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

parse_pl_yml

if [ $1 == "replace" ] && [ -z "$2" ]; then
 echo "You need to specify the source and destination sites"
elif [ -z "$2" ]; then
 echo "You need to specify the source and destination sites"
else
  from=$1
  to=$2
fi

echo "Replacing files in $to with files from $from, while keeping git in $to"

import_site_config $to
to_sp=$site_path
import_site_config $from
from_sp=$site_path

echo "Store prod git"
mv $to_sp/$to/.git $from_sp/$from/.prodgit
mv $to_sp/$to/.gitignore $from_sp/$from/.prodgitignore

rm -rf $to_sp/$to
cp $from_sp/$from $to_sp/$to -rf
mv $to_sp/$to/.git $to_sp/$to/.devgit
mv $to_sp/$to/.gitignore $to_sp/$to/.devgitignore
mv $to_sp/$to/.prodgit $to_sp/$to/.git
mv $to_sp/$to/.prodgitignore $to_sp/$to/.gitignore

echo "Fix site settings"
pl fixss $to

echo "Set site permissions"
pl fixp $to

# Make sure url is setup and open it!
#pl sudoeuri localprod
pl open $to
# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
