#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to install a variety of drupal flavours particularly opencourse
This will use opencourse-project as a wrapper. It is presumed you have already cloned opencourse-project.
you can provide the following arguments:

-i|--install 	This will install the files with the options you set, otherwise the database will be dumped and recreated and rebuilt.
-g|--git	This will do a git install, otherwise composer will be used.
-m|--migrate	For opencourse perform a migration from the old site. Only works if you have the database setup.
-p=*|--project=* give a composer install, eg rjzaar/opencourse:8.4.x-dev
-d|--dev	Development setup. Otherwise a non-dev installation will occur.
-y|--yes	Answer all prompts with yes.
-f=*|--folder=*	Specify the project folder name. This is the root folder for the installation. If not given the standard name will be used, eg opencourse for opencourse.
-sf=*|--sfolder=* Give the site folder name, otherwise the standard one will be used, eg opencourse/docroot, d8/web, social/html.
-u=*|--user=*	Username, ie your username on ubuntu.
-s|--secure	Do you want the private files folder stored somewhere else?
-a=*|--address=*|uri=* What is the localwebserver url? This will automatically open it up once the script completes.
-n|--nodownload This is a subchoice of install, where it is presumed the download has already occurred and so it picks up install at that point.
-db|--database Database name. If no database name is given then the foldername is used.
-dbuser|--databaseuser Database user name. If no username is given then the username is the same as the database name.
-dbpass|--databasepassword Database password If no password is given then the password is the same as the username.
-sn|--sitename This is the site name. It could be the URL of the site.

Options for project
    v|varbase
    oc|opencourse
    d8|drupal
    os|opensocial
    dr|druptopia
    l|lightning
    ocp|opencourse-project
or provide something else: rjzaar/opencourse:8.5.x-dev

Example (for varbase): ./scripts/ocinstall.sh -i -g -p=v -d -y -u=rob -s -a=v.b -db=vb -n
for opencourse: ./scripts/ocinstall.sh -i -g -p=oc -d -y -u=rob -s -a=o.c1
HELP
exit 0
}
nodown="n"
install='n'
git="n"
migrate="n"
dev="n"
yes="n"
secure="n"
user="rob"
uri="o.c"
sn="opencourse-project"
ofolder=false #This is to check if the user chose a folder or not. If not use the standard one for that install.
sfolder=false #site folder, folder where the site sits, not the site folder where default is.
project="opencourse"
# For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
# there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and 
private="/home/$user/$sn/private"
oc="n" #add opencourse modules etc.
cat="n" #add opencat setup.
# db is for database. It is used for db name, db user, db password to simplify things. It is the same as folder unless opencat setup.

if [ "$#" = 0 ]
then
print_help
exit 1
fi
for i in "$@"
do
case $i in
    -i|--install)
    install="y"
    shift # past argument=value
    ;;
    -g|--git)
    git="y"
    shift # past argument=value
    ;;
    -n|--nodownload)
    $nodown="y"
    shift # past argument=value
    ;;
    -m|--migrate)
    migrate="y"
    shift # past argument=value
    ;;
    -p=*|--project=*)
    project="${i#*=}"
    shift # past argument=value
    ;;
    -d|--dev)
    dev="y"
    shift # past argument=value
    ;;
    -y|--yes)
    yes="y"
    shift # past argument=value
    ;;
    -f=*|--folder=*)
    ofolder="${i#*=}"
    shift # past argument=value
    ;;
    -sf=*|--sfolder=*)
    sfolder="${i#*=}"
    shift # past argument=value
    ;;
    -u=*|--user=*)
    user="${i#*=}"
    shift # past argument=value
    ;;
    -s|--secure)
    secure="y"
    shift # past argument=value
    ;;
    -a=*|--address=*|uri=*)
    uri="${i#*=}"
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
    sn="${i#*=}"
    shift # past argument=value
    ;;
    -h|--help) print_help;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument *\n"
      printf "***************************\n"
      print_help
      exit 1
    ;;
