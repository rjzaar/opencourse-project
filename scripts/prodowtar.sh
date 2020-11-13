#!/bin/bash
################################################################################
#                          prodowtar For Pleasy Library
#
#  This script will overwrite production with the site chosen It will first
#  backup prod The external site details are also set in pl.yml under prod:
#  Using tar method
#
#  This script is used to turn off dev mode and uninstall dev modules.  You
#  just need to state the sitename, eg stg.
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
scriptname='pleasy-prodowtar'

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
pl prodowtar stg
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
args=$(getopt -o hs:y -l help,step:,yes --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
  echo "No site specified."
    echo "please do 'pl prodowtar --help' for more options"
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


if [ $1 = "prodowtar" ] && [ -z "$2" ]; then
  echo "No site specified"
  print_help
  exit 0
fi

sitename_var=$1

echo "overwriting production server with $sitename_var site"

parse_pl_yml

if [ "$prod_method" !== "tar" ]; then
  echo "Production method tar is not set in pl.yml. Aborting"
exit 1
fi
import_site_config $sitename_var

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
echo -e "$Pcolor step 3: replace production files with $sitename_var $Color_off"

cd
cd "$folderpath/sitebackups/$sitename_var"
options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
Name=${options[0]:2}

echo "Using tar method to push db and files to production"
  Name=$(date +%Y%m%d\T%H%M%S)
echo "uploading $Name"
scp $Name $prod_alias:$Name
ssh $prod_alias "cp $Name latest.sql -rf"

echo "uploading ${Name::-4}.tar.gz"
scp ${Name::-4}.tar.gz $prod_alias:${Name::-4}.tar.gz
ssh $prod_alias "cp ${Name::-4}.tar.gz latest.tar.gz -rf"
fi


if [ $step -lt 5 ] ; then
echo -e "$Pcolor step 4: install production files $Color_off"
prod_root=$(dirname $prod_docroot)
#ssh $prod_alias "cp -rf $prod_root $prod_root.old"
#ssh $prod_alias "rm -rf $prod_root"
#ssh $prod_alias "mkdir $prod_root"
#ssh $prod_alias "if [ -d $prod_root.new ]; then sudo rm -rf $prod_root.new ; fi"

echo -e "\e[34mrestoring files\e[39m"

ssh $prod_alias -t "sudo rm -rf $prod_root.new && sudo mkdir $prod_root.new"
if [ -z $Name ]
then
echo "Don't know the name so using the lastest.tar.gz on server to extract"
ssh $prod_alias -t "sudo tar -zxf latest.tar.gz --directory $prod_root.new --strip-components=1"
else
echo "Extracting ${Name::-4}.tar.gz into $prod_root.new"
ssh $prod_alias -t "sudo tar -zxf ${Name::-4}.tar.gz --directory $prod_root.new --strip-components=1"
fi

echo "fix file permissions, requires sudo on external server and Restoring correct settings.php"

ssh $prod_alias -t "sudo chown $prod_user:www-data $prod_root.new -R"
ssh $prod_alias "cp $prod_root/$(basename $prod_docroot)/sites/default/settings.php $prod_root.new/$(basename $prod_docroot)/sites/default/settings.php -rf"
ssh $prod_alias -t "sudo bash ./fix-p.sh --drupal_user=puregift --drupal_path=$prod_docroot.new/docroot"


fi


if [ $step -lt 6 ] ; then
echo -e "$Pcolor step 5: move site folders $Color_off"
prod_root=$(dirname $prod_docroot)
# Try the easy way
#result=$(drush sql:sync @$sitename_var @prod)
#if [ "$result" = ": 0" ]; then echo "Database synced"
#else
echo "Need to overwrite the database the hard way"
#echo "prod in maintenance mode"
#drush @prod sset system.maintenance_mode TRUE

echo "renaming folder to opencat.org to make it live"
# Now swap them.
if [ -z $Name ]; then Name=$(date +%Y%m%d\T%H%M%S) ; fi
echo "rm .old"
ssh $prod_alias -t "if [ -d $prod_root.old ]; then sudo rm -rf $prod_root.old ; fi"
echo "mv $prod_root to $prod_root.old"
ssh $prod_alias -t "if [ -d $prod_root ]; then sudo mv $prod_root $prod_root.old ; fi"
echo "mv new to current"
ssh $prod_alias -t "if [ -d $prod_root.new ]; then sudo mv $prod_root.new $prod_root ; fi"
fi

if [ $step -lt 7 ] ; then
echo -e "$Pcolor step 6: install production database $Color_off"
if [ 1 == 0 ]
then
drush sql:sync @$sitename_var @prod
else
# old method
echo "The restoring the database requires sudo on the external server."
if [ -z $Name ]
then
echo "Don't know the name so using the lastest.sql on server to restore"
ssh $prod_alias -t "sudo ./restoredb.sh latest.sql"
else
echo "Restoring $Name to production database"
ssh $prod_alias -t "sudo ./restoredb.sh $Name"
fi
fi
fi

if [ $step -lt 8 ] ; then
echo -e "$Pcolor step 7: prod in production mode $Color_off"
drush @prod sset system.maintenance_mode FALSE

echo "clearing cache"
ssh $prod_alias "cd $prod_docroot && drush cr"

#fi
fi

if [ $step -lt 9 ] ; then
echo -e "$Pcolor step 8: open production site $Color_off"
drush @prod uli
fi

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0











echo "docroot"
drush -y rsync @$sitename_var @prod -- -O  --delete
echo "cmi"
drush -y rsync @$sitename_var:../cmi @prod:../cmi -- -O  --delete
echo "vendor"
drush -y rsync @$sitename_var:../vendor @prod:../vendor -- -O  --delete
echo "bin"
drush -y rsync @$sitename_var:../bin @prod:../bin -- -O  --delete
echo "composer.json"
drush -y rsync @$sitename_var:../composer.json @prod:../composer.json -- -O  --delete
echo "composer.lock"
drush -y rsync @$sitename_var:../composer.lock @prod:../composer.lock -- -O  --delete

# Now sync the database
drush sql:sync @$sitename_var @prod

drush @prod cr
drush @prod sset system.maintenance_mode FALSE

# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0



#On prod:
# maintenance mode
echo "prod in maintenance mode"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"

# backup db and private files
echo "backup proddb and private files"
ssh $prod_alias "./backoc.sh"

# pull opencat
echo "pull opencat"
ssh $prod_alias "./pull.sh"

#restore private files, just in case some were added between test and deploy
echo "remove prod private files"
ssh $prod_alias "cd opencat.org && rm -rf private"
echo "restore prod private files"
ssh $prod_alias "cd opencat.org && tar -zxf ../ocbackup/private.tar.gz"
echo "Fix permissions, requires sudo"
ssh -t $prod_alias "sudo chown :www-data opencat.org -R"
ssh -t $prod_alias "sudo ./fix-p.sh --drupal_user=puregift --drupal_path=/home/puregift/opencat.org/opencourse/docroot"

#update drupal
echo "prod drush updb"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush updb -y"
echo "prod drush fra"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush fra -a"
echo "prod drush cr"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush cr"

# update/cmi import
echo "prod cmi import"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush cim --source=../../cmi/ -y"
echo "prod cr"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush cr"

# out of maintenance mode
echo "prod prod mode"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"

echo -e "\e[34mpatch .htaccess on prod\e[39m"
ssh $prod_alias "cd opencat.org/opencourse/docroot/ && sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess"

#for some reason this is needed again.
echo -e "\e[34mFix ownership may need sudo password.\e[39m"
ssh $prod_alias "sudo chown :www-data opencat.org -R"




# test again.
