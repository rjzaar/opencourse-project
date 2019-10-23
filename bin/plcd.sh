#!/bin/bash
ocroot="/home/rob/opencat"
#Don't touch the above line it will be modified by init.sh

# This will help navigate around the project site
function plcd () {

ocroots=$ocroot/scripts
#. $ocroots/_inc.sh;
if [ $# = 0 ]
then
cd $ocroot
else
sn=$1
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
    s)
    cd $ocroot/scripts
    ;;
    *)
    cd $ocroot/$sn
    ;;
  esac
else
  case  $2  in
    d)
    if [ -d $ocroot/$sn/docroot ] ; then cd $ocroot/$sn/docroot
    else if [ -d $ocroot/$sn/html ] ; then cd $ocroot/$sn/html
    else if [ -d $ocroot/$sn/web ] ; then cd $ocroot/$sn/web
    else "webroot directory for $sn can't be found"
    fi
    fi
    fi
    ;;
    b)
    cd $ocroot/sitebackups/$sn
    ;;
    sd)
    if [ -d $ocroot/$sn/docroot ] ; then cd $ocroot/$sn/docroot/sites/default
    else if [ -d $ocroot/$sn/html ] ; then cd $ocroot/$sn/html/sites/default
    else if [ -d $ocroot/$sn/web ] ; then cd $ocroot/$sn/web/sites/default
    else "sites/default directory for $sn can't be found"
    fi
    fi
    fi
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
    if [ -f $ocroot/$sn/docroot/sites/default/settings.php ] ; then vi $ocroot/$sn/docroot/sites/default/settings.php
    else if [ -f $ocroot/$sn/html/sites/default/settings.php ] ; then vi $ocroot/$sn/html/sites/default/settings.php
    else if [ -f $ocroot/$sn/web/sites/default/settings.php ] ; then vi $ocroot/$sn/web/sites/default/settings.php
    else "sites/default directory for $sn can't be found"
    fi
    fi
    fi
    ;;
    sl)
    if [ -f $ocroot/$sn/docroot/sites/default/settings.local.php ] ; then vi $ocroot/$sn/docroot/sites/default/settings.local.php
    else if [ -f $ocroot/$sn/html/sites/default/settings.local.php ] ; then vi $ocroot/$sn/html/sites/default/settings.local.php
    else if [ -f $ocroot/$sn/web/sites/default/settings.local.php ] ; then vi $ocroot/$sn/web/sites/default/settings.local.php
    else "sites/default directory for $sn can't be found"
    fi
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
