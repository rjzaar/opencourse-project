#!/bin/bash
#backupdb

#start timer
SECONDS=0
echo -e "\e[34mbackup $1 \e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

parse_oc_yml
sn=$1
import_site_config $sn

backup_db

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
