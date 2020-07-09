#!/bin/bash

parse_pl_yml

if [ $1 == "open" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sitename_var=$1
echo "about to open $sitename_var"
drush @$sitename_var uli &


