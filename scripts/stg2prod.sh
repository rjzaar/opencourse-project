#!/bin/bash
#stg2prod
#This will backup prod, and import stg into prodution
#This presumes teststg.sh worked, therefore opencat git is upto date with cmi export and all files.

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
parse_pl_yml

#prod settings are in pl.yml

if [ $1 == "stg2prod" ] && [ -z "$2" ]
  then
  sitename_var="$sites_stg"
elif [ -z "$2" ]
  then
    sitename_var=$1
fi

import_site_config $sitename_var

# Help menu
print_help() {
cat <<-HELP
This script will push stg to prod
It will first backup prod
The external site details are also set in pl.yml under prod:
HELP
exit 0
}


#First backup the current stg site.
read -p "Do you want to backup prod?(Y/n)" question
case $question in
    n|c|no|cancel)
    echo exiting immediately, no changes made
    ;;
    *)
    pl backupprod
    ;;
esac

#alternatively could use pl olwprod

#put prod in maintenance mode
drush @prod sset system.maintenance_mode TRUE
drush -y rsync @$sitename_var @prod -- -O  --delete
#Private files are the latest there anyway.
drush -y rsync @$sitename_var:../cmi @prod:../cmi -- -O  --delete

# Now sync the database


# fix file permissions?

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0


# test again.
