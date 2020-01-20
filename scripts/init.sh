#!/bin/bash

# This will set up pleasy and initialise the sites as per pl.yml, including the current production shared database.

# TODO?
# Add npm, nodejs: https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# Use node v12: https://stackoverflow.com/questions/41195952/updating-nodejs-on-ubuntu-16-04


# This is needed to avoid the "awk: line 43: function asorti never defined" error
echo "Will need to install gawk - sudo required"
sudo apt-get install gawk
echo running include files...
. "$script_root/_inc.sh"
echo parsing yml
parse_pl_yml

echo "wwwpath $www_path"
if [ $user = "" ]
then
  echo "user empty"
  user="rob"
  project="opencat"
fi

echo "Adding pl command to bash commands, including plextras"
schome="/home/$user/$project/bin"
sed -i "2s/.*/ocroot=\"\/home\/$user\/$project\"/" "$schome/plextras.sh"
#sed -i "3s/.*/ocroot=\"\/home\/$user\/$project\"/" "$schome/plextras.sh"
wwwp="${www_path////\\/}"
sed -i  "3s/.*/ocwroot=\"$wwwp\"/" "$schome/plextras.sh"
sr="${script_root////\\/}"
sed -i "4s/.*/script_root=\"$sr\"/" "$schome/plextras.sh"
echo "export PATH=\"\$PATH:$schome\"" >> ~/.bashrc
echo ". $schome/plextras.sh" >> ~/.bashrc

#prep up the debug command with cli and apached locations
echo "adding debug command"
ocbin="/home/$user/$project/bin"
sed -i "3s|.*|phpcli=\"$phpcli\"|" "$ocbin/debug.sh"
sed -i "4s|.*|phpapache=\"$phpapache\"|" "$ocbin/debug.sh"



#set up d8fp to run without password
echo -e "$Cyan \n Make fixing folder permissions and debug run without sudo $Color_Off"
sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath/bin" $user
echo "export PATH=\"\$PATH:/usr/local/bin/\"" >> ~/.bashrc
echo ". /usr/local/bin/debug.sh" >> ~/.bashrc

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

# see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
# Update packages and Upgrade system
echo -e "$Cyan \n Updating System.. $Color_Off"
sudo apt-get update -y && sudo apt-get upgrade -y

## Install AMP
echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli php-gd php-mbstring php-xml php-curl php-bz2 php-zip git unzip php-xdebug -y

#add github credentials
echo -e "$Cyan \n Add github credentials $Color_Off"
git config --global user.email $github_email
git config --global user.name $github_user
git config --global credential.helper store



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
echo -e "$Cyan \n Install Composer $Color_Off"
cd
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#mv composer.phar /usr/local/bin/composer
sudo chown -R $user .composer/


# Install drush globally with drush launcher
# see: https://github.com/drush-ops/drush-launcher  ### xdebug issues?
echo -e "$Cyan \n Install Drush globally $Color_Off"
if [ ! -f /usr/local/bin/drush ]
then
wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
sudo chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush
else
  echo "drush already present."
fi

# Also need to install drush globally so drush will work outside of drupal sites
# see https://www.jeffgeerling.com/blog/2018/drupal-vm-48-and-drush-900-some-major-changes
# see https://docs.drush.org/en/8.x/install-alternative/  and
# see https://github.com/consolidation/cgr
cd
#composer global require drush/drush
composer global require consolidation/cgr
echo "export PATH=\"\$(composer config -g home)/vendor/bin:$PATH\"" >> ~/.bashrc
cgr drush/drush
echo "export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush" >> ~/.bashrc


## Install drupal console
## see https://drupalconsole.com/articles/how-to-install-drupal-console
#echo -e "$Cyan \n Install Drupal console globally $Color_Off"
#if [ ! -f /usr/local/bin/drupal ]
#then
#curl https://drupalconsole.com/installer -L -o drupal.phar
##could test it
## php drupal.phar
#sudo mv drupal.phar /usr/local/bin/drupal
#sudo chmod +x /usr/local/bin/drupal
#drupal init
##Bash or Zsh: Add this line to your shell configuration file:
#source "$HOME/.console/console.rc" 2>/dev/null
##Fish: Create a symbolic link
#ln -s ~/.console/drupal.fish ~/.config/fish/completions/drupal.fish
#drupal self-update
#else
#  echo "Drupal console already present"
#fi



#set up website folder for apache
echo -e "$Cyan \n setup /var/wwww/oc for websites $Color_Off"
if [ ! -d /var/www/oc ]
then
sudo mkdir /var/www/oc
sudo chown $user:www-data /var/www/oc
else
  echo "/var/wwww/oc already exists"
fi


#Set up vi to not add extra characters
#From: https://askubuntu.com/questions/353911/hitting-arrow-keys-adds-characters-in-vi-editor
echo -e "$Cyan \n Fix adding extra characters for vi $Color_Off"
cat > $(dirname $script_root)/.vimrc <<EOL
set nocompatible
EOL

#Now add theming tools
# see https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# use recommended version of Node.js
curl -sL https://deb.nodesource.com/setup_8.x | sudo bash -
apt install nodejs
apt install build-essential

curl -L https://npmjs.com/install.sh | sh
apt install npm
npm install gulp-cli -g
npm install gulp -D

echo "Increase watch speed for gulp: requires sudo."
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p




echo " open this link to add the xdebug extension for the browser you want to use"
echo "https://www.jetbrains.com/help/phpstorm/2019.3/browser-debugging-extensions.html?utm_campaign=PS&utm_medium=link&utm_source=product&utm_content=2019.3 "




