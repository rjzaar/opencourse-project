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

pass: Working and passing Travis CI :heavy_check_mark:

works: Working but not yet integrated to Travis CI :white_check_mark:

todo: Has not been looked at yet :question:


# FUNCTION LIST

<details>
**<summary> pl addc :white_check_mark: </summary>**
Usage: pl addc [OPTION]
  This script is used to add github credentials

  Mandatory arguments to long options are mandatory for short options too.
    -h --help               Display help (Currently displayed)

  Examples:
  pl addc -h
<\details>
<details>
**<summary> pl backupdb :white_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--
[34mbackup --help [39m
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
<\details>
<details>
**<summary> pl backupprod :white_check_mark: </summary>**
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
<\details>
<details>
**<summary> pl backup :white_check_mark: </summary>**
Usage: pl backup [OPTION] ... [SOURCE]
This script is used to backup a particular site's files and database.
You just need to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -m --message='msg'      Enter an optional message to accompany the backup

Examples:
pl backup -h
pl backup dev
pl backup tim -m 'First tim backup'
pl backup --message='Love' love
END HELP
<\details>
<details>
**<summary> pl copy :white_check_mark: </summary>**
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
<\details>
<details>
**<summary> pl devpush :white_check_mark: </summary>**
Usage: pl devpush [OPTION]
Include help Rob!

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
<\details>
<details>
**<summary> pl enmod :white_check_mark: </summary>**
Usage: pl enmod [OPTION] ... [SITE] [MODULE]
This script will install a module first using composer, then fix the file/dir
ownership and then enable the module using drush automatically.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
<\details>
<details>
**<summary> pl fixp :white_check_mark: </summary>**
Usage: pl fixp [OPTION] ... [SOURCE]
This script is used to fix permissions of a Drupal site You just need to
state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
<\details>
<details>
**<summary> pl fixss :white_check_mark: </summary>**
Usage: pl fixss [OPTION] ... [SOURCE]
This will fix (or set) the site settings in local.settings.php You just need
to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
<\details>
<details>
**<summary> pl gcompushmaster :white_check_mark: </summary>**
Usage: pl gcompushmaster [OPTION] ... [SITE] [MESSAGE]
This will merge branch with master You just need to state the sitename, eg
dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
<\details>
<details>
**<summary> pl gcom :white_check_mark: </summary>**
--**BROKEN DOCUMENTATION**--
please type 'pl gcom --help' for more options
--**BROKEN DOCUMENTATION**--
<\details>
<details>
**<summary> pl gcomsh :white_check_mark: </summary>**
Usage: pl gcomsh [OPTION] ... [SITE] [MESSAGE]
This will git commit changes with msg after merging with master. You just
need to state the sitename, eg dev.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gcomsh -h
pl gcomsh dev (relative dev folder)
pl gcomsh tim 'First tim backup'
<\details>
<details>
**<summary> pl gcomup2upstream :white_check_mark: </summary>**
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
<\details>
<details>
**<summary> pl gcomup :white_check_mark: </summary>**
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
<\details>
<details>
**<summary> pl gulp :white_check_mark: </summary>**
Usage: pl gulp [OPTION] ... [SITE]
This script is used to set upl gulp browser sync for a particular page. You
just need to state the sitename, eg loc and the page, eg opencat.loc

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gulp 
END HELP
<\details>
<details>
**<summary> pl importdev :white_check_mark: </summary>**
Usage: pl gulp [OPTION] ... [SOURCE-SITE] [DEST-SITE]
@ROB add description please

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
pl gulp 
END HELP
<\details>
<details>
**<summary> pl init :white_check_mark: </summary>**
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
    sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath/bin" $user
    sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli \
    php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip
    php-xdebug -y
    sudo apt-get -y install mysql-server
    sudo apt-get install phpmyadmin -y
    php -r "copy(https://getcomposer.org/installer, composer-setup.php);"
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    curl https://drupalconsole.com/installer -L -o drupal.phar
    sudo apt install nodejs build-essential
    curl -L https://npmjs.com/install.sh | sh
    sudo apt install npm
    sudo npm install gulp-cli -g
    sudo npm install gulp -D
END OF HELP
<\details>
<details>
**<summary> pl installf :white_check_mark: </summary>**
Usage: pl installf [OPTION]
This script is used to install a variety of drupal flavours particularly
opencourse, but just the file system. No database.  This will use
opencourse-project as a wrapper. It is presumed you have already cloned
opencourse-project.  You just need to specify the site name as a single
argument.  All the settings for that site are in pl.yml If no site name is
given then the default site is created.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --default	          Use default Drupal flavour
  -f --from=[flavour]     Choose drupal flavour
  -y --yes                Auto Yes to all options

Examples:
END HELP
<\details>
<details>
**<summary> pl install :white_check_mark: </summary>**
Usage: pl install site [OPTION]
This script is used to install a variety of drupal flavours particularly
opencourse This will use opencourse-project as a wrapper. It is presumed you
have already cloned opencourse-project.  You just need to specify the site name
as a single argument.  All the settings for that site are in pl.yml If no site
name is given then the default site is created.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -y --yes                Auto Yes to all options
  -s --step=[INT]         Restart at the step specified.
  -b --build-step=[INT]   Restart the build at step specified (step=6)
  -d --debug              Provide debug information when running this script.
  -t --test            This option is only for test environments like Travis, eg there is no mysql root password.

Examples:
pl install d8
END HELP
<\details>
<details>
**<summary> pl main :white_check_mark: </summary>**
Usage: pl main [OPTION] ... [SITE] [MODULES]
This script will turn maintenance mode on or off. You will need to specify the
site first than on or off, eg pl main loc on

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
<\details>
<details>
**<summary> pl makedb :white_check_mark: </summary>**
Usage: pl makedb [OPTION] ... [SITE]
<ADD DESC HERE>

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
<\details>
<details>
**<summary> pl makedev :white_check_mark: </summary>**
Usage: pl makedev [OPTION] ... [SITE]
This script is used to turn on dev mode and enable dev modules.
You just need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
END HELP
<\details>
<details>
**<summary> pl makelpwp :white_check_mark: </summary>**
Usage: pl makepwp [OPTION] ... [SITE]
This script is used to overwrite localprod with the actual external production
site.  The choice of localprod is set in pl.yml under sites: localprod: The
external site details are also set in pl.yml under prod: Note: once localprod
has been locally backedup, then it can just be restored from there if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -s --step=[1-6]         Select step to proceed (For DEBUG purposes?)

Examples:
END HELP
<\details>
<details>
**<summary> pl makeprod :white_check_mark: </summary>**
Usage: pl makeprod [OPTION] ... [SITE]
This script is used to turn off dev mode and uninstall dev modules.  You just
need to state the sitename, eg stg.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
END HELP
<\details>
<details>
**<summary> pl olwprod :white_check_mark: </summary>**
Usage: pl olwprod [OPTION] ... [SITE]
This script is used to overwrite localprod with the actual external production
site.  The choice of localprod is set in pl.yml under sites: localprod: The
external site details are also set in pl.yml under prod: Note: once localprod
has been locally backedup, then it can just be restored from there if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
<\details>
<details>
**<summary> pl prodow :white_check_mark: </summary>**
Usage: pl prodow [OPTION] ... [SITE]
This script will overwrite production with the site chosen It will first backup
prod The external site details are also set in pl.yml under prod:

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
<\details>
<details>
**<summary> pl rebuild :white_check_mark: </summary>**
Usage: pl rebuild [OPTION] ... [SITE]
This script is used to rebuild a particular site's database. You just need to
state the sitename, eg loc.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
<\details>
<details>
**<summary> pl update :white_check_mark: </summary>**
Usage: pl update [OPTION]
This script will update the configs for all sites

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.

Examples:
<\details>
<details>
**<summary> pl copyf :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl _inc :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl open :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl reset :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl restoredb :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl restore :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl stg2prodoverwrite2 :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl stg2prodoverwrite :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl stg2prod :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl stopgulp :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl testim :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl testi :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl test :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl teststg :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl teststgupdb :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
<details>
**<summary> pl varup :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**
</details>
