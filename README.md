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

Status codes

pass: Working and passing Travis CI :heavy_check_mark:

works: Working but not yet integrated to Travis CI :white_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

<details>

**<summary>addc: Usage: pl addc [OPTION] :question: </summary>**
--**BROKEN DOCUMENTATION**--
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc -h
--**BROKEN DOCUMENTATION**--

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

**<summary>backupprod: Backs up the production site :question: </summary>**
Usage: pl backup [OPTION] ... [SOURCE]
  This script is used to backup prod site's files and database. You can
  add an optional message.

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)
    -m --message='msg'      Enter a message to accompany the backup (IS THIS
                            OPTIONAL ROB?)

  Examples:
  pl backupprod -h
  pl backupprod ./tim -m 'First tim backup'

</details>

<details>

**<summary>backup: Backup site and database :heavy_check_mark: </summary>**
Usage: pl backup [OPTION] ... [SOURCE] [MESSAGE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev and an optional message.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl backup -h
pl backup dev
pl backup tim 'First tim backup'
END HELP

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

**<summary>devpush: Usage: pl devpush [OPTION] :question: </summary>**
--**BROKEN DOCUMENTATION**--
Include help Rob!

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
--**BROKEN DOCUMENTATION**--

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

**<summary>gcompushmaster: Git merge branch with master and push :question: </summary>**
Usage: pl gcompushmaster [OPTION] ... [SITE] [MESSAGE]
This will merge branch with master You just need to state the sitename, eg
dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:

</details>

<details>

**<summary>gcom: args:  --help -- :question: </summary>**
--**BROKEN DOCUMENTATION**--
Git commit code with optional backup
Usage: pl gcom [SITE] [MESSAGE] [OPTION]
This script will git commit changes to [SITE] with [MESSAGE].\
If you have access rights, you can commit changes to pleasy itself by using pl for [SITE].

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

**<summary>gcomsh: Git push after master merge :question: </summary>**
Usage: pl gcomsh [OPTION] ... [SITE] [MESSAGE]
This will git commit changes with msg after merging with master. You just
need to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gcomsh -h
pl gcomsh dev (relative dev folder)
pl gcomsh tim 'First tim backup'

</details>

<details>

**<summary>gcomup2upstream: Git commit with upstream merge :question: </summary>**
Usage: pl gcomup2upstream [OPTION] ... [SITE] [MESSAGE]
This will merge branch with master, and update to the upstream git. It
presupposes you have already merged. You just need to state the sitename, eg
dev.
                                    branch with master
Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gcomup2upstream -h
pl gcomup2upstream dev (relative dev folder)
pl gcomup2upstream tim 'First tim backup'
END HELP

</details>

<details>

**<summary>gcomup: Git commit and backup :question: </summary>**
Usage: pl gcomup [OPTION] ... [SITE] [MESSAGE]
Composer update, git commit changes and backup. This script follows the
correct path to git commit changes You just need to state the
sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gcomup -h
pl gcomup dev (relative dev folder)
pl gcomup tim 'First tim backup'
END HELP

</details>

<details>

**<summary>gulp: Turn on gulp :question: </summary>**
Usage: pl gulp [OPTION] ... [SITE]
This script is used to set upl gulp browser sync for a particular page. You
just need to state the sitename, eg loc and the page, eg opencat.loc

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gulp
END HELP

</details>

<details>

**<summary>importdev: Copy localprod to stg, then import dev to stg :question: </summary>**
Usage: pl importdev [OPTION] ... [SOURCE-SITE] [DEST-SITE]
@ROB add description please

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl importdev 
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
END HELP

</details>

<details>

**<summary>main: Turn maintenance mode on or off :question: </summary>**
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

**<summary>makedb: Create the database for a site :question: </summary>**
Usage: pl makedb [OPTION] ... [SITE]
<ADD DESC HERE>

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

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

**<summary>makelpwp: Overwrite localprod with production :white_check_mark: </summary>**
Usage: pl makelpwp [OPTION] ... [SITE]
This script is used to overwrite localprod with the actual external production
site.  The choice of localprod is set in pl.yml under sites: localprod: The
external site details are also set in pl.yml under prod: Note: once localprod
has been locally backedup, then it can just be restored from there if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-6]         Select step to proceed (For DEBUG purposes?)

Examples:
pl makelpwp
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

**<summary>prodow: Overwrite production with site specified :question: </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
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

**<summary>restore: args:  --help -- :heavy_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--
Restore a particular site's files and database from backup
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.

OPTIONS
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -f --first              Usse the latest backup
  -y --yes                Auto delete current content

Examples:
pl restore loc
pl restore loc stg -fy
pl restore -h
pl restore loc -d
--**BROKEN DOCUMENTATION**--

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

**<summary>copyf:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>_inc:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>open:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>reset:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>restoredb:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>stg2prodoverwrite2:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>stg2prodoverwrite:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>stg2prod:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>stopgulp:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>testim:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>testi:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>test:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>teststg:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>teststgupdb:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

<details>

**<summary>varup:  :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

