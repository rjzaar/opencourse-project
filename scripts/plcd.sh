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
    *)
    cd $ocroot/$sn
    ;;
  esac
else
  case  $2  in
    d)
    cd $ocroot/$sn/docroot
    ;;
    b)
    cd $ocroot/sitebackups/$sn
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
