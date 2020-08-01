#!/bin/bash
################################################################################
#                Git Push and merge Master For Pleasy Library
#
#  This will merge the branch into master, it presupposes you have already
#  merged branch with master
#  PSEUDOCODE
#  git checkout master
#  git pull origin master
#  git merge feature/[my-existing-branch]
#  git push origin master
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
scriptname='pleasy-gcompushmaster'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Git merge branch with master and push
Usage: pl gcompushmaster [OPTION] ... [SITE] [MESSAGE]
This will merge branch with master You just need to state the sitename, eg
dev.

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
    echo "please do 'pl gcompushmaster --help' for more options"
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
parse_pl_yml

if [ $1 == "gcompushmasterpushmaster" ] && [ -z "$2" ]
  then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]
  then
    sitename_var=$1
    msg="Updating."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will merge branch with master"
# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

parse_pl_yml
import_site_config $sitename_var
cd $site_path/$sitename_var

echo "Add credentials."
ssh-add ~/.ssh/$github_key

### Make sure branch has already been merged with master!!!!

# Could do a push to master
git checkout master
git pull origin master
git merge feature/[my-existing-branch]
git push origin master



