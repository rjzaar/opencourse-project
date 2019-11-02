#!/bin/bash

# This will set up pleasy and initialise the sites as per pl.yml, including the current production shared database.

# TODO?
# install drupal console: run in user home directory:
# composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader

. "$script_root/_inc.sh"

parse_pl_yml

echo "Adding pl command to bash commands, including plcd"
schome="/home/$user/$project/bin"
echo $schome
sed -i "2s/.*/ocroot=\"\/home\/$user\/$project\"/" "$schome/plcd.sh"
echo "export PATH=\"\$PATH:$schome\"" >> ~/.bashrc
echo ". $schome/plcd.sh" >> ~/.bashrc
cd
source ~/.bashrc
#plsource

# Create mysql root password file
# Check if one exists
if [ ! -f $(dirname $script_root)/mysql.cnf ]
then
echo "Creating mysql.cnf"
cat > $(dirname $script_root)/mysql.cnf <<EOL
[client]
user = root
password = root
host = localhost
EOL
else
echo "mysql.cnf already exists"
fi

#Could check install of drush, drupal console, etc.

# Modified from: https://gist.github.com/aamnah/f03c266d715ed479eb46
#COLORS
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan


# see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
# Update packages and Upgrade system
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt-get update -y && sudo apt-get upgrade -y

## Install AMP
echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli php-gd php-mbstring php-xml php-curl php-bz2 git unzip -y

echo -e "$Cyan \n Installing MySQL $Color_Off"
# From: https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server


echo -e "$Cyan \n Installing phpMyAdmin $Color_Off"
sudo apt-get install phpmyadmin -y

## TWEAKS and Settings
# Permissions
#echo -e "$Cyan \n Permissions for /var/www $Color_Off"
#sudo chown -R www-data:www-data /var/www
#echo -e "$Green \n Permissions have been set $Color_Off"

# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
echo -e "$Cyan \n Enabling Modules $Color_Off"
sudo a2enmod rewrite
sudo phpenmod xml

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo service apache2 restart
#Check if composer is installed otherwise install it
# From https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-16-04?comment=67716
cd
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#mv composer.phar /usr/local/bin/composer
sudo chown -R $user .composer/




#set up d8fp to run without password
sudo $folderpath/scripts/lib/installd8fp.sh "$folderpath/scripts/lib/d8fp.sh" $user

