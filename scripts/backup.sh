#!/bin/bash
################################################################################
#                 Backup db and files For Pleasy Library                       
#                                                                              
# This script is used to backup a particular site's files and database.
# You just need to state the sitename, eg dev
#
#  Change History                                                              
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,        
#                                   prelim commenting                          
#  09/02/2020 James Lim  Getopt parsing implementation, script documentation   
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
# Implement message function
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
scriptname='pleasy-backup'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl backup [OPTION] ... [SOURCE]
  This script is used to backup a particular site's files and database.
  You just need to state the sitename, eg dev. 

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
    -m --message='msg'      Enter a message to accompany the backup (IS THIS
                            OPTIONAL ROB?)
  
  Examples:
  pl backup -h
  pl backup ./dev (relative dev folder)
  pl backup ./tim -m 'First tim backup'
  pl backup --message='Love' ~/love"
exit 0
}
# Use of Getopt 
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hm: -l help,message: --name "$scriptname" -- "$@")
echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl backup --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# if no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 0
    ;;
  -m | --message)
    shift
    msg="$(echo "$1" | sed 's/^=//g')"
    echo "Msg = $msg"
    #MESSAGE FUNCTION NOT IMPLEMENTED
    ;;
  -- )
  shift
  break
  ;;
  *)
  "Programming error, this should not show up!"
  exit 1
  ;;
  esac
  shift
done


# No arguments
################################################################################
# if no argument found exit and display error. User must input directory for
# backup else this script will fail.
################################################################################
if [ "$#" = 0 ]; then
  echo "ERROR: No directory name found for backup"
  print_help
  exit 1
elif [[ ! -d "$1" ]]; then
  echo "Cannot find directory "$1", please try again or use --help for more options"
fi

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
echo -e "\e[34mbackup $1 \e[39m"
. $script_root/_inc.sh;


sitename_var=$1

#----------------------- Extra code, unsure of its use -------------------------
# folder=$(basename $(dirname $script_root))
# webroot="docroot"
#-------------------------------------------------------------------------------

# It it interesting to note that parse_pl_yml is run in many scripts. What does
# it do?
parse_pl_yml
# What do these do?
################################################################################
# 
################################################################################
import_site_config $sitename_var
backup_site $sitename_var

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))