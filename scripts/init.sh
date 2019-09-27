#!/bin/bash

# This will set up drop and initialise the sites as per oc.yml, including the current production shared database.

# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

script_root=$(dirname $(whereis_realpath "$0"))

. "$script_root/_inc.sh"

echo "Parse YAML"
parse_oc_yml

echo "Adding pl command to bash commands, including plcd"
schome="/home/$user/$project/scripts"
sed -i "2s/ocroot=\"~\/opencourse\"/ocroot=\"\/home\/$user\/$project\"/" "$schome/plcd.sh"
echo "export PATH=\"\$PATH:$schome\"" >> ~/.bashrc
echo ". $schome/plcd.sh" >> ~/.bashrc
source ~/.bashrc
#plsource

# Create mysql root password file
cat > $(dirname $script_root)/mysql.cnf <<EOL
[client]
user = root
password = root
host = localhost
EOL



