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
stages, dev (called loc for local), stg and prod. Communication with the production server is via drush and git or scp.
This project is also based on the varbase two repository structure, varbase and varbase-project.
This is a good way to go since most updates to varbase don't need to be updated on a varbase based project.
Those that do are included in varbase-project.
There are also a lot less files to track in varbase-project than varbase itself.
It provides an intelligent separation.

A particular site based project needs to include site specific files which should be stored on a private 
repository for backup. When moving from dev to prod the git repositories will be swapped.

# WORKFLOW

Git is the fastest and easiest way to move files. There are three repositories

Opencourse (ocrepo): A repo for just the code for opencourse (dev environment)

Production site repo (prodrepo): A repo of all of the site files (prod environment) Master branch stores prod. Dev
branch stores the new prod to be pushed up.

Production database repo (prod.sql): A private secure repo for the live database (ocback).

The suggest best way to run workflow is explained in this presentation: 
https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
  at 29:36
  
This has been implemented with the following commands
Merge dev into master (or other branch)
```
pl gcom #will export config and commit to git
git pull # Check the pull works.
git merge master
pl runup #will run any updates. Check all is good.
git checkout master 
git merge dev #check for errors.
git push
git checkout dev # back to work
```
Process to push to production
```
pl proddown stg #copy prod to stg
pl gcom loc
pl dev2stg loc #will use git to move dev files to stg. stg has prodrepo.
pl runup stg #run updates on stage and check site.
```
You can repeat these steps to set up the live test site on the production server

```
pl updatetest
```
And/or you can run them on the live production server.
```
pl updateprod # This repeats the steps on Prod. Check all is well.
```
If there is a problem on production.

```
pl restoreprod  #This restores Prod to the old site. Only if needed.
```
 
# PLEASY RATIONALE

What makes pleasy different? Pleasy is trying to use the simplest tools (bash scripting) to leverage drupal and varbase tools 
to provide the simplest and yet powerful devops environment. This way it is easy for beginners to adopt and even improve, yet
powerful enough to use for production. It tries to take the suggested best practice from Drupal documentation and turn it into
scripts. It hopes to grow into a complete devops solution incorporating the best tools and practices available. 

# ROADMAP

1) The varbase use of Phing to install the site needs to be integrated into pleasy.

2) The varbase script varbase-update.sh needs to be integrated into pleasy.

3) A server version needs to be developed.

4) All the remaining scripts (ie with status todo) need to be updated and integrated.

5) All scripts tested with travis

6) This will become a 1.0 release

7) Lando integrated into pleasy using https://github.com/pendashteh/landrop. This will be a 2.0 release

8) New functions to set up site testing using varbase behat code.

9) Automatical travis testing of any commits.

10) These new functions to set up travis tests that respond to drupal core security updates automatically and if passing auto push to production.

11) New update functions to set up travis tests that respond to varbase project updates, test automatically and create stage site which is tested automatically. One line code push to production.

Other improvements: nginx as an option. Varnish as an option. Incorporate https://github.com/drevops/drevops



Status codes

pass: Working and passing Travis CI :white_check_mark:

works: Working but not yet integrated to Travis CI :heavy_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

(Click on the arrow to expand the function help.)


<details>

**<summary>addc: Add github credentials :white_check_mark: </summary>**
Usage: pl addc [OPTION]
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc 

</details>

<details>

**<summary>backupdb: [34mbackup --help [39m :question: </summary>**
--**BROKEN DOCUMENTATION**--
Backs up the database only
    Usage: pl backupdb [OPTION] ... [SOURCE]
  This script is used to backup a particular site's database.
  You just need to state the sitename, eg dev.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
    -m --message='msg'      Enter an optional message to accompany the backup

  Examples:
  pl backupdb -h
  pl backupdb dev
  pl backupdb tim -m 'First tim backup'
  pl backupdb --message='Love' love
  END HELP
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>backup: Backup site and database :heavy_check_mark: </summary>**
Usage: pl backup [OPTION] ... [SOURCE] [MESSAGE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev and an optional message.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -g --git                Also create a git backup of site.

Examples:
pl backup -h
pl backup dev
pl backup tim 'First tim backup'
END HELP

</details>

<details>

**<summary>copyf: Copies only the files from one site to another :white_check_mark: </summary>**
Usage: pl copyf [OPTION] ... [SOURCE]
This script will copy one site to another site. It will copy only the files
but will set up the site settings. If no argument is given, it will copy dev
to stg If one argument is given it will copy dev to the site specified If two
arguments are give it will copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:

</details>

<details>

**<summary>copypt: Copy the production site to the test site. :white_check_mark: </summary>**
Usage: pl copypt [OPTION]
  This script is used to copy the production site to the test site. The site
  details are in pl.yml.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl copypt 

</details>

<details>

**<summary>copy: Copies one site to another site. :heavy_check_mark: </summary>**
    Usage: pl copy [OPTION] ... [SOURCE] [DESTINATION]
This script will copy one site to another site. It will copy all
files, set up the site settings and import the database. If no
argument is given, it will copy dev to stg. If one argument is given it
will copy dev to the site specified. If two arguments are give it will
copy the first to the second.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:

</details>

<details>

**<summary>dev2stg: Uses git to update a stage site with the dev files. :white_check_mark: </summary>**
Usage: pl dev2stg [OPTION] ... [SOURCE]
This script will use git to update the files from dev repo (ocdev) on the stage
site dev to stg. If one argument is given it will copy dev to the site
specified. If two arguments are give it will copy the first to the second.
Presumes the dev git has already been pushed. Git is used for this rather than
simple file transfer so it follows the requirements in .gitignore.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:

</details>

<details>

**<summary>enmod: Usage: pl enmod [OPTION] ... [SITE] [MODULE] :question: </summary>**
--**BROKEN DOCUMENTATION**--
This script will install a module first using composer, then fix the file/dir
ownership and then enable the module using drush automatically.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>fixp: Usage: pl fixp [OPTION] ... [SOURCE] :white_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--
This script is used to fix permissions of a Drupal site You just need to
state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>fixss: Usage: pl fixss [OPTION] ... [SOURCE] :white_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--
This will fix (or set) the site settings in local.settings.php You just need
to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>gcom: args:  --help -- :question: </summary>**
--**BROKEN DOCUMENTATION**--
Git commit code with optional backup
Usage: pl gcom [SITE] [MESSAGE] [OPTION]
This script will export config and git commit changes to [SITE] with [MESSAGE].\
If you have access rights, you can commit changes to pleasy itself by using pl
for [SITE] or pleasy.

OPTIONS
  -h --help               Display help (Currently displayed)
  -b --backup             Backup site after commit
  -v --verbose            Provide messages of what is happening
  -d --debug              Provide messages to help with debugging this function

Examples:
pl gcom loc "Fixed error on blah." -bv\
pl gcom pl "Improved gcom."
--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>gcomvup: Git commit and update to latest varbase stable :question: </summary>**
Usage: pl gcomvup [OPTION] ... [SITE] [MESSAGE]
Varbase update, git commit changes and backup. This script follows the
correct path to git commit changes You just need to state the
sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gcomvup -h
pl gcomvup dev (relative dev folder)
pl gcomvup tim 'First tim backup'
END HELP

</details>

<details>

**<summary>gulp: Turn on gulp :white_check_mark: </summary>**
Usage: pl gulp [OPTION] ... [SITE] [URL]
This script is used to set up gulp browser sync for a particular page. You
just need to state the sitename and optionally a particular page
, eg loc and http://pleasy.loc/sar

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gulp loc
pl gulp loc http://pleasy.loc/sar

END HELP

</details>

<details>

**<summary>info: Information on site(s) :heavy_check_mark: </summary>**
Usage: pl info [SITE] [TYPE] [OPTION]
This script is used to provide various information about a site.
You just need to state the sitename, eg dev and optionally the type of information

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl info -h
pl info dev
END HELP

</details>

<details>

**<summary>init: Initialises pleasy :heavy_check_mark: </summary>**
  Usage: pl init [OPTION]
This will set up pleasy and initialise the sites as per
pl.yml, including the current production shared database.
This will install many programs, which will be listed at
the end.

Mandatory arguments to long options are mandatory for short options too.
    -y --yes                Force all install options to yes (Recommended)
    -h --help               Display help (Currently displayed)
    -s --step={1,15}        FOR DEBUG USE, start at step number as seen in code
    -n --nopassword         Nopassword. This will give the user full sudo access without requireing a password!
                            This could be a security issue for some setups. Use with caution!
    -t --test            This option is only for test environments like Travis, eg there is no mysql root password.
    -l --lando              This will install lando

Examples:
git clone git@github.com:rjzaar/pleasy.git [sitename]  #eg git clone git@github.com:rjzaar/pleasy.git mysite.org
bash ./pleasy/bin/pl  init # or if using [sitename]
bash ./[sitename]/bin/pl init

then if debugging:

bash ./[sitename]/bin/pl init -s=6  # to start at step 6.

INSTALL LIST:
    sudo apt-get install gawk
    sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath\/bin" $user
    sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli \
    php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip
    php-xdebug -y
    sudo apt-get -y install mysql-server
    sudo apt-get install phpmyadmin -y
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    curl https://drupalconsole.com/installer -L -o drupal.phar
    sudo apt install nodejs build-essential
    curl -L https://npmjs.com/install.sh | sh
    sudo apt install npm
    sudo npm install gulp-cli -g
    sudo npm install gulp -D
END OF HELP

</details>

<details>

**<summary>install: Installs a drupal site :heavy_check_mark: </summary>**
Usage: pl install site [OPTION]
This script is used to install a variety of drupal flavours particularly
opencourse This will use opencourse-project as a wrapper. It is presumed you
have already cloned opencourse-project.  You just need to specify the site name
as a single argument.  All the settings for that site are in pl.yml If no site
name is given then the default site is created.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -f --files              Only install site files. No database
  -s --step=[INT]         Restart at the step specified.
  -b --build-step=[INT]   Restart the build at step specified (step=6)
  -d --debug              Provide debug information when running this script.
  -t --test            This option is only for test environments like Travis, eg there is no mysql root password.

Examples:
pl install d8
pl install ins -b=6 #To start from installing the modules.
pl install loc -s=3 #start from composer install
END HELP

</details>

<details>

**<summary>main: Turn maintenance mode on or off :white_check_mark: </summary>**
Usage: pl main [OPTION] ... [SITE] [MODULES]
This script will turn maintenance mode on or off. You will need to specify the
site first than on or off, eg pl main loc on

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl main loc on
pl main dev off
END HELP

</details>

<details>

**<summary>makedb: Create the database for a site :white_check_mark: </summary>**
Usage: pl makedb [OPTION] ... [SITE]
<ADD DESC HERE>

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide messages to help with debugging this function

Examples:
END HELP

</details>

<details>

**<summary>makedev: Turn dev mode on for a site :heavy_check_mark: </summary>**
Usage: pl makedev [OPTION] ... [SITE]
This script is used to turn on dev mode and enable dev modules.
You just need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
pl makedev loc
END HELP

</details>

<details>

**<summary>makeprod: Turn production mode on and remove dev modules :heavy_check_mark: </summary>**
Usage: pl makeprod [OPTION] ... [SITE]
This script is used to turn off dev mode and uninstall dev modules.  You just
need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
END HELP

</details>

<details>

**<summary>proddown: Overwrite a specified local site with production :white_check_mark: </summary>**
Usage: pl proddown [OPTION] ... [SITE]
This script is used to overwrite a local site with the actual external production
site. If no site specified, localprod will be used. The external site details are also set in pl.yml under prod: Note: once
the local site has been locally backedup, then it can just be restored from there
if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-2]         Select step to proceed (If it stalls on a step)
  -d --debug              Provide messages to help with debugging this function


Examples:
pl proddown stg
pl proddown stg -s=2
pl proddown
END HELP

</details>

<details>

**<summary>prodowgit: Overwrite production with site specified :question: </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.

Examples:
pl prodow stg
END HELP

</details>

<details>

**<summary>prodowtar: Overwrite production with site specified :question: </summary>**
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

</details>

<details>

**<summary>prodstat: Production status :white_check_mark: </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will provide the status of the production site

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl prodstat
END HELP

</details>

<details>

**<summary>rebuild: Rebuild a site's database :question: </summary>**
Usage: pl rebuild [OPTION] ... [SITE]
This script is used to rebuild a particular site's database. You just need to
state the sitename, eg loc.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP

</details>

<details>

**<summary>restore: Restore a particular site's files and database from backup :heavy_check_mark: </summary>**
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.
If the [FROM] site is prod, and the production method is git, git will be used to restore production

OPTIONS
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -f --first              Use the latest backup
  -y --yes                Auto delete current content

Examples:
pl restore loc
pl restore loc stg -fy
pl restore -h
pl restore loc -d
pl restore prod stg

</details>

<details>

**<summary>runup: This script will run any updates on the stg site or the site specified. :question: </summary>**
Usage: pl runupdates [OPTION] ... [SOURCE]
This script presumes the files including composer.json have been updated in some way and will now run those updates.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl runup loc

</details>

<details>

**<summary>stopgulp: This script is used to kill any processes started by gulp. There are no arguments required. :white_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--

--**BROKEN DOCUMENTATION**--

</details>

<details>

**<summary>updateprod: Update Production (or test) server with stg or specified site. :question: </summary>**
Usage: pl updateprod [OPTION] ... [SITE] [MESSAGE]
This will copy stg or site specified to the production (or test) server and run
the updates on that server. It will also backup the server. It presumes the server
has git which will be used to restore the server if there was a problem.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -t --test               Update the test server not production.

Examples:
pl updateprod # This will use the site specified in pl.yml by sites: stg:
pl updateprod d8 # This will update production with the d8 site.
pl updateprod d8 -t # This will update the test site specified in pl.yml with the d8 site.

</details>

<details>

**<summary>update: Update all site configs :heavy_check_mark: </summary>**
Usage: pl update [OPTION]
This script will update the configs for all sites

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:

</details>

<details>

**<summary>open:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>restoredb:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>testim:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>test:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>varup:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

