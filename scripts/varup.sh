#!/bin/bash
#backup db and files

#start timer
SECONDS=0
echo -e "\e[34m update varbase on $1 site\e[39m"
. $script_root/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to update a particular site to the latest varbase available.
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
msg="$2"
#folder=$(basename $(dirname $script_root))
#webroot="docroot"
parse_pl_yml
import_site_config $sn

echo "Updating varbase"
cd $site_path/$sn/
./bin/update-varbase.sh



echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



