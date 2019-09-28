#!/bin/bash

parse_oc_yml

if [ $1 == "open" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sn=$1
drush @$sn uli


