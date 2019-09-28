#!/bin/bash
# This will set the correct folder and file permissions for a drupal site.

#start timer
SECONDS=0

# Help menu
print_help() {
cat <<-HELP
This script is used to fix permissions of a Drupal site
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
parse_oc_yml
import_site_config $sn

# This will set the correct permissions
# Persumes the following information is set
# $user
# $folder
# $sn
# $webroot
set_site_permissions



