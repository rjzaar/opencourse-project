# opencourse-project

This project is a folder wrapper for opencourse or other distributions. It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three stages, dev, stg and prod. There are some scripts needed on the production server.
This project is also based on the varbase two repository structure, varbase and varbase-project. This is a good way to go since most updates to varbase don't need to be updated on a varbase based project. Those that do are included in varbase-project. There are also a lot less files to track in varbase-project than varbase itself. It provides an intelligent separation. But there is need for another wrapper for a varbase project, since scripts, cmi and private folders need to be excluded from standard access. Since a particular site based project needs to include site specific files which should be stored on a private repository for backup, there is one more layer needed. The only difference with this layer is the .gitignore file which includes folders needed on production. Welcome to Drupal 8 development. 

#New Commands
Here is the simple setup for an opencourse development environment
First choose the name of your dev environment (It will be used as the last part of the site url) I suggest oc

git clone git@github.com:rjzaar/opencourse-project.git oc

cd oc
The next step will give access to the powerful drop command (thanks Alexar!) to setup the site based on the oc.yml file
cp example.oc.yml oc.yml
edit the oc.yml file and change accordingly, eg add database credentials. If you don't add database credentials, 
no problem, it will prompt you as you go.
./scripts/ocinit.sh  

#The Manual Way
Create a database and user (change db, dbuser and dbpass to whatever you want)
mysql -u username -p -e "CREATE DATABASE db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci";
mysql -u username -p
CREATE USER dbuser@localhost IDENTIFIED BY 'dbpass';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, CREATE TEMPORARY TABLES ON db.* TO 'dbuser'@'localhost' IDENTIFIED BY 'dbpass'; 

For development you want to set up a local instance on apache
edit the hosts filea and add "127.0.0.1 address" where address is the URL of your local webserver.
sudo vi /etc/hosts
127.0.0.1 address

You will need to add a sitename ssh key for your server. Add the following to your .ssh/config file
Host sitename
        User serveruser
        Port 22
        Hostname sitename
        IdentityFile ~/.ssh/sitename
        
Make sure you have a key to your server at ~/.ssh/sitename

Add an apache rule:
address.conf:
```<VirtualHost *:80>
        ServerName address
        DocumentRoot /home/user/sitename/folder/sfolder
               <Directory /home/user/sitename/folder/sfolder>
                                Options None
                                Require all granted
                                AllowOverride All
                </Directory>
        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
# vim: syntax=apache ts=4 sw=4 sts=4 sr noet
```

then 
```
sudo a2ensite address.conf
sudo service apache2 restart
```
    git clone git@github.com:rjzaar/opencourse-project.git octest
    cd octest
    ./scripts/ocinstall.sh -i -g -p=oc -d -y -u=rob -s -a=address -db=db -f=octest
To install varbase:

    ./opencourse-project/scripts/ocinstall.sh 

# REQUIREMENTS
sudo apt-get install php7.0-zip (for h5p)

# PRODUCTION SERVER 
The production server settings.local.php needs to have
```$settings['config_readonly'] = TRUE;```

so config can't be changed on the production server.

Make sure the production server has the same timezone as dev

```sudo dpkg-reconfigure tzdata```

# Here is the structure explained in detail
VARBASE
This is where vardot works on all the details for the Drupal distribution of varbase.

VARBASE-PROJECT
This is where vardot provides a project wrapper for varbase which it uses its own way for creating a subdistribution. I use it differently by forking it and maintaining it as the upstream version. This allows me to merge changes for updates. The great advantage here is I don't need to merge the details since they are in varbase, only the 'macro' changes. Thanks Vardot. :)

OPENCOURSE
This is a fork of varbase-project which includes all the opencourse functionality. It can therefore be extended different ways. This is for all development work on the project itself. This means it can in incorporated into various different staging strategies.

