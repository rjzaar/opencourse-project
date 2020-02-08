#!/bin/bash

parse_pl_yml

if [ $1 == "makedb" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sitename_var=$1
echo "create db for $sitename_var"
import_site_config $sitename_var
make_db



