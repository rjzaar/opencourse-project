#!/bin/bash
################################################################################
#                       proddown For Pleasy Library
#
#  This script is used to overwrite localprod with the actual external
#  production site.  The choice of localprod is set in pl.yml under sites:
#  localprod: The external site details are also set in pl.yml under prod:
#  Note: once localprod has been locally backedup, then it can just be restored
#  from there if need be.
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
#   -t --test            Download the test server instead.
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='proddown'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
echo \
"Overwrite a specified local site with production
Usage: pl proddown [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. If no site specified, localprod will be used. The external site details are also set in pl.yml under prod: Note: once
the local site has been locally backedup, then it can just be restored from there
if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function


Examples:
pl proddown stg
pl proddown stg -s=2
pl proddown
END HELP"

}



# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Step Variable
################################################################################
# Variable step is defined for debug purposes. If the init fails, we can,
# using step, start at the point of the script which had failed
################################################################################
step=${step:-1}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hs:d -l help,step:,debug --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl proddown --help' for more options"
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
  -s | --step)
    flag_step=1
    shift
    step="$1"
    shift; ;;
  -d | --debug)
    verbose="debug"
    shift; ;;
#  -t | --test)
#    test="y"
#    shift; ;;
  --)
  shift
  break; ;;
  *)
  "Programming error, this should not show up!"
  exit 1; ;;
  esac
done

parse_pl_yml

# Make sure @prod is setup.
update_all_configs
sitename_var=$1
if [ $1 = "proddown" ] && [ -z "$2" ]; then
  echo "No site specified, using localprod"
  sitename_var="localprod"
fi

echo "Importing production site into $sitename_var"

import_site_config $sitename_var

if [ $step -gt 1 ] ; then
  echo "Starting from step $step"
fi

##First backup the current localprod site if it exists
#if [ $step -lt 2 ] ; then
#  echo "step 1: backup current sitename_var: $sitename_var"
#  pl backup $sitename_var "presync"
#fi

#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
#echo "pre rsync"
#drush -y rsync @prod @$sitename_var -- --omit-dir-times --delete

if [ $step -lt 2 ] ; then
  echo -e "$Cyan step 1: backup production $Color_Off"

  to=$sitename_var
  backup_prod
  # sql file: $Namesql
  # all files: $folderpath/sitebackups/prod/$Name.tar.gz
  sitename_var=$to
fi

if [ $step -lt 3 ] ; then
  echo -e "$Cyan step 2: restore production to $sitename_var $Color_Off"
  pl restore prod $sitename_var -yf
fi
#
#if [ $step -lt 5 ] ; then
#  echo -e "$Green step 4: Fix site settings $Color_off"
#  fix_site_settings
#fi

#if [ $step -lt 6 ] ; then
#echo "step 5: rsync private and cmi folders"
#drush -y rsync @prod:../private @$sitename_var:../ -- --omit-dir-times  --delete
#drush -y rsync @prod:../cmi @$sitename_var:../ -- --omit-dir-times  --delete
#fi

#if [ $step -lt 6 ] ; then
#echo "step 5: Fix site permissions"
#set_site_permissions
#fi

# Now get the database
#This command wasn't fully working.
# This one does
#echo "Now get the database"
#Name="prod$(date +%Y%m%d\T%H%M%S-).sql"
#Namepath="$folderpath/sitebackups/localprod"
#SFile="$folderpath/sitebackups/localprod/$Name"
## The next 2 commands don't work...
##drush @prod sql-dump  --gzip > "$SFile.gz"
##gzip -d "$SFile.gz"
## So try this instead
#drush @prod sql-dump --gzip --result-file="../../../$Name"
#scp cathnet:"$Name.gz" "$Namepath/$Name.gz"
#gzip -d "$Namepath/$Name.gz"
#
#
#
##Now import it
#result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $SFile 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
#if [ "$result" = ": 0" ]; then echo "Production database imported into database $db using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi

#drush @localprod cr

#pl backup $sitename_var "postsync"

# Make sure url is setup and open it!
#pl sudoeuri localprod
echo -e "$Cyan Opening $sitename_var $Color_Off"
pl open $sitename_var
# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
