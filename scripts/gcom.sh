#!/bin/bash
################################################################################
#                       Git Commit For Pleasy Library
#
#  This will git commit changes and run an backup to capture it.
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
#  Core Maintainer:  Rob Zar
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

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
verbose="none"

# Set script name for general file use
scriptname='pleasy-gcom'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl gcom [SITE] [MESSAGE] [OPTION]
This script will git commit changes to [SITE] with [MESSAGE].\
If you have access rights, you can commit changes to pleasy itself by using "pl" for [SITE].

OPTIONS
  -h --help               Display help (Currently displayed)
  -b --backup             Backup site after commit
  -v --verbose            Provide messages of what is happening
  -d --debug              Provide messages to help with debugging this function

Examples:
pl gcom loc \"Fixed error on blah.\" -bv\
pl gcom pl \"Improved gcom.\""
exit 0
}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -a -o hbvd -l help,backup,verbose,debug --name "$scriptname" -- "$@")
# echo "$args"
ocmsg "args: $args" debug
################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please type 'pl gcom --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"
ocmsg "\$1: $1" debug
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
   -b | --backup)
    gcombackup="backup"
    shift
    ;;
   -v | --verbose)
    verbose="normal"
    shift
    ;;
   -d | --debug)
    verbose="debug"
    shift
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

ocmsg "12 $1 $2" debug

if [[ "$1" == "gcom" ]] && [[ -z "$2" ]]; then
 echo "No site specified."
elif [[ -z "$2" ]]; then
 echo "No message specified."
else
  sitename_var=$1
  msg="'$*'"
fi

ocmsg "msg: $msg" debug

if [[ "$sitename_var" == "pl" ]] ; then site="" ; sitename_var="pleasy" ; else site="site "; fi

echo -n "This will git commit changes on $site$sitename_var with msg $msg "
if [[ "$gcombackup" == "backup" ]] && [[ "$sitename_var" != "pleasy" ]] ; then
echo "and run a backup to capture it."
else
echo " "
fi

if  [[ "$gcombackup" == "backup" ]] && [[ "$sitename_var" == "pleasy" ]] ; then
echo "Can't backup pleasy - ignoring backup request."
fi
# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

ocmsg "folderpath: $folderpath" debug

ocmsg " Now parse pl.yml " debug
parse_pl_yml
ocmsg "verbose: $verbose" debug

if [[ "$sitename_var" == "pleasy" ]] ; then
ocmsg "commiting to pleasy"
cd $folderpath
else
import_site_config $sitename_var
ocmsg "cd $site_path/$sitename_var" debug
cd $site_path/$sitename_var
fi

add_git_credentials

sitename_var_len=$(echo -n $sitename_var | wc -m)
msg=${msg:$(($sitename_var_len+1))}

ocmsg "Commit git add && git commit with msg \'$msg\"" debug
git add .
git commit -m "\"{$msg//'}\""
git push

if [[ "$gcombackup" == "backup" ]] && [[ "$sitename_var" != "pleasy" ]] ; then
ocmsg "Backup site $sitename_var with msg $msg"
backup_site $sitename_var $msg
fi
