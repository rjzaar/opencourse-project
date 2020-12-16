#!/bin/bash

# This includes any environment specific variables. These are auto generated from pl.yml and the environment.
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
 . $(dirname $DIR)/pl_var.sh

# This will help navigate around the project site
function plcd () {

ocroots=$ocroot/scripts



if [ $# = 0 ]
then
cd $ocroot
else
sitename_var=$1
. $script_root/_inc.sh;

parse_pl_yml
#echo "webroot $webroot"
import_site_config $sitename_var
#echo "webroot $webroot"
if [[ $# -eq 1 ]]
then
  case  $1  in
    a)
    cd /etc/apache2/sites-available
    ;;
    b)
    cd $ocroot/sitebackups
    ;;
    c)
    cd $ocroot/../.composer
    ;;
    d)
    cd $ocroot/../.drush
    ;;
    dc)
    cd $ocroot/../.console
    ;;
    dcs)
    cd $ocroot/../.console/sites
    ;;
    l)
    cd /usr/local/bin
    ;;
    s)
    cd $ocroot/scripts
    ;;
    w)
    cd $ocwroot/
    ;;
    *)
    cd $site_path/$sitename_var
    ;;
  esac

else
  case  $2  in
    d)
    if [ -d $site_path/$sitename_var/$webroot ] ; then cd $site_path/$sitename_var/$webroot
    else echo "webroot directory for sitepath: $site_path sitename_var: $sitename_var webroot $webroot can't be found"
    fi
    ;;
    b)
    cd $ocroot/sitebackups/$sitename_var
    ;;
    sd)
    if [ -d $site_path/$sitename_var/$webroot ] ; then cd $site_path/$sitename_var/$webroot/sites/default
    else echo "sites/default directory for $sitename_var can't be found"
    fi
    ;;
    t)
    cd $site_path/$sitename_var/$webroot/themes/custom/$theme
    ;;
    *)
    cd $ocroot/$sitename_var/$2
    ;;
  esac

#if [[ $2 -eq "d" ]]
#then
#cd $ocroot/$sitename_var/docroot
#else
#cd $ocroot/$sitename_var/$2
#fi
fi
fi

}

function plvi () {

ocroots=$ocroot/scripts
#. $ocroots/_inc.sh;
if [ $# = 0 ]
then
echo "You have not provided a file to edit"
else
if [[ $# -eq 1 ]]
then
  case  $1  in
    a)
    echo "Add apache config file here to this function ..."
    ;;
    c)
    vi $ocroot/../.composer/composer.json
    ;;
    d)
    echo "Work out how to open the first alias file"
    ;;
    dc)
    vi $ocroot/../.console/config.yml
    ;;
    dcs)
    echo "Work out how to open the first yml file"
    ;;
    s)
    cd $ocroot/scripts
    ;;
    *)
    sitename_var=$1
    ;;
  esac
else
  sitename_var=$1
  case  $2  in
    a)
    vi /etc/apache2/sites-available/$ocroot.$sitename_var.conf
    ;;
    s)
    if [ -f $site_path/$sitename_var/docroot/sites/default/settings.php ] ; then vi $site_path/$sitename_var/docroot/sites/default/settings.php
    else if [ -f $site_path/$sitename_var/html/sites/default/settings.php ] ; then vi $site_path/$sitename_var/html/sites/default/settings.php
    else if [ -f $site_path/$sitename_var/web/sites/default/settings.php ] ; then vi $site_path/$sitename_var/web/sites/default/settings.php
#    else if [ -f $ocwroot/$sitename_var/docroot/sites/default/settings.php ] ; then vi $ocwroot/$sitename_var/docroot/sites/default/settings.php
#    else if [ -f $ocwroot/$sitename_var/html/sites/default/settings.php ] ; then vi $ocwroot/$sitename_var/html/sites/default/settings.php
#    else if [ -f $ocwroot/$sitename_var/web/sites/default/settings.php ] ; then vi $ocwroot/$sitename_var/web/sites/default/settings.php
    else echo "sites/default directory for $sitename_var can't be found"
    fi
#    fi
#    fi
#    fi
    fi
    fi
    ;;
    sl)
    if [ -f $site_path/$sitename_var/docroot/sites/default/settings.local.php ] ; then vi $site_path/$sitename_var/docroot/sites/default/settings.local.php
    else if [ -f $site_path/$sitename_var/html/sites/default/settings.local.php ] ; then vi $site_path/$sitename_var/html/sites/default/settings.local.php
    else if [ -f $site_path/$sitename_var/web/sites/default/settings.local.php ] ; then vi $site_path/$sitename_var/web/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sitename_var/docroot/sites/default/settings.local.php ] ; then vi $ocwroot/$sitename_var/docroot/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sitename_var/html/sites/default/settings.local.php ] ; then vi $ocwroot/$sitename_var/html/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sitename_var/web/sites/default/settings.local.php ] ; then vi $ocwroot/$sitename_var/web/sites/default/settings.local.php
    else echo "sites/default directory for $sitename_var can't be found"
    fi
#    fi
#    fi
#    fi
    fi
    fi
    ;;
    *)
    echo "Sorry I don't know what you want me to edit."
    ;;
  esac

#if [[ $2 -eq "d" ]]
#then
#cd $ocroot/$sitename_var/docroot
#else
#cd $ocroot/$sitename_var/$2
#fi
fi
fi

}

function plsource () {
source ~/.bashrc
}

function addc () {
if [ -f ~/.ssh/github ]; then
    ssh-add ~/.ssh/github
else
    echo "could not add git credentials, recommended to create github credentials in .ssh folder"
fi
}

