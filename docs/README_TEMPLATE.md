# Pleasy

[![Build Status](https://travis-ci.com/rjzaar/pleasy.svg?branch=master)](https://travis-ci.com/rjzaar/pleasy)

This is a Devops framework for drupal sites, particularly based on varbase.
The framework is run through the pl (short for please), plcd and plvi commands.
The pl command has been added to bash commands so can be accessed anywhere. It is followed by the script name and usually which instance to be worked on, eg "pl backup stg" will backup the stage instance.
There is a yaml file which contains the framework setup. An example yaml file is provided and is ready to be used, with some tweaking required.
You set it up with the following commands

```
git clone git@github.com:rjzaar/pleasy.git 
bash ./pleasy/bin/pl  init
source ~/.bashrc
pl update
```
Now edit pl.yml with your settings or just use the defaults

You will now have a functioning pleasy.

You should now be able to install your first site:
```
pl install d8
```
OR if you want to install the varbase distribution
```
pl install var
```

# Config: pl.yml

The main configuration is in a single file called pl.yml. This is created from the example.pl.yml file. pl.yml needs
to be edited to suit the current user, eg setting github credentials. But it has enough information to be useable 
out of the box. The following site information is ready to go

d8: Drupal 8 install

d8c: Drupal 8 composer install

varg: varbase-project install using git

vard: dev varbase-project install using composer

varc: varbase-project install using composer 

# VARBASE

It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three 
stages, dev (called loc for local), stg and prod. Communication with the production server is via drush and scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.
It provides an intelligent separation.

Since a particular site based project needs to include site specific files which should be stored on a private 
repository for backup, there is one more layer needed. The only difference with this layer is the .gitignore file 
which includes folders needed on production. Welcome to Drupal 8 development.

# WORKFLOW

Git is the fastest and easiest way to move files. There are three repositories

Opencourse (ocrepo): A repo for just the code for opencourse.

Production site repo (prodrepo): A repo of all of the site files.

Production database repo (prod.sql): A private secure repo for the live database.

Prodrepo is needed as a complete site backup (except for settings.php and some other files). It has it's own 
.prodgitignore. The two repos can be swapped in the same folder so only one is used at a time (the two ignore files are
also swapped and also ignore the repos). 

1) (Dev) Dev work is normally done on loc with ocrepo. The loc .git is pushed. 
2) (Testing)
 
    a) The prodrepo is cloned to stg and installed with proddb. There are two scripts on production gitbackupdb.sh and 
    gitbackupfiles.sh which can be run in parallel to speed things up.
    
    b) The git is then swapped in stg (.git to .gitprod and .git from loc copied in, .gitignore to 
.prodgitignore and .devgitignore copied in). 

    c) On stg a git fetch origin and hard reset will modify all relevant files to the new ones. 
    ```
    git fetch origin
    git reset --hard origin/master
    ```
    d) The .git is then moved to .devgit and .prodgit is moved to .git (as well as the relevant .gitignore files)
3) The necessary updates are run to make sure everything updates correctly (composer install, drush updb, etc). 
4) Once this process is complete and everything is working the changes are pushed to a new branch on prodgit. 

If production is overwritten with stg, then the database is moved to prod and both files and db are installed. 

Otherwise:
1) The production site is backed up. An alternate site is created with no edits allowed. The url points to this site.
2) The files are brought in via a branch checkout on production. 
3) The database is updated.
4) Check if the update has worked

    a) If all is good, the site is made live, ie the url points to it.
    
    b) If there is a problem, git master is checked out and the backup database is restored. The url then points back
    to the main production site.

5) Once it is live and all is well a merge on production using the 'theirs' option brings the new files into the master of
prodrepo.

The advantage of this is there are two repos for their specific purposes. Having a master and dev branch on proddb allows
for easy changing over of files for a restore.

Status codes

pass: Working and passing Travis CI :white_check_mark:

works: Working but not yet integrated to Travis CI :heavy_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

