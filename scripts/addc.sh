#!/bin/bash
# This will set the correct folder and file permissions for a drupal site.

# Help menu
print_help() {
cat <<-HELP
This script is used to add github credentials
HELP
exit 0
}
if [ "$1" = "-h" ]
then
print_help
exit 1
fi


parse_pl_yml
echo "Adding key $github_key"
ssh-add ~/.ssh/$github_key





