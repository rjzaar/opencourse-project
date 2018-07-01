# opencourse-project

This project is a folder wrapper for opencourse. It provides various scripts. TBC


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


