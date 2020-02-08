#!/bin/bash
# This will git commit changes and run an backup to capture it.
#

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "gcom" ] && [ -z "$2" ]
  then
  sitename_var="$sites_dev"
  elif [ -z "$2" ]
  then
    sitename_var=$1
    msg="Commit."
   else
    sitename_var=$1
    msg=$2
fi

echo "This will git commit changes on site $sitename_var with msg $msg and run an backup to capture it."
# Help menu
print_help() {
cat <<-HELP
This script follows the correct path to git commit changes
You just need to state the sitename, eg dev.
HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

parse_pl_yml
import_site_config $sitename_var

echo "Add credentials."
ssh-add ~/.ssh/$github_key

ocmsg "Commit git add && git commit with msg $msg"
git add .
git commit -m msg
git push

ocmsg "Backup site $sitename_var with msg $msg"
backup_site $sitename_var $msg





