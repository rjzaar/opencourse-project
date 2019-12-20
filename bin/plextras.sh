#!/bin/bash
ocroot="/home/rob/opencat"
ocwroot="/var/www/oc"
script_root="/home/rob/opencat/scripts"
#Don't touch the above lines it will be modified by init.sh

# This will help navigate around the project site
function plcd () {

ocroots=$ocroot/scripts



if [ $# = 0 ]
then
cd $ocroot
else
. $script_root/_inc.sh;
parse_pl_yml
sn=$1
import_site_config $sn

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
    cd $ocwroot/oc
    ;;
    *)
    cd $site_path/$sn
    ;;
  esac

else
  case  $2  in
    d)
    if [ -d $site_path/$sn/$webroot ] ; then cd $site_path/$sn/$webroot
    else echo "webroot directory for $sn can't be found"
    fi
    ;;
    b)
    cd $ocroot/sitebackups/$sn
    ;;
    sd)
    if [ -d $site_path/$sn/$webroot ] ; then cd $site_path/$sn/$webroot/sites/default
    else echo "sites/default directory for $sn can't be found"
    fi
    ;;
    t)
    cd $site_path/$sn/$webroot/themes/custom/$theme
    ;;
    *)
    cd $ocroot/$sn/$2
    ;;
  esac

#if [[ $2 -eq "d" ]]
#then
#cd $ocroot/$sn/docroot
#else
#cd $ocroot/$sn/$2
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
    sn=$1
    ;;
  esac
else
  sn=$1
  case  $2  in
    a)
    vi /etc/apache2/sites-available/$ocroot.$sn.conf
    ;;
    s)
    if [ -f $site_path/$sn/docroot/sites/default/settings.php ] ; then vi $site_path/$sn/docroot/sites/default/settings.php
    else if [ -f $site_path/$sn/html/sites/default/settings.php ] ; then vi $site_path/$sn/html/sites/default/settings.php
    else if [ -f $site_path/$sn/web/sites/default/settings.php ] ; then vi $site_path/$sn/web/sites/default/settings.php
#    else if [ -f $ocwroot/$sn/docroot/sites/default/settings.php ] ; then vi $ocwroot/$sn/docroot/sites/default/settings.php
#    else if [ -f $ocwroot/$sn/html/sites/default/settings.php ] ; then vi $ocwroot/$sn/html/sites/default/settings.php
#    else if [ -f $ocwroot/$sn/web/sites/default/settings.php ] ; then vi $ocwroot/$sn/web/sites/default/settings.php
    else echo "sites/default directory for $sn can't be found"
    fi
#    fi
#    fi
#    fi
    fi
    fi
    ;;
    sl)
    if [ -f $site_path/$sn/docroot/sites/default/settings.local.php ] ; then vi $site_path/$sn/docroot/sites/default/settings.local.php
    else if [ -f $site_path/$sn/html/sites/default/settings.local.php ] ; then vi $site_path/$sn/html/sites/default/settings.local.php
    else if [ -f $site_path/$sn/web/sites/default/settings.local.php ] ; then vi $site_path/$sn/web/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sn/docroot/sites/default/settings.local.php ] ; then vi $ocwroot/$sn/docroot/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sn/html/sites/default/settings.local.php ] ; then vi $ocwroot/$sn/html/sites/default/settings.local.php
#    else if [ -f $ocwroot/$sn/web/sites/default/settings.local.php ] ; then vi $ocwroot/$sn/web/sites/default/settings.local.php
    else echo "sites/default directory for $sn can't be found"
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
#cd $ocroot/$sn/docroot
#else
#cd $ocroot/$sn/$2
#fi
fi
fi

}

function plsource () {
source ~/.bashrc
}

function addc () {
ssh-add ~/.ssh/github
}

