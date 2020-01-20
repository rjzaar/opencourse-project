#!/bin/bash

# This will set up pleasy and initialise the sites as per pl.yml, including the current production shared database.

# TODO?
# Add npm, nodejs: https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# Use node v12: https://stackoverflow.com/questions/41195952/updating-nodejs-on-ubuntu-16-04
step=1
if [ "$#" -gt 0 ]; then
  for i in "$@"; do
    case $i in
    -s=* | --step=*)
      step="${i#*=}"
      shift # past argument=value
      ;;
    -y | --yes)
      yes="y"
      shift
      ;;
    -h | --help) print_help ;;
    *)
      shift # past argument=value
      ;;
    esac
  done

fi

if [ $step -gt 1 ]; then
  echo "Starting from step $step"
fi

if [ $step -lt 2 ]; then
  echo -e "$Cyan step 1: Will need to install gawk - sudo required $Color_Off"
# This is needed to avoid the "awk: line 43: functionWill need to install gawk - sudo required asorti never defined" error
sudo apt-get install gawk
fi


echo -e "$Cyan step 2 (must be run): checking if folder $sn exists $Color_Off"
echo running include files...
. "$script_root/_inc.sh"
echo parsing yml
echo "location: $folderpath/pl.yml"
if [ ! -f "$folderpath/pl.yml" ] ; then echo " Please copy example.pl.yml to pl.yml and modify. exiting. "; exit 1 ; fi
no_config_update="true"
parse_pl_yml

#echo "wwwpath $www_path"

if [ $step -lt 4 ]; then
  echo -e "$Cyan step 3: Adding pl command to bash commands, including plextras $Color_Off"
# Check correct user name
if [ ! -d "/home/$user" ] ; then echo "User name in pl.yml $user does not match the current user's home directory name. Please fix pl.yml."; exit 1; fi

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
fi

if [ $step -lt 5 ]; then
  echo -e "$Cyan step 4: Create mysql root password file $Color_Off"
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
fi
#Could check install of drush, drupal console, etc.

if [ $step -lt 6 ]; then
  echo -e "$Cyan step 5: Updating System..  $Color_Off"
# see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
# Update packages and Upgrade system
sudo apt-get update -y && sudo apt-get upgrade -y

## Install AMP
echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip php-xdebug -y
fi

if [ $step -lt 7 ]; then
  echo -e "$Cyan step 6: Add github credentials $Color_Off"
#add github credentials
git config --global user.email $github_email
git config --global user.name $github_user
git config --global credential.helper store
fi


if [ $step -lt 8 ]; then
  echo -e "$Cyan step 7: Installing MySQL $Color_Off"
# From: https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
fi

if [ $step -lt 9 ]; then
  echo -e "$Cyan step 8: Installing phpMyAdmin $Color_Off"
sudo apt-get install phpmyadmin -y
fi

## TWEAKS and Settings
# Permissions
#echo -e "$Cyan \n Permissions for /var/www $Color_Off"
#sudo chown -R www-data:www-data /var/www
#echo -e "$Green \n Permissions have been set $Color_Off"

if [ $step -lt 10 ]; then
  echo -e "$Cyan step 9: Enabling Modules  $Color_Off"
# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
sudo a2enmod rewrite
sudo phpenmod xml

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo service apache2 restart
fi

if [ $step -lt 11 ]; then
  echo -e "$Cyan step 10: Install Composer  $Color_Off"
#Check if composer is installed otherwise install it
# From https://www.digitalocean.com/community/tutorials/how-to-install-and-use-composer-on-ubuntu-16-04?comment=67716
cd
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
php -r "if (hash_file('SHA384', 'composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
#mv composer.phar /usr/local/bin/composer

# Not sure why this next line might be needed....
#sudo chown -R $user .composer/
fi

if [ $step -lt 12 ]; then
  echo -e "$Cyan step 11: Install Drush globally $Color_Off"
# Install drush globally with drush launcher
# see: https://github.com/drush-ops/drush-launcher  ### xdebug issues?
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
source ~/.bashrc

cgr drush/drush
echo "export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush" >> ~/.bashrc
source ~/.bashrc

fi

if [ $step -lt 13 ]; then
  echo -e "$Cyan step 12: Install Drupal console globally  $Color_Off"
# Install drupal console
# see https://drupalconsole.com/articles/how-to-install-drupal-console
if [ ! -f /usr/local/bin/drupal ]
then
curl https://drupalconsole.com/installer -L -o drupal.phar
#could test it
# php drupal.phar
sudo mv drupal.phar /usr/local/bin/drupal
sudo chmod +x /usr/local/bin/drupal
drupal init
#Bash or Zsh: Add this line to your shell configuration file:
source "$HOME/.console/console.rc" 2>/dev/null
#Fish: Create a symbolic link
ln -s ~/.console/drupal.fish ~/.config/fish/completions/drupal.fish
drupal self-update
else
  echo "Drupal console already present"
fi
fi

if [ $step -lt 14 ]; then
  echo -e "$Cyan step 13: setup /var/wwww/oc for websites  $Color_Off"
#set up website folder for apache
if [ ! -d /var/www/oc ]
then
sudo mkdir /var/www/oc
sudo chown $user:www-data /var/www/oc
else
  echo "/var/wwww/oc already exists"
fi

no_config_update="false"
update_all_configs
fi

if [ $step -lt 15 ]; then
  echo -e "$Cyan step 14: Fix adding extra characters for vi  $Color_Off"
#Set up vi to not add extra characters
#From: https://askubuntu.com/questions/353911/hitting-arrow-keys-adds-characters-in-vi-editor
echo -e "$Cyan \n  $Color_Off"
cat > $(dirname $script_root)/.vimrc <<EOL
set nocompatible
EOL
fi

if [ $step -lt 16 ]; then
  echo -e "$Cyan step 15: Now add theming tools $Color_Off"
#Now add theming tools
# see https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# use recommended version of Node.js
curl -sL https://deb.nodesource.com/setup_10.x | sudo bash -
sudo apt install nodejs build-essential


curl -L https://npmjs.com/install.sh | sh
sudo apt install npm
sudo npm install gulp-cli -g
sudo npm install gulp -D

echo "Increase watch speed for gulp: requires sudo."
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p

fi


echo " open this link to add the xdebug extension for the browser you want to use"
echo "https://www.jetbrains.com/help/phpstorm/2019.3/browser-debugging-extensions.html?utm_campaign=PS&utm_medium=link&utm_source=product&utm_content=2019.3 "




