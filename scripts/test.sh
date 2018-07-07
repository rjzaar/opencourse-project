#!/usr/bin/env bash
dbuser="vbn"
dbpass="vbp"
folder="folder"
#db="vb"
nodown="n"

    if [ "$nodown" = "a" ]
    then
    echo "no $nodown"
    else
    echo "yes"
    fi



#echo "db $db dbuser $dbuser dbpass $dbpass"
#
#RESULT=`mysqlshow --user=$dbuser --password=$dbpass $db| grep -v Wildcard | grep -o $db`
#if [ "$RESULT" == "$db" ]; then
#    echo "yes"
#    else
#    echo "No"
#fi

# ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob