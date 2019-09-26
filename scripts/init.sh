#!/bin/bash

# This will set up drop and initialise the sites as per oc.yml, including the current production shared database.

# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

config_path=$1
script_root=$(dirname $(whereis_realpath "$0"))

#. $script_root/lib/common.inc.sh;
#. $script_root/lib/db.inc.sh;
#. $script_root/scripts/_inc.sh;

_config_path=$1
_config_base_path=""
_config_prefix=""
config_base=""
echo "Parse YAML"
. $script_root/scripts/parse_yaml.sh "../oc.yml"

schome="/home/$user/$project/scripts/"

echo "export PATH=\"\$PATH:$schome\"" >> ~/.bashrc
source ~/.bashrc



