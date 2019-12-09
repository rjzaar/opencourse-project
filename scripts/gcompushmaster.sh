#!/bin/bash
# This will merge the branch into master
# It presupposes you have already merged branch with master
#
#  git checkout master
#  git pull origin master
#  git merge feature/[my-existing-branch]
#  git push origin master
#

#start timer
SECONDS=0
parse_pl_yml

if [ $1 == "gcompushmaster" ] && [ -z "$2" ]
  then
  sn="$sites_dev"
  elif [ -z "$2" ]
  then
    sn=$1
    msg="Updating."
   else
    sn=$1
    msg=$2
fi

echo "This will merge branch with master"
# Help menu
print_help() {
cat <<-HELP
This will merge branch with master
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
import_site_config $sn
cd $site_path/$sn

echo "Add credentials."
ssh-add ~/.ssh/$github_key

### Make sure branch has already been merged with master!!!!

# Could do a push to master
git checkout master
git pull origin master
git merge feature/[my-existing-branch]
git push origin master



