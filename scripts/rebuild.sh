#!/bin/bash
# This task must be run by pl "task name" arguments
if [ -z $folder ]
then
echo "This task must be run by putting pl before it and no .sh, eg pl rebuild loc"
exit 1
fi

#restore site and database
# $1 is the backup
# $2 if present is the site to restore into
# $sn is the site to import into
# $bk is the backed up site.

#start timer
SECONDS=0
if [ $1 == "rebuild" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi
sn=$1

# Help menu
print_help() {
cat <<-HELP
This script is used to rebuild a particular site's database.
You just need to state the sitename, eg loc.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

parse_pl_yml
import_site_config $sn

rebuild_site

# Could check here is url is set or not.

echo "Trying to go to URL $uri"
drush uli --uri=$uri

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
echo



