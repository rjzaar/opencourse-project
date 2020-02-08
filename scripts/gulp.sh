#!/bin/bash
# This will set the correct folder and file permissions for a drupal site.

#start timer
SECONDS=0

# Help menu
print_help() {
cat <<-HELP
This script is used to set upl gulp browser sync for a particular page.
You just need to state the sitename, eg loc and the page, eg opencat.loc
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


# This code could be better integrated.
sed -i "1s|.*|var page = \"$2\";|" "$site_path/$sitename_var/$webroot/themes/custom/$theme/gulpfile.js"
cd "$site_path/$sitename_var/$webroot/themes/custom/$theme/"
gulp & #This will start the scss syncing.
browser-sync start --proxy "$2" --files "**/*.twig, **/*.css, **/*.js" --reload-delay 1000 & # This will start browser sync.
echo "gulp and browser-sync started."

# to check for processes so background ones can be killed:
# ps -ef | grep "sync"
# ps -ef | grep "gulp"
