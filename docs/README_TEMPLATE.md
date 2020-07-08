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

It provides various scripts for development processes which incorporate composer, cmi and backup. It includes three stages, dev (called loc for local), stg and prod. Communication with the production server is via drush and scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.
It provides an intelligent separation.

Since a particular site based project needs to include site specific files which should be stored on a private repository for backup, there is one more layer needed.
The only difference with this layer is the .gitignore file which includes folders needed on production. Welcome to Drupal 8 development.

Status codes

pass: Working and passing Travis CI :white_check_mark:

works: Working but not yet integrated to Travis CI :heavy_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