OPENCOURSE-PROJECT
This is a particular staging strategy taking into account the new complexities (I'm looking at you composer and cmi) Drupal uses. While composer and cmi bring many advantages, they need to be managed properly so errors are properly dealt with and don't end up in production. These should be able to be automated for quicker error finding and prepartion for using tools like docker and travis. The opencourse-project provides a number of scripts that provides automated ways to move between stages dev, stg and prod and (still to be written) ways to revcover from mishaps. 

OCSITE
Opencourse-project is written for its own development. Anyone wanting to build on it will need to fork it and have it setup as the upstream version. Opencourse-project is setup so all you have to do is fork it. There is then one set of changes for the gitignore so private and cmi are included in the standard gitignore. There is another gitignore for development which is used when working on opencourse-project itself. Database backup folders could also be included. Ocsite is your private site backup on github (or any git server?). 

While it appears complex, the structure provides clear separation between each of the layers, with improvements cascading through and the potential to automate these changes with automated tests and auto updates. It must be honestly taken into account that the time period between drupal security updates made available and incorporated on production is critical and the new drupal complexities means this can take time. Any serious update should not break current sites and a 'drush up drupal' should be enough, but I'm not silly enough to guarantee that. I don't know of any other tool that can provide the breadth of possibilities (Drupal framework and modules) I need in a dev environment while building on and incorporating other people's work (Vardot and maybe Opigno later). Drupal is going to be around for a long time and building on D8 should last awhile, this is particularly appealing, though it is yet to be seen that this is a wise choice. The cutting edge is usually the bleeding edge. But so far so good.

# SUMMARY so far
Either fork opencourse and use your own infrastructure or fork opencourse-project and use the provided set of scripts to manage your dev, stg and prod stages.

# Processes
The process is as follows:
1) dev2stg (opencourse push)
2) teststg (pull prod database and test)
3) stg2prod (opencat push)
4) stg2dev (if opencourse.git not present, then pull opencourse.git and setup).

#dev2stg
Make changes to move from a dev to stg environment.
This is the same folder with the same database, just some changes are made to setup.
This presumes a single dev is able to work on dev and stg on his own, without a common stg server (for now).
Note database is the same between dev and stg in the forward direction.

- turn off dev settings
- turn off dev modules
- opencourse git push
- turn off composer dev (patch .htaccess)
- rebuild permissions
- clear cache
(uninstall feature modules (leaves settings on site).???)

#teststg
This will pull down the production db and test it.
- backup whole stg site (stored in ~/ocbackup/site/oc.tar)
- export cmi
- backup stgdb (stored in ~/ocbackup/localdb/oc.sql)
- pull proddb (calls backoc.sh on prod, pulls db and private files, replaces private files)
- push opencat
- import proddb
- update db, fra, cim, clear cache

#stg2prod
Make changes to move from a dev to stg environment.
This is the same folder with the same database, just some changes are made to setup.
This presumes a single dev is able to work on dev and stg on his own, without a common stg server (for now).
- put prod in maintenance mode
- backup proddb and private files
- pull opencat on prod
- restore private files (since the pull possible overwrites new ones)
- update drupal, fra, cr
- import cmi
- prod mode
- check site!

# restore prod
This script needs to be written in case stg2prod does not work right.
- maintenance mode
- restore files
- restore db
- prod mode

#prod2stg
This is defunct, since teststg serves the same purpose better.

#stg2dev
Need to check if there is an opencourse git or not.
if not, then delete opencourse and clone a fresh opencourse and install (dev is default).
- move opencourse git (not needed since ignored.)
- turn on dev modules (composer install and patch .htaccess)
- rebuild file permissions
- enable dev modules (oc_dev)
- site mode dev
- clear cache

#resoc.sh
This script ran migrations from the old D7 database. It is now defunct since the structure has improved and
a new method needs to be developed to copy the live database, sanitize it and use it
to populate the demo site.

#updoc.php
This is now defunct. It moved field data into embeded nodes in the body field for all docs.

#ocupdate2ustream.sh
This is used to update opencourse to the latest varbase release.

#overwritestg2prod
this script will overwrite the production site with stg. All data on production will be lost. 
This is good for a first setup of production.


#git commit steps for branch
1) You create a branch
2) You just commit your code to branch
3) You tell the sitemaster to merge your code OR follow the following steps.
4) Very optional: you update your local with composer update and commit branch
5) Optional: you update your local with the upstream.
6) Optional: you update your local with master and commit branch
7) You update your local with master and commit master

#git commit steps for master
1) You just commit your code to master
2) Very optional: you update master with composer update and commit branch
3) You update master with the upstream.

#todo
Could add drupal console config file ~/.console/config.yml
Important: go through gcom code and add parts to _inc.yml
set up sudoers properly: https://www.drupal.org/node/244924#script-based-on-guidelines-given-above

install drush using composer: 
composer global update
composer global require drush/drush:^9.0.0

set up drush to work with both drush 8 and 9
https://github.com/drush-ops/drush/blob/master/examples/example.site.yml
drush core:init


Need sendmail installed


