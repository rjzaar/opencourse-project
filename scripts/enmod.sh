#!/bin/bash

# See help

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "enmod" ] && [ -z "$2" ]
  then
echo "You need to specify the site and the module in that order"
print_help
fi
if [ -z "$2" ]
  then
echo "You have only given one argument. You need to specify the site and the module in that order"
print_help
   else
    sitename_var=$1
    mod=$2
fi

echo "This will install and enable the $mod module for the site $sitename_var using both composer and drush en automatically."
parse_pl_yml
import_site_config $sitename_var
# Help menu
print_help() {
cat <<-HELP
This script will install a module first using composer, then fix the file/dir ownership and then enable the module
using drush automatically.
HELP
exit 0
}

cd $site_path/$sitename_var
echo "Installing module using composer"
composer require drupal/$mod

echo "Fixing site permissions."
sudo chown :www-data $site_path/$sitename_var -R

echo "installing using drush"
drush @$sitename_var en -y $mod

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))