esac
done
case $project in
    v|varbase)
    echo "varbase chosen"
    project="vardot/varbase-project:8.5.x-dev"
    gproject='git@github.com:Vardot/varbase.git'
    profile='varbase'
    sfolder='docroot'
    folder="varbase"
    ;;
    oc|opencourse)
    project="rjzaar/opencourse:8.5.x-dev"
    oc="y"
    gproject='git@github.com:rjzaar/opencourse.git'
    profile='varbase'
    sfolder='docroot'
    folder="opencourse"
    ;;
    d8|drupal)
    project="drupal-composer/drupal-project:8.x-dev"
    profile='standard'
    sfolder='web'
    folder="D8"
    ;;
    os|opensocial)
    project="goalgorilla/social_template:dev-master"
    profile='opensocial'
    sfolder='html'
    folder="opensocial"
    ;;

    dr|druptopia)
    project="drutopia/drutopia_template:dev-master"
    profile='drutopia'
    sfolder='web'
    folder="drutopia"
    ;;
    l|lightning)
    project="acquia/lightning-project"
    profile='lightning'
    sfolder='docroot'
    folder="lightning"
    ;;
    *)
    # unknown option
    project=$project
    ;;
esac

if [ "$ofolder" = false ]
then
folder=$folder
else
folder=$ofolder
fi

#Opencourse-project setup
if [ -z ${db+x} ]
then
    db=$folder
fi
if [ -z ${dbuser+x} ]
then
    dbuser=$db
fi
if [ -z ${dbpass+x} ]
then
    dbpass=$dbuser
fi


if [ "$sfolder" = false ]
then
#request sfolder
read -p "You need to choose the right site folder name (d(docroot)/h(html)/w(web)/or type in folder name" sfolderq
    case $sfolderq in
        d|docroot)
        sfolder="docroot"
        ;;
        h|html)
        sfolder="html"
        ;;
        w|web)
        sfolder="web"
        ;;
        *)
        # unknown option
        sfolder=$sfolderq
        ;;
    esac
else
sfolder=$sfolder
fi
private="/home/$user/$sn/private"
echo "Note the project will always be in the opencourse-project folder (unless you choose another name for it via the -sn=choice)"
echo "than the install folder."
echo "Install  = $install"
echo "Migrate  = $migrate"
echo "Git      = $git"
echo "Dev      = $dev"
echo "Project  = $project"
echo "Profile  = $profile"
echo "Install folder = $folder"
echo "site folder = $sfolder"
echo "uri      = $uri"
echo "secure   = $secure"
echo "Private folder = $private"
echo "nodownload = $nodown"
echo "Database = $db"
echo "Database user = $dbuser"
echo "Database password = $dbpass"
echo "Site name = $sn"
echo

if [ "$sn" != "opencourse-project" ]
then
    echo "folder needs to be changed and site name established."
    cd
    if [ ! -d "$sn" ]; then
    echo "Site folder $sn doesn't exist"
    mv opencourse-project $sn
    else
    echo "Site folder $sn already exists"
    fi
    echo "Record sitename in file ocvariables.txt"
    cd $sn
if [ ! -e "ocvariables.txt" ]; then
    echo "Creating ocvariables.txt"

  echo >> "ocvariables.txt"
fi
fi

#storing sitename so other scripts can use it.
echo "$sn" > "ocvariables.txt"

