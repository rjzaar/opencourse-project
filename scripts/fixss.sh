#!/bin/bash

# This will fix (or set) the site settings in local.settings.php

echo -e "\e[34m fix or set the site settings for $1 \e[39m"


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

sitename_var=$1

parse_pl_yml

import_site_config $sitename_var

fix_site_settings
