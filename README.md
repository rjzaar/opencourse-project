# opencourse-project

This project is a folder wrapper for opencourse. It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three stages, dev, qa and prod. There are some scripts needed on the production server.
This project is also based on the varbase two repository structure, varbase and varbase-project. This is a good way to go since most updates to varbase don't need to be updated on a varbase based project. Those that do are included in varbase-project. There are also a lot less files to track in varbase-project than varbase itself. It provides an intelligent separation. But there is need for another wrapper for a varbase project, since scripts, cmi and private folders need to be excluded from standard access. Since a particular site based project needs to include site specific files which should be stored on a private repository for backup, there is one more layer needed. The only difference with this layer is the .gitignore file which includes folders needed on production. Welcome to Drupal 8 development. 

# Here is the structure explained in detail
VARBASE
This is where vardot works on all the details for the Drupal distribution of varbase.

VARBASE-PROJECT
This is where vardot provides a project wrapper for varbase which it uses its own way for creating a subdistribution. I use it differently by forking it and maintaining it as the upstream version. This allows me to merge changes for updates. The great advantage here is I don't need to merge the details since they are in varbase, only the 'macro' changes. Thanks Vardot. :)

OPENCOURSE
This is a fork of varbase-project which includes all the opencourse functionality. It can therefore be extended different ways. This is for all development work on the project itself. This means it can in incorporated into various different staging strategies.

OPENCOURSE-PROJECT
This is a particular staging strategy taking into account the new complexities (I'm looking at you composer and cmi) Drupal uses. While composer and cmi bring many advantages, they need to be managed properly so errors are properly dealt with and don't end up in production. These should be able to be automated for quicker error finding and prepartion for using tools like docker and travis. The opencourse-project provides a number of scripts that provides automated ways to move between stages dev, qa and prod and (still to be written) ways to revcover from mishaps. 

OCSITE
Opencourse-project is written for its own development. Anyone wanting to build on it will need to fork it and have it setup as the upstream version. There is then one set of changes for the gitignore so private and cmi are included. Database backup folders could also be included. Ocsite is your private site backup on github (or any git server?). 

While it appears complex, the structure provides clear separation between each of the layers, with improvements cascading through and the potential to automate these changes with automated tests and auto updates. It must be honestly taken into account that the time period between drupal security updates made available and incorporated on production is critical and the new drupal complexities means this can take time. Any serious update should not break current sites and a 'drush up drupal' should be enough, but I'm not silly enough to guarantee that. I don't know of any other tool that can provide the breadth of possibilities (Drupal framework and modules) I need in a dev environment while building on and incorporating other people's work (Vardot and maybe Opigno later). Drupal is going to be around for a long time and building on D8 should last awhile, this is particularly appealing, though it is yet to be seen that this is a wise choice. The cutting edge is usually the bleeding edge. But so far so good.

# Processes
The process is as follows:
1) dev2qa (opencourse push)
2) qa2prod (opencat push)
3) prod2qa (if qa pres, then just database, and pull opencat (in case others have updated it).
          (if qa not pres, then pull opencat).
4) qa2dev (if opencourse.git not present, then pull opencourse.git and setup).

#dev2qa
#Make changes to move from a dev to qa environment.
#This is the same folder with the same database, just some changes are made to setup.
#This presumes a single dev is able to work on dev and qa on his own, without a common qa server (for now).

#You would normally push opencourse to git before these steps.

#turn off dev settings

#turn off dev modules

#move opencourse git

#uninstall feature modules (leaves settings on site).

#Note database is the same between dev and qa in the forward direction.




#qa2prod
#Make changes to move from a dev to qa environment.
#This is the same folder with the same database, just some changes are made to setup.
#This presumes a single dev is able to work on dev and qa on his own, without a common qa server (for now).

#export cmi

#push opencat

#backup db

#pull db from prod

#cmi import

# test

#On prod:
# backup db
# maintenance mode
# pull opencat
# update/cmi import
# out of maintenance mode
# test again.



#prod2qa
#There should be NO changes to CMI on live. if there are, they will be in sql an
d therefore moved down with the database to qa, but could be overwritten with fe
ature import from dev to qa. 

# Files option: setup all the files as well.
# clone opencat.
#  opencourse non dev files are already included.
# set up database
# set up settings and settings.local

# On prod: export sql

# On qa: get sql

#       import sql




#qa2dev

# Need to check if there is an opencourse git or not.
# if not, then delete opencourse and clone a fresh opencourse and install (dev is default).

# install feature modules?

# move opencourse git to opencourse

# turn on dev modules (composer)

# turn on dev settings.


