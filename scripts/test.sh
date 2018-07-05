#!/usr/bin/env bash
dbuser="vb"
dbpass="vb"
db="vb"
RESULT=`mysqlshow --user=$dbuser --password=$dbpass $db| grep -v Wildcard | grep -o $db`
if [ "$RESULT" == "$db" ]; then
    echo "yes"
    else
    echo "No"
fi

# ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob