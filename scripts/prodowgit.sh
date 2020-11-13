#!/bin/bash
################################################################################
#                          prodowgit For Pleasy Library
#
#  This script will overwrite production with the site chosen It will first
#  backup prod The external site details are also set in pl.yml under prod:
#  It uses the git method to push the site up.
#
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-prodowgit'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC
Overwrite production with site specified
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl prodow stg
END HELP
HEREDOC

}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o hs:dy -l help,step:,debug,yes --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
  echo "No site specified."
    echo "please do 'pl prodow --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
step=1
while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 0; ;;
  -s | --step)
    flag_step=1
    shift
    step=${1:1}
    shift; ;;
  -d | --debug)
  verbose="debug"
  shift
  ;;
  -y | --yes)
    yes=1
    shift; ;;
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done

Pcolor=$Cyan


if [ $1 = "prodowgit" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 0
fi

sitename_var=$1

echo "overwriting production server with $sitename_var site using git method"

parse_pl_yml

import_site_config $sitename_var

if [[ ! "$prod_method"  == "git" ]] ; then
  echo "Production method git is not set in pl.yml. Aborting"
exit 1
fi

if [ $step -gt 1 ] ; then
  echo -e "Starting from step $step"
fi
prod_root=$(dirname $prod_docroot)
#First backup the current dev site if it exists
if [ $step -lt 2 ] ; then
echo -e "$Pcolor step 1: backup current sitename_var $sitename_var $Color_off"
pl backup $sitename_var "presync"

fi
#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
#echo "pre rsync"
#drush -y rsync @prod @$sitename_var -- --omit-dir-times --delete

if [ $step -lt 3 ] ; then
echo -e "$Pcolor step 2: backup production $Color_off"
## Make sure ssh identity is added
#eval `ssh-agent -s`
#ssh-add ~/.ssh/$prod_alias

to=$sitename_var
backup_prod
# sql file: $Namesql
# all files: $folderpath/sitebackups/prod/$Name.tar.gz
sitename_var=$to
import_site_config $sitename_var
fi

if [ $step -lt 4 ] ; then
echo -e "$Pcolor step 3: replace production files with $sitename_var $Color_Off"

cd
cd "$folderpath/sitebackups/$sitename_var"
options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
Name=${options[0]:2}
ocmsg "Name of sql backup: $Name "
 # Move sql backup to proddb and push
 echo "Using git method to push db and files to production"
# push database
if [[ ! -d "$folderpath/sitebackups/proddb" ]] ; then mkdir "$folderpath/sitebackups/proddb" ; fi
 cd "$folderpath/sitebackups/proddb"

ocmsg "Making sure we have the latest git"

ocmsg "Copying the databse from $sitename_var to git backup"
 cp ../$sitename_var/$Name prod.sql
 Bname=$(date +%d%b%g%l:%M:%S%p)
ocmsg "git add ."
if [[ ! $(git diff --exit-code) == "" ]] ; then
git add .
ocmsg "git commit"
git commit -m "pushup$Bname"
fi
git fetch
git merge -s ours master
git push

ocmsg "Now push the files"
cd "$site_path/$sitename_var"
 # Presume branch dev already created. otherwise run git checkout -b dev

# For some reason if there are no changes git commit will stop bash. I think it might be giving an error code?
# So check first and if no changes, don't commit.


if [[ ! $(git diff --exit-code) == "" ]] ; then
ocmsg "Need to commit files"
git add .
ocmsg "git commit"
git commit -m "pushup$Bname"
fi
git fetch
git merge -s ours origin -m "Overwriting with local"
git push origin

fi

if [ $step -lt 5 ] ; then
echo -e "$Pcolor step 4: install production files $Color_off"
prod_root=$(dirname $prod_docroot)
#ssh $prod_alias "cp -rf $prod_root $prod_root.old"
#ssh $prod_alias "rm -rf $prod_root"
#ssh $prod_alias "mkdir $prod_root"
#ssh $prod_alias "if [ -d $prod_root.new ]; then sudo rm -rf $prod_root.new ; fi"

echo -e "\e[34mrestoring files\e[39m"
    echo "prodkey: $prod_gitkey"
    # For now the script should work, but needs various improvments such as, being able to restore on error.
    ssh $prod_alias "./overwrite.sh $prod_docroot"
fi

if [ $step -lt 6 ] ; then
echo -e "$Pcolor step 5: open production site $Color_off"
drush @prod uli &
fi

# If it works, the production site needs to be swapped to prod branch from dev branch and hard rest to dev, is use 'ours'.

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0

