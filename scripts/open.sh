#!/bin/bash

parse_pl_yml

if [ $1 == "open" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sn=$1
echo "about to open $sn"
drush @$sn uli


