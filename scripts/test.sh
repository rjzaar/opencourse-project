#!/bin/bash

cd /var/www/oc/stg/docroot/
echo "collected output"
var=$(drush cim -y 2>&1)
echo "collected output"
#echo "$var"
exit 0

Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

echo -e "$Red hello red $Color_Off"
echo -e "hi again."
echo -e "$Green green $Color_Off"

Name=$(date +%d%b%g%l:%M:%S%p)
echo $Name
exit 0
git clone git://github.com/phpenv/phpenv.git ~/.phpenv
echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(phpenv init -)"' >> ~/.bash_profile
exec $SHELL -l


echo 'max_execution_time = 1200' >> varbase.php.ini;
echo 'max_input_time = 180' >> varbase.php.ini;
echo 'max_input_vars = 10000' >> varbase.php.ini;
echo 'memory_limit = 4000M' >> varbase.php.ini;
echo 'error_reporting = E_ALL' >> varbase.php.ini;
echo 'post_max_size = 64M' >> varbase.php.ini;
echo 'upload_max_filesize = 32M' >> varbase.php.ini;
echo 'max_file_uploads = 40' >> varbase.php.ini;
echo 'sendmail_path = /bin/true' >> varbase.php.ini;
phpenv config-add varbase.php.ini
phpenv rehash
