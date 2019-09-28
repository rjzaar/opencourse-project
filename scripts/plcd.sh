#!/bin/bash
ocroot="/home/rob/opencat"
#ocroot="~/opencourse"

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
    cd /etc/apache/sites-available
    ;;
    b)
    cd $ocroot/sitebackups
    ;;
    s)
    cd $ocroot/scripts
    ;;
    d)
    cd $ocroot/../.drush
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

function plsource () {
source ~/.bashrc
}
