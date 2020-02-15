#!/bin/bash

# See help

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

if [ $1 == "main" ] && [ -z "$2" ]
  then
echo "You need to specify the site and on/off in that order"
print_help
fi
if [ -z "$2" ]
  then
echo "You have only given one argument. You need to specify the site and the module in that order"
print_help
   else
    sitename_var=$1
    main=$2
fi

echo "This will turn $main maintenance mode on the $sitename_var site."
# Don't need to parse site since all we need is in the command, though we presume site name is correct.
#parse_pl_yml
#import_site_config $sitename_var
# Help menu
print_help() {
cat <<-HELP
This script will turn maintenance mode on or off. You will need to specify the site first than on or off,
eg pl main loc on
HELP
exit 0
}

 for i in "$2"; do
    case $i in
    on)
      drush @$1 state:set system.maintenance_mode 1 --input-format=integer
      drush @$1 cache:rebuild
      shift # past argument=value
      ;;
    off)
      drush @$1 state:set system.maintenance_mode 0 --input-format=integer
      drush @$1 cache:rebuild
      shift # past argument=value
      ;;
    *)
      echo "You need to state on or off."
      shift # past argument=value
      ;;
    esac
  done

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

