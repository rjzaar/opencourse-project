#!/bin/bash
################################################################################
#                          prodstat For Pleasy Library
#
#  This script will provide the status of the production site
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
scriptname='pleasy-prodstat'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Production status
Usage: pl prodow [OPTION] ... [SITE]
This script will provide the status of the production site

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl prodstat
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
echo "Production status for $prod_uri"
ssh $prod_alias "./prodstat.sh $prod_docroot"


# If it works, the production site needs to be swapped to prod branch from dev branch and hard rest to dev, is use 'ours'.

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0

