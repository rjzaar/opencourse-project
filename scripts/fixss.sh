#!/bin/bash

# This will fix (or set) the site settings in local.settings.php

echo -e "\e[34m fix or set the site settings for $1 \e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This will fix (or set) the site settings in local.settings.php
You just need to state the sitename, eg dev.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

sn=$1
. $script_root/_inc.sh;
folder=$(basename $(dirname $script_root))
folderpath=$(dirname $script_root)
webroot="docroot"
parse_oc_yml

import_site_config $sn

# Check that settings.php has reference to local.settings.php
sfile=$(<"$folder_path/$sn/$webroot/sites/default/settings.php")
if [[ $sfile =~ (\{[[:space:]]*include) ]]
then
echo "settings.php is correct"
else
echo "settings.php: added reference to settings.local.php"
cat >> $folder_path/$sn/$webroot/sites/default/settings.php <<EOL
 if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }

EOL
fi


cat > $folder_path/$sn/$webroot/sites/default/local.settings.php <<EOL
<?php

$settings['install_profile'] = '$profile';
$settings['file_private_path'] =  '../private';
$databases['default']['default'] = array (
  'database' => '$db',
  'username' => '$dbuser',
  'password' => '$dbpass',
  'prefix' => '',
  'host' => 'localhost',
  'port' => '3306',
  'namespace' => 'Drupal\Core\Database\Driver\mysql',
  'driver' => 'mysql',
);
$config_directories[CONFIG_SYNC_DIRECTORY] = '../cmi';
EOL
if [ "$dev" == "y" ]
then
cat >> $folder_path/$sn/$webroot/sites/default/local.settings.php <<EOL
$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
$settings['cache']['bins']['render'] = 'cache.backend.null';
$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
$config['config_split.config_split.config_dev']['status'] = TRUE;
EOL
fi
echo "Added local.settings.php to $sn"
