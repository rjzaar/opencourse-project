#!/bin/bash
################################################################################
#                          prodmaster For Pleasy Library
#
#  This script will make sure production site and db is on master branch and not dev
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
scriptname='pleasy-prodmaster'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Make sure production site and db is on master branch
Usage: pl prodmaster [OPTION] ...
This script will make sure production site and db is on master branch and not dev

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl prodmaster
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
args=$(getopt -o h -l help --name "$scriptname" -- "$@")


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
    print_help
    exit 2; ;;
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done

Pcolor=$Cyan
parse_pl_yml
echo "Make sure production site $prod_uri has the site and db on master branch"
ssh $prod_alias "./prodmaster.sh $prod_docroot"


# If it works, the production site needs to be swapped to prod branch from dev branch and hard rest to dev, is use 'ours'.

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0

