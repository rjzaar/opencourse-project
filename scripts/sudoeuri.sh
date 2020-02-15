#!/bin/bash
#This will set up a new uri

# Help menu
print_help() {
cat <<-HELP
This script will set up a new site, including local hosts, apache, database name. Must be run as sudo.
You can provide the following arguments:

-sitename_var|--sitename This is the site name. It is the URL of the site. The database name will be the sitename_var without any '.'.

eg dev.oc site URL: dev.oc database: devoc folder: dev.oc


HELP
exit 0
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

if [ $1 == "sudoeuri" ] && [ -z "$2" ]
  then
    echo "No site specified"
    print_help
    exit 1
fi
# Must be sudo
if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi
# Helper functions to get the abolute path for the command
# Copyright http://stackoverflow.com/a/7400673/257479
myreadlink() { [ ! -h "$1" ] && echo "$1" || (local link="$(expr "$(command ls -ld -- "$1")" : '.*-> \(.*\)$')"; cd $(dirname $1); myreadlink "$link" | sed "s|^\([^/].*\)\$|$(dirname $1)/\1|"); }
whereis() { echo $1 | sed "s|^\([^/].*/.*\)|$(pwd)/\1|;s|^\([^/]*\)$|$(which -- $1)|;s|^$|$1|"; }
whereis_realpath() { local SCRIPT_PATH=$(whereis $1); myreadlink ${SCRIPT_PATH} | sed "s|^\([^/].*\)\$|$(dirname ${SCRIPT_PATH})/\1|"; }

script_root=$(dirname $(whereis_realpath "$0"))
script_root=$(dirname $(whereis_realpath "$0"))
folder=$(basename $(dirname $script_root))
folderpath=$(dirname $script_root)
user_home=$(dirname $folderpath)
. $script_root/_inc.sh;

sitename_var=$1

parse_pl_yml
import_site_config $sitename_var

site_url="$folder.$sitename_var"
site_info
# construct absolute path
absolute_doc_root="$site_path/$sitename_var/$webroot"
echo "Site URL: $folder.$sitename_var"
echo "Site docroot: $absolute_doc_root"

# update vhost
vhost="# @site_url@
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot \"@site_docroot@\"
    ServerName @site_url@
    ServerAlias www.@site_url@
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined

    <Directory \"@site_docroot@\">
        Require all granted
        AllowOverride All
  </Directory>
</VirtualHost>"
vhost=${vhost//@site_url@/$site_url}
vhost=${vhost//@site_docroot@/$absolute_doc_root}

`touch $vhosts_path$site_url.conf`
echo "$vhost" > "$vhosts_path$site_url.conf"
echo "Updated vhosts in Apache config"

# update hosts file
echo 127.0.0.1    $site_url >> $hosts_path
echo "Updated the hosts file"

# restart apache
echo "Enabling site in Apache..."
echo `a2ensite $site_url`

echo "Restarting Apache..."
echo `service apache2 restart`

echo "Process complete, check out the new site at http://$site_url"

exit 0
