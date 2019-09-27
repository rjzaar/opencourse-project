#!/usr/bin/env bash

#mysql --defaults-extra-file=/home/rob/opencat/mysql.cnf -e "CREATE DATABASE teststg CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
# Get the helper functions etc.
. $script_root/_inc.sh;

auto="y"
folder=$(basename $(dirname $script_root))
webroot="docroot" # or could be web or html
project="rjzaar/opencourse:8.7.x-dev"
# For a private setup, either it is a test setup which means private is in the usual location <site root>/site/default/files/private or
# there is a proper setup with opencat, which means private is as below. $secure is the switch, so if $secure and
sn="dev"
profile="varbase"
dev="y"

parse_oc_yml
