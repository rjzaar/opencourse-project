#!/bin/bash
#stg2dev
# Start Timer
SECONDS=0
echo -e "\e[34m Give site $1 dev mode and modules \e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to turn on dev mode and enable dev modules.
You just need to state the sitename, eg stg.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

sn=$1

#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_oc_yml
import_site_config $sn

# turn on dev modules (composer)

cd $folderpath/$sn
echo "Composer install."
composer install --quiet

# rebuild permissions
echo "Rebuild permissions, might require sudo."
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
set_site_permissions

#install dev modules
echo "install dev modules"
drush @$sn en -y oc_dev

#turn on dev settings
echo "Turn on dev mode"
drupal --target=$uri site:mode dev

#clear cache
echo "Clear cache"
drush @$sn cr

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