if [ "$install" = "y" ]
then
    echo "Installing ..."
    if [ "$nodown" = "n" ]
    then
        echo "Downloading ... (nodown = n)"
        if [ "$yes" != "y" ]
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

             git clone $gproject

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
            git reset origin/8.5.x  # this is required if files in the non-empty directory are in the repo
            git checkout -t origin/8.5.x
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
                git reset --hard origin/8.5.x
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
    sed -i '4iOptions +FollowSymLinks' $sn/$folder/$sfolder/.htaccess
    echo "install site"
    cd $sn/$folder/$sfolder

    #set up settings.local.php so drush won''t add database connections to settings.php
    echo "create settings.local.php"
    cd sites/default
    cp default.settings.php settings.php

     echo " if (file_exists(\$app_root . '/' . \$site_path . '/settings.local.php')) {
       include \$app_root . '/' . \$site_path . '/settings.local.php';
    }" >> settings.php


    migratesettings=""
    if [ "$migrate" = "y" ]
    then
    migratesettings="// Database entry for drush migrate-upgrade --configure-only
                     \$databases['upgrade']['default'] = array (
                       'database' => 'ocmigrate',
                       'username' => 'ocmigrate',
                       'password' => 'ocmigrate',
                       'prefix' => '',
                       'host' => 'localhost',
                       'port' => '3306',
                       'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
                       'driver' => 'mysql',
                     );
                     // Database entry for drush migrate-import --all
                     \$databases['migrate']['default'] = array (
                       'database' => 'ocmigrate',
                       'username' => 'ocmigrate',
                       'password' => 'ocmigrate',
                       'prefix' => '',
                       'host' => 'localhost',
                       'port' => '3306',
                       'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
                       'driver' => 'mysql',
                     );"
    fi

    if [ "$dev" = "y" ]
    then
        devp="\$settings['container_yamls'][] = DRUPAL_ROOT . '/sites/development.services.yml';
              \$settings['cache']['bins']['render'] = 'cache.backend.null';
              \$settings['cache']['bins']['dynamic_page_cache'] = 'cache.backend.null';
              \$config_directories[CONFIG_SYNC_DIRECTORY] = '../../cmi';"
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
    $migratesettings
    $devp
    " > settings.local.php
    cd
    dpath="/home/$user/$sn/$folder/$sfolder"
    echo "drupal path $dpath"
	echo "Fixing permissions requires sudo password."
    sudo bash ./$sn/scripts/d8fp.sh --drupal_user=$user --drupal_path=$dpath
    #chmod g+w -R $sn/$folder/$sfolder/modules/custom


fi
#

#Drop database  # Not needed since drush install will drop and recreate the database anyway.
# if [ "$yes" != "y" ]
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
cd $sn/$folder/$sfolder
echo "install drupal site"
# drush status
# drupal site:install  varbase --langcode="en" --db-type="mysql" --db-host="127.0.0.1" --db-name="$dir" --db-user="$dir" --db-pass="$dir" --db-port="3306" --site-name="$dir" --site-mail="admin@example.com" --account-name="admin" --account-mail="admin@example.com" --account-pass="admin" --no-interaction
 drush -y site-install $profile  --account-name=admin --account-pass=admin --account-mail=admin@example.com --site-name="$folder"
#don''t need --db-url=mysql://$dir:$dir@localhost:3306/$dir in drush because the settings.local.php has it.

#sudo bash ./d8fp.sh --drupal_path=$folder/$sfolder --drupal_user=$user #shouldn't need this, since files don't need to be changed.
#chmod g+w -R $folder/$sfolder/modules/custom

if [ "$oc" = "y" ]
then
    #install all required modules
    echo "Install modules for opencourse"
     #drush en -y oc_theme
	#for some reason does not set it as default!
     drupal theme:install  oc_theme --set-default
	drush cr
     drush config-set system.theme default oc_theme -y

    if [ "$dev" = "y" ]
    then
     drush en -y oc_dev
     #uninstall the wrapper. Will leave all dependencies installed.
     drush pm-uninstall -y oc_dev
    fi

    drush pm-uninstall -y oc_prod
    cd
    if [ "$install" = "y" ]
    then
    echo "fix permissions, requires sudo"
    # This is only if the install hasn''t been run before. All files should have correct permissions.
    sudo bash ./d8fp.sh --drupal_path=$folder/$sfolder --drupal_user=$user
    chmod g+w -R $folder/$sfolder/modules/custom
    fi
fi
cd
cd $sn/$folder/$sfolder
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
    cd $sn/$folder/$sfolder
    ../../scripts/resoc.sh install
    #Now run the script to embed the videos, external and internal links into the body.
    #drush scr ../../scripts/updoc.php
fi
#try again
###drush config-set system.theme default oc_theme -y
echo "Trying to go to URL $uri"
 drush uli --uri=$uri

