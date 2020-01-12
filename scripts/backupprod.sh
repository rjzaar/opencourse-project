#!/bin/bash
#backup db and files

#start timer
SECONDS=0
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to backup prod site's files and database. You can add an optional message.
HELP
exit 0
}
if [ $1 == "backupprod" ] && [ -z "$2" ]
  then
  echo -e "\e[34mbackup prod \e[39m"
  elif [ -z "$2" ]
  then
  echo -e "\e[34mbackup prod with message $1\e[39m"
  else
  print_help
fi

msg=$1
#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_pl_yml

backup_prod $msg

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



