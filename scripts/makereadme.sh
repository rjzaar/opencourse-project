#!/bin/bash
# This will set the correct folder and file permissions for a drupal site.
. $script_root/_inc.sh;
parse_pl_yml

# Help menu
print_help() {
cat <<-HELP
This script is used to list all commands and add the help of each command to the README file.
HELP
exit 0
}
if [ "$1" = "-h" ]
then
print_help
exit 1
fi

for entry in `ls $folderpath/scripts`; do
    echo $entry
done
