#!/bin/bash

# Get the helper functions etc.
. $script_root/_inc.sh;

#. $script_root/lib/common.inc.sh;
#. $script_root/lib/db.inc.sh;
#. $script_root/scripts/_inc.sh;

# Help menu
print_help() {
cat <<-HELP
This script is used to install a variety of drupal flavours particularly opencourse
This will use opencourse-project as a wrapper. It is presumed you have already cloned opencourse-project.
you can provide the following arguments:

-r|--rebuild 	The database will be dumped, recreated and rebuilt.
-g|--git	This will do a git install, otherwise composer will be used.
-p=*|--project=* give a composer install, eg rjzaar/opencourse:8.7.x-dev
-pr=*|--profile=* The profile to be installed
-d|--dev	Development setup. Otherwise a non-dev installation will occur.
-au|--auto	Answer all prompts with yes.
-w=*|--webroot=* Give the site folder name, otherwise the standard one will be used, eg opencourse/docroot, d8/web, social/html.
-a=*|--address=*|uri=* What is the localwebserver url? This will automatically open it up once the script completes.
-n|--nodownload This is a subchoice of install, where it is presumed the download has already occurred and so it picks up install at that point.
-db|--database Database name. If no database name is given then the foldername is used.
-dbuser|--databaseuser Database user name. If no username is given then the username is the same as the database name.
-dbpass|--databasepassword Database password If no password is given then the password is the same as the username.
-sn|--sitename This is the site name, eg dev. The url will be sn.folder, eg dev.oc, unless address is specified.
-ap|--apache This will set up apache and hosts infrastructure based on your settings

"site" Any site name that is made up of letters and numbers only.
WARNING: if you overwrite an option in the recipe, it will not be saved in the recipe.


HELP
exit 0
}

auto="y"
folder=$(basename $(dirname $script_root))
webroot="docroot" # or could be web or html
project="rjzaar/opencourse:8.7.x-dev"
# For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
# there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and
sn="dev"
profile="varbase"
dev="y"

parse_oc_yml

#Import oc.yml settings
# Create a list of recipes
for f in $recipes_ ; do recipes="$recipes,${f#*_}" ; done
recipes=${recipes#","}

# Check to see if recipe is present
# Get the sitename
for i in "$@"
do
case $i in
    *[^[:alnum:]]*)
    ;;
    *)
    sn=$i
    ;;
esac
done

if [[ $recipes != *"$sn"* ]]
then
echo "No recipe! For now aborting. Could in future add the details."
exit 1
fi

import_site_config $sn



#Field_Separator=$IFS
## set comma as internal field separator for the string list
#IFS=,
#for val in $recipes;
#do
#echo ">$val<"
#done
#IFS=$Field_Separator

if [ "$#" = 0 ]
then
print_help
exit 1
fi
for i in "$@"
do
case $i in
    -p=*|--project=*)
    $project="${i#*=}"
    shift # past argument=value
    ;;
    -pr=*|--profile=*)
    $profile="${i#*=}"
    shift # past argument=value
    ;;
    -d|--dev)
    dev="y"
    shift # past argument=value
    ;;
    -au|--auto)
    auto="y"
    shift # past argument=value
    ;;
    -w=*|--webroot=*)
    $webroot="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--user=*)
    user="${i#*=}"
    shift # past argument=value
    ;;
    -a=*|--address=*|uri=*)
    $uri="${i#*=}"
    shift # past argument=value
    ;;
    -db=*|--database=*)
    db="${i#*=}"
    shift # past argument=value
    ;;
    -dbuser=*|--databaseuser=*)
    dbuser="${i#*=}"
    shift # past argument=value
    ;;
    -dbpass=*|--databasepassword=*)
    dbpass="${i#*=}"
    shift # past argument=value
    ;;
    -sn=*|--sitename=*)
    $sn="${i#*=}"
    shift # past argument=value
    ;;
    -ap|--apache)
    apache="y"
    shift # past argument=value
    ;;
    -h|--help) print_help;;
    *)
    case $i in
        *[^[:alnum:]]*)
            printf "***************************\n"
            printf "* Error: Invalid argument *\n"
            printf "***************************\n"
            print_help
            exit 1
        ;;
            *)
            sn=$i
        ;;
    esac
    ;;
esac
done

private="/home/$user/$folder/$sn/private"
uri="$sn.$folder"

db_defaults

echo "Installing $sn"
echo "About to install:"
site_info
echo

exit 1
install="y"

