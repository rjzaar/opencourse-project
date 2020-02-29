#!/bin/bash
#backup db and files

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0
echo -e "\e[34m update varbase on $1 site\e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to update a particular site to the latest varbase available.
You just need to state the sitename, eg dev.
HELP
exit 0
}
# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 2
fi

sitename_var=$1
msg="$2"
#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_pl_yml
import_site_config $sitename_var

echo "Updating varbase"
cd $site_path/$sitename_var/
./bin/update-varbase.sh



# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



