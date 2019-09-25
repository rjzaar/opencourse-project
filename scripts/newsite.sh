#!/bin/bash
#This will set up a new site

# Help menu
print_help() {
cat <<-HELP
This script will set up a new site, including local hosts, apache, database name. Must be run as sudo.
You can provide the following arguments:

-sn|--sitename This is the site name. It is the URL of the site. The database name will be the sn without any '.'.

eg dev.oc site URL: dev.oc database: devoc folder: dev.oc


HELP
exit 0
}
if [ "$#" = 0 ]
then
print_help
exit 1
fi

for i in "$@"
do
case $i in
  -y) #put your project defaults here.
  # currently no defaults.
  shift
  ;;
      -sn=*|--sitename=*)
    sn="${i#*=}"
    shift # past argument=value
    ;;
  -h|--help) print_help;;
  *)
    printf "***************************\n"
    printf "* Error: Invalid argument *\n"
    printf "***************************\n"
    print_help
    exit 1
  ;;
esac
done

# Must be sudo
if [ $(id -u) != 0 ]; then
  printf "**************************************\n"
  printf "* Error: You must run this with sudo or root*\n"
  printf "**************************************\n"
  print_help
  exit 1
fi

#add apache reference
#current_directory="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
hosts_path="/etc/hosts"
vhosts_path="/etc/apache2/sites-available/"
#vhost_skeleton_path="$current_directory/vhost.skeleton.conf"
web_root="/home/rob/"
site_url=$sn
relative_doc_root="$sn/opencourse/docroot"

# construct absolute path
absolute_doc_root=$web_root$relative_doc_root


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
echo `/etc/init.d/apache2 restart`

echo "Process complete, check out the new site at http://$site_url"

exit 0