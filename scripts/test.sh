#!/usr/bin/env bash
dbuser="vbn"
dbpass="vbp"
folder="folder"
#db="vb"


if [ -z ${db+x} ]
then
    db=$folder
fi
if [ -z ${dbuser+x}]
then
    dbuser=$db
fi
if [ -z ${dbpass+x} ]
then
    dbpass=$dbuser
fi
echo "db $db dbuser $dbuser dbpass $dbpass"

RESULT=`mysqlshow --user=$dbuser --password=$dbpass $db| grep -v Wildcard | grep -o $db`
if [ "$RESULT" == "$db" ]; then
    echo "yes"
    else
    echo "No"
fi

# ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob