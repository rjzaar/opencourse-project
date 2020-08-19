#!/bin/bash
ocroot="/home/james/pleasy"
ocwroot="/var/www/oc"
script_root=/home/james/pleasy/scripts
#Don't touch the above lines it will be modified by init.sh

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

. $script_root/_inc.sh;

sitename_var=$1

parse_pl_yml
import_site_config $sitename_var

site_url="$folder.$sitename_var"
uri=$site_url
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
