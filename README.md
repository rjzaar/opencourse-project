# Pleasy

[![Build Status](https://travis-ci.com/rjzaar/pleasy.svg?branch=master)](https://travis-ci.com/rjzaar/pleasy)

This is a Devops framework for drupal sites, particularly based on varbase.
The framework is run through the pl (short for please), plcd and plvi commands.
The pl command has been added to bash commands so can be accessed anywhere. It is followed by the script name and usually which instance to be worked on, eg "pl backup stg" will backup the stage instance.
There is a yaml file which contains the framework setup. An example yaml file is provided and is ready to be used, with some tweaking required.
You set it up with the following commands

```
git clone git@github.com:rjzaar/pleasy.git [sitename]  #eg git clone git@github.com:rjzaar/pleasy.git mysite.org
cd [sitename]
cp example.pl.yml pl.yml
```
Now edit pl.yml with your settings.
```
cd bin
./pl init  #This will setup the necessary variables.
```
You will now have a functioning pleasy.
If there is an error "function asorti never defined" then run the following command and it should now work
```
sudo apt install gawk
```


You should now be able to install your first site:
```
pl install loc
```

It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three stages, dev (called loc for local), stg and prod. Communication with the production server is via drush and scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.
It provides an intelligent separation.

Since a particular site based project needs to include site specific files which should be stored on a private repository for backup, there is one more layer needed.
The only difference with this layer is the .gitignore file which includes folders needed on production. Welcome to Drupal 8 development.

#New Commands
Here is the simple setup for an opencourse development environment
First choose the name of your dev environment (It will be used as the last part of the site url) I suggest oc

git clone git@github.com:rjzaar/opencourse-project.git oc

cd oc
The next step will give access to the powerful drop command (thanks Alexar!) to setup the site based on the pl.yml file
cp example.pl.yml pl.yml
edit the pl.yml file and change accordingly, eg add database credentials. If you don't add database credentials,
no problem, it will prompt you as you go.
./scripts/ocinit.sh

#List of Commands



# Developing pleasy

Messages are kept to a minimum in normal use. You can add a -v --verbose option to recieve messages for all the internal
steps.
For any command more messages are provided if you add the -d  --debug option. This will turn on debug mode and provide more
information for you.

#The Manual Way
You will need to add a sitename ssh key for your server. Add the following to your .ssh/config file
Host sitename
        User serveruser
        Port 22
        Hostname sitename
        IdentityFile ~/.ssh/sitename

Make sure you have a key to your server at ~/.ssh/sitename


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


