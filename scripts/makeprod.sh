#!/bin/bash
#stg2dev
# Start Timer
SECONDS=0
echo -e "\e[34m Give site $1 prod mode and remove dev modules \e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to turn off dev mode and uninstall dev modules.
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
parse_pl_yml
import_site_config $sn

#turn on prod settings
echo "Turn on prod mode"
drupal --target=$uri site:mode prod

#uninstall dev modules
echo "uninstall dev modules"
drush @$sn pm-uninstall -y $dev_modules

# turn off dev modules (composer)

cd $site_path/$sn
echo "Composer install with no dev modules."
composer install --no-dev --quiet

# rebuild permissions
echo "Rebuild permissions, might require sudo."
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
set_site_permissions

#clear cache
echo "Clear cache"
drush @$sn cr

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