if [ "$install" = "y" ]
then
    echo "Installing ..."
    if [ "$nodown" = "n" ]
    then
        echo "Downloading ... (nodown = n)"
        if [ "$auto" != "y" ]
        then
        read -p "Do you want to delete the folder $folder if it exists (y/n/c)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;

        esac
        fi

        echo "Move to opencourse-project folder"
        cd
        cd $sn
        echo "remove $folder: May need sudo password."
        sudo rm -rf $folder
        #if [ "$cat" = "y" ]
        #then
        #    rm -rf opencat
        #fi

        #set group so file permissions are correct.
        #echo "set group to www-data"
        #newgrp www-data
        echo "Checking for git"
        if [ "$git" = "y" ]
        then
            echo "Adding git credentials"
             ssh-add /home/$user/.ssh/github
            echo "Cloning  git project: $gproject"

             git clone $gproject $folder

            echo "move to project folder $folder"
            cd
            cd $sn/$folder/
            if [ "$folder" = "opencourse" ]
            then
                echo "Opencouse so add upstream varbase-project.git"
             git remote add upstream git@github.com:Vardot/varbase-project.git
            fi
            echo "Run composer install"
            composer install
        else
            if [ "$dev" = "y" ]
            then
                echo "Setting composer install to dev."
                devs="--stability dev"
            else
                devs=""
            fi

            echo "Run composer create project: $project"
             composer create-project $project $folder $devs --no-interaction
        fi

        # Add opencourse git if you are going to override the upstream with new version...?
        # this needs a lot or checking out....
        if [ "$cat" = "y" ]
        then
            cd
            cd $sn/$folder
            echo "initialising and adding git to opencourse"
            git init
            git remote add origin git@github.com:rjzaar/opencourse.git
            git fetch
            git reset origin/8.7.x  # this is required if files in the non-empty directory are in the repo
            git checkout -t origin/8.7.x
            git status
            if [ $? -eq 0 ]; then
             echo Good status
            else
             echo bad status
            fi
            git diff
            read -p "Do you want to (a)bort, (p)ush current status to remote, or (o)veride with remote or (c)ontinue (a/p/o/c)" question
            case $question in
                a)
                echo aborting
                exit 1
                ;;
                p)
                echo push current to opencourse git remote
                git add .
                git commit -m "Adding current files from opencat."
                git push
                ;;
                o)
                echo overriding current with opencourse git remote
                git fetch --all
                git reset --hard origin/8.7.x
                ;;
                *)
                echo Continuing ...
                ;;
            esac
             git remote add upstream git@github.com:Vardot/varbase.git
             cd
            sudo chown $user:www-data -R $sn
            cd $sn/$folder
            echo "Composer install"
             composer install

        fi
    fi
    #end of nodown can now continue to install
    echo "change file permissions add www-data as group"
    cd
    sudo chown $user:www-data -R $sn

	echo "patch .htaccess"
    sed -i '4iOptions +FollowSymLinks' $sn/$folder/$webroot/.htaccess
    echo "install site"
    cd $sn/$folder/$webroot

    #set up settings.local.php so drush won''t add database connections to settings.php
    echo "create settings.local.php"
    cd sites/default
    cp default.settings.php settings.php

     echo " if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }" >> settings.php

    if [ "$dev" = "y" ]
    then
        devp="\$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
              \$settings['cache']['bins']['render'] = 'cache.backend.null';
              \$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
              \$config_directories[CONFIG_SYNC_DIRECTORY] = '../cmi';"
    else
        devp=""
    fi
    if [ "$secure" = "y" ]
        then
        secures="\$settings['file_private_path'] =  '$private';"
        # Create private files directory.
        echo "Create private files directory"
        if [ ! -d $private ]; then
          mkdir $private
        fi
        chmod 770 -R $private
        chown $user:www-data -R $private
    fi

     echo "<?php

    \$settings['install_profile'] = '$profile';
    $secures
    \$databases['default']['default'] = array (
      'database' => '$db',
      'username' => '$dbuser',
      'password' => '$dbpass',
      'prefix' => '',
      'host' => 'localhost',
      'port' => '3306',
      'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
      'driver' => 'mysql',
    );
    $devp
    " > settings.local.php
    cd
    dpath="/home/$user/$sn/$folder/$webroot"
    echo "drupal path $dpath"
	echo "Fixing permissions requires sudo password."
    sudo bash ./$sn/scripts/d8fp.sh --drupal_user=$user --drupal_path=$dpath
    #chmod g+w -R $sn/$folder/$webroot/modules/custom


fi
#

#Drop database  # Not needed since drush install will drop and recreate the database anyway.
# if [ "$auto" != "y" ]
#    then
#    read -p "do you want to drop the database $folder if it exists (y/n/c)" question
#    case $question in
#        n|c|no|cancel)
#        echo exiting immediately, no changes made
#        exit 1
#        ;;
#    esac
#    fi
#echo "drop database"
#mysqladmin -u $dbuser -p$dbpass -f drop $db;
#echo "recreate database"
#mysql -u $dbuser -p$dbpass -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";

cd
cd $sn/$folder/$webroot
echo "install drupal site"
# drush status
# drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
 drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$folder"
#don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.

#sudo bash ./d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user #shouldn't need this, since files don't need to be changed.
#chmod g+w -R $folder/$webroot/modules/custom

if [ "$oc" = "y" ]
then
    #install all required modules
    echo "Install modules for opencourse"
     #drush en -y oc_theme
	#for some reason does not set it as default!
     drupal theme:install  oc_theme --set-default
	drush cr


    if [ "$dev" = "y" ]
    then
     drush en -y oc_dev
     #uninstall the wrapper. Will leave all dependencies installed.
     drush pm-uninstall -y oc_dev
    else
     drush en -y oc_prod
    fi

    drush pm-uninstall -y oc_prod
    cd
    if [ "$install" = "y" ]
    then
    echo "fix permissions, requires sudo"
    # This is only if the install hasn''t been run before. All files should have correct permissions.
    sudo bash ./$folder/scripts/d8fp.sh --drupal_path=$folder/$webroot --drupal_user=$user
    chmod g+w -R $folder/$webroot/modules/custom
    chmod g+w $folder/private -R
    fi
    cd $sn/$folder/$webroot
    drush config-set system.theme default oc_theme -y
fi
cd
cd $sn/$folder/$webroot
if [ "$dev" = "y" ]
then
echo "Setting to dev mode"
 drupal site:mode dev
 drush php-eval 'node_access_rebuild();'
fi
if [ "$migrate" = "y" ] && [ "$oc" = "y" ]
then
    echo "Run migrations"
    cd
    cd $sn/$folder/$webroot
    ../../scripts/resoc.sh install
    #Now run the script to embed the videos, external and internal links into the body.
    echo "Incorporate video and links into ocdoc body."
    drush scr ../../scripts/updoc.php
fi
#try again
###drush config-set system.theme default oc_theme -y
echo "Trying to go to URL $uri"
 drush uli --uri=$uri

