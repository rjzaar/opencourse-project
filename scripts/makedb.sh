#!/bin/bash

parse_pl_yml

if [ $1 == "makedb" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi

sn=$1
echo "create db for $sn"
import_site_config $sn
make_db



