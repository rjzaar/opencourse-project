#!/bin/bash
#prodow
#This will backup prod, and overwrite prodution with site chosen
#This presumes teststg.sh worked, therefore opencat git is upto date with cmi export and all files.

#start timer
SECONDS=0
Pcolor=$Cyan
step=1
if [ $1 = "prodow" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi
sn=$1
if [ -z "$3" ]
  then
for i in "$@"
do
case $i in
    -s=*|--step=*)
    step="${i#*=}"
    shift # past argument=value
    ;;
    -y|--yes)
    yes="y"
    shift
    ;;
    -h|--help) print_help;;
    *)
    shift # past argument=value
    ;;
esac
done
fi

echo "overwriting production server with $sn site"
. $script_root/_inc.sh;
parse_pl_yml

import_site_config $sn


# Help menu
print_help() {
cat <<-HELP
This script will overwrite production with the site chosen
It will first backup prod
The external site details are also set in pl.yml under prod:
HELP
exit 0
}

if [ $step -gt 1 ] ; then
  echo -e "Starting from step $step"
fi

#First backup the current dev site if it exists
if [ $step -lt 2 ] ; then
echo -e "$Pcolor step 1: backup current sn $sn $Color_off"
pl backup $sn "presync"
fi
#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
#echo "pre rsync"
#drush -y rsync @prod @$sn -- --omit-dir-times --delete

if [ $step -lt 3 ] ; then
echo -e "$Pcolor step 2: backup production $Color_off"
# Make sure ssh identity is added
eval `ssh-agent -s`
ssh-add ~/.ssh/$prod_alias
to=$sn
backup_prod
# sql file: $Namesql
# all files: $folderpath/sitebackups/prod/$Name.tar.gz
sn=$to
fi

if [ $step -lt 4 ] ; then
echo -e "$Pcolor step 3: replace production files with $sn $Color_off"

Name=$(date +%Y%m%d\T%H%M%S)
cd
cd "$folder/sitebackups/$sn"
options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
Name=${options[0]:2}
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
ssh $prod_alias "if [ -d $prod_root.new ]; then rm -rf $prod_root.new ; fi"

echo -e "\e[34mrestoring files\e[39m"
if [ -z $Name ]
then
echo "Don't know the name so using the lastest.tar.gz on server to extract"
ssh $prod_alias "tar -zxf latest.tar.gz --directory $prod_root.new --strip-components=1"
else
echo "Extracting ${Name::-4}.tar.gz into $prod_root"
ssh $prod_alias "tar -zxf ${Name::-4}.tar.gz --directory $prod_root.new --strip-components=1"
fi

echo "Restoring correct settings.php"
ssh $prod_alias "cp ocbackup/settings.php $prod_root.new/$(basename $prod_docroot)/sites/default/settings.php -rf"

echo fix file permissions, requires sudo on external server
ssh $prod_alias -t "sudo chown $prod_user:www-data $prod_root.new -R"
ssh $prod_alias -t "sudo bash ./fix-p.sh --drupal_user=puregift --drupal_path=$prod_docroot.new"
fi

if [ $step -lt 6 ] ; then
echo -e "$Pcolor step 5: install production database $Color_off"

# Try the easy way
#result=$(drush sql:sync @$sn @prod)
#if [ "$result" = ": 0" ]; then echo "Database synced"
#else
echo "Need to overwrite the database the hard way"
echo "prod in maintenance mode"
drush @prod sset system.maintenance_mode TRUE

echo "renaming folder to opencat.org to make it live"
# Now swap them.
if [ -z $Name ]; then Name=$(date +%Y%m%d\T%H%M%S) ; fi
ssh $prod_alias "if [ -d $prod_root.old ]; then rm -rf $prod_root.old ; fi"
ssh $prod_alias "if [ -d $prod_root ]; then mv $prod_root $prod_root.old ; fi"
ssh $prod_alias "if [ -d $prod_root.new ]; then mv $prod_root.new $prod_root ; fi"

if [ 1 == 1 ]
then
drush sql:sync @$sn @prod
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

echo "prod in production mode"
drush @prod sset system.maintenance_mode FALSE

echo "clearing cache"
ssh $prod_alias "cd opencat/opencourse/docroot && drush cr"

#fi
fi

if [ $step -lt 7 ] ; then
echo -e "$Pcolor step 6: open production site $Color_off"
drush @prod uli
fi

echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0











echo "docroot"
drush -y rsync @$sn @prod -- -O  --delete
echo "cmi"
drush -y rsync @$sn:../cmi @prod:../cmi -- -O  --delete
echo "vendor"
drush -y rsync @$sn:../vendor @prod:../vendor -- -O  --delete
echo "bin"
drush -y rsync @$sn:../bin @prod:../bin -- -O  --delete
echo "composer.json"
drush -y rsync @$sn:../composer.json @prod:../composer.json -- -O  --delete
echo "composer.lock"
drush -y rsync @$sn:../composer.lock @prod:../composer.lock -- -O  --delete

# Now sync the database
drush sql:sync @$sn @prod

drush @prod cr
drush @prod sset system.maintenance_mode FALSE

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