#!/bin/bash
################################################################################
#                      Backupdb For Pleasy Library                       
#                                                                              
#  Hi Rob, please state what this does, and the difference between this and
#  backup.sh
#                                                                              
#  Change History                                                              
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,        
#                                   prelim commenting                          
#  11/02/2020 James Lim  Getopt parsing implementation, script documentation   
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
#                             Commenting with model                            
# NAME OF COMMENT
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc                            
################################################################################
#                                                                               
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-backupdb'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Usage: pl backupdb [OPTION] ... [SOURCE]
  This script is used to backup a particular site's files and database.
  You just need to state the sitename, eg dev. (ROB What is the
  difference between this and backup.sh?)

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
  
  Examples:
  pl backupdb -h
  pl backupdb ./dev (relative dev folder)"
exit 0
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
echo -e "\e[34mbackup $1 \e[39m"
. $script_root/_inc.sh;

# Use of Getopt 
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")
#echo "$args"

##########################   BUG ALERT  ########################################
# program quits upon getopt fail, which is unusual to say the least
################################################################################

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
  -- )
  shift
  break
  ;;
  *)
  "Programming error, this should not show up!"
  exit 1
  ;;
  esac
done

#echo $0; echo $1; echo "DEBUG EXIT"; exit 0

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

parse_pl_yml
sitename_var=$1
import_site_config $sitename_var

backup_db

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))