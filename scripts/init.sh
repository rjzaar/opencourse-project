#!/bin/bash
################################################################################
#                      Initialisation For Pleasy Library
#
#  This will set up pleasy and initialise the sites as per
#  pl.yml, including the current production shared database.
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  08/02/2020 James Lim  Getopt parsing implementation, script documentation
#  04//04/2020 Rob Zaar  init is now working with new implementation.
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
# Add npm, nodejs: https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# Use node v12:
# https://stackoverflow.com/questions/41195952/updating-nodejs-on-ubuntu-16-04
#
################################################################################

# Set script name for general file use
scriptname='pleasy-init'
# Change this to debug to debug this script
verbose="none"
# User help
################################################################################
# Prints user guide
################################################################################
print_help() {
  echo \
  'Usage: pl init [OPTION]
This will set up pleasy and initialise the sites as per
pl.yml, including the current production shared database.
This will install many programs, which will be listed at
the end.

Mandatory arguments to long options are mandatory for short options too.
    -y --yes                Force all install options to yes (Recommended)
    -h --help               Display help (Currently displayed)
    -s --step={1,15}        FOR DEBUG USE, start at step number as seen in code
    -n --nopassword         Nopassword. This will give the user full sudo access without requireing a password!
                            This could be a security issue for some setups. Use with caution!
    -t --test            This option is only for test environments like Travis, eg there is no mysql root password.

Examples:
git clone git@github.com:rjzaar/pleasy.git [sitename]  #eg git clone git@github.com:rjzaar/pleasy.git mysite.org
bash ./pleasy/bin/pl  init # or if using [sitename]
bash ./[sitename]/bin/pl init

then if debugging:

bash ./[sitename]/bin/pl init -s=6  # to start at step 6.

INSTALL LIST:
    sudo apt-get install gawk
    sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath/bin" $user
    sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli \
    php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip
    php-xdebug -y
    sudo apt-get -y install mysql-server
    sudo apt-get install phpmyadmin -y
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
    sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
    curl https://drupalconsole.com/installer -L -o drupal.phar
    sudo apt install nodejs build-essential
    curl -L https://npmjs.com/install.sh | sh
    sudo apt install npm
    sudo npm install gulp-cli -g
    sudo npm install gulp -D
END OF HELP'
}

# Step Variable
################################################################################
# Variable step is defined for debug purposes. If the init fails, we can,
# using step, start at the point of the script which had failed
################################################################################
step=${step:-1}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are --yes --help --step
################################################################################
args=$(getopt -o yhs:ndt -l yes,help,step:,nopassword,debug,test --name "$scriptname" -- "$@")
# echo "$args"

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do './pl init --help' for more options"
    exit 1
}

# Set getopt parse backup into $@
################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# if no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -s | --step)
    shift;
    step="$(echo "$1" | sed 's/^=//g')"
    #echo "$step"
    # If step is in an invalid range, display invalid and exit program
    if [[ $step -gt 15 || $step -lt 1 ]]; then {
      echo "Invalid step value "$step" - valid range [1,15]"
      exit 1
    }
    fi
    ;;
  -y | --yes)
    yes="y"
    ;;
   -d | --debug)
    verbose="debug"
    ;;
  -n | --nopassword)
    nopassword="y"
    ;;
  -t | --test)
    pltest="y"
    ;;
  -h | --help)
    print_help
    exit 0
    ;;
  --)
    shift
    break
    ;;
  *)
    # *) should not occur with getopt, if it does, there is a bug
    echo "Programming error! Parse argument should not be passed"
    exit 1
    ;;
  esac
  shift
done

# Step Display
################################################################################
# Display to user which step is chosen if step option is defined
################################################################################
if [ $step -gt 1 ]; then
  echo "Starting from step $step"
fi

# Step 1
################################################################################
# Attempt to install gawk
################################################################################
if [ $step -lt 2 ]; then
  echo -e "$Cyan step 1: Will need to install gawk - sudo required $Color_Off"
# This is needed to avoid the awk: line 43: functionWill
# need to install gawk - sudo required asorti never
# defined error

#echo "test mysql"
#result=$(mysql -e 'CREATE DATABASE test;' 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
#echo "result2: >$result<"
#
#if [[ "$result" != ": 0" ]]; then
#  echo "mysql did not work"
#  mysql -e 'CREATE DATABASE test;'
#  fi
#echo "did it work?"

if [[ "$nopassword" == "y" ]] ; then
# set up user with sudo
echo "$USER ALL=(ALL:ALL) NOPASSWD: ALL" | sudo EDITOR="tee -a" visudo

# This could be improved with creating specific scripts that would complete any sudo tasks and each of these be given
# nopasswd permission. This would reduce the security risk of the above command.

fi

sudo apt-get install gawk
gout=$(gawk -Wv)
gversion=${gout:8:1}
echo "Gawk version: >$gversion<"

if [[ "$gversion" == "5" ]] ; then
  echo "Need to purge gawk and install version 4 of gawk"
1:4.1.4+dfsg-1build1
  sudo apt-get remove gawk -y

  wget https://ftp.gnu.org/gnu/gawk/gawk-4.2.1.tar.gz
tar -xvpzf gawk-4.2.1.tar.gz
cd gawk-4.2.1
sudo ./configure && sudo  make &&  sudo make install
sudo apt install  gawk=1:5.0.1+dfsg-1
# It installs 5.0.1, but when you run gawk -Wv it says it 4.2.1. Anyway it works. I don't know another way of doing it.
fi
fi

# Step 2
################################################################################
# This step must run, regardless of statement since the functions must be included for any other steps to be able to run
# Since the following steps will need the variables that will be accessible only if parse_pl_yml is run.
################################################################################
echo -e "$Cyan step 2 (must be run): checking if folder $sitename_var exists $Color_Off"
echo running include files...
# This includes all the functions in _inc.sh for use by init.sh @JamesCHLim
. "$script_root/_inc.sh"
ocmsg "parsing yml" debug
ocmsg "location: $folderpath/pl.yml" ocmsg
if [ ! -f "$folderpath/pl.yml" ] ; then
  ocmsg "Copying example.pl.yml to pl.yml and setting some defaults based on the system." debug
  cp $folderpath/example.pl.yml $folderpath/pl.yml
  # set the user
  sed -i "s/stcarlos/$USER/g" $folderpath/pl.yml
fi
# When using parse_pl_yml for the first time, ie as part init.sh, there is no need to update the script, since it
# doesn't need updating. Updating will cause problems. So we need to make sure it doesn't update by setting the
# no_config_update to "true". This is the only time it is set to true. We also don't want it to run if we are
# rerunning the init.sh script.
no_config_update="true"
# Import yaml, presumes $script_root is set
parse_pl_yml
#echo "wwwpath $www_path"

# Step 3
################################################################################
# Adding pl command to bash commands, including plextras
################################################################################
if [ $step -lt 4 ] ; then
  echo -e "$Cyan step 3: Adding pl command to bash commands, including plextras $Color_Off"

update_locations

#prep up the debug command with cli and apached locations
echo "adding debug command"
ocbin="/home/$user/$project/bin"
sed -i "3s|.*|phpcli=\"$phpcli\"|" "$ocbin/debug"
sed -i "4s|.*|phpapache=\"$phpapache\"|" "$ocbin/debug"

#set up d8fp, debug and sudoeuri to run without password
echo -e "$Cyan \n Make fixing folder permissions and debug run without sudo $Color_Off"
sudo $folderpath/scripts/lib/installsudoers.sh "$folderpath/bin" $user
echo "export PATH=\"\$PATH:/usr/local/bin/\"" >> ~/.bashrc
echo ". /usr/local/bin/debug" >> ~/.bashrc

cd
source ~/.bashrc
#plsource
fi

# Step 4
################################################################################
# Create mysql root password file
################################################################################
if [ $step -lt 5 ]; then
  echo -e "$Cyan step 4: Create mysql root password file $Color_Off"
# Create mysql root password file
# Check if one exists
if [ ! -f $(dirname $script_root)/mysql.cnf ]
then
echo "Creating $(dirname $script_root)/mysql.cnf"

if [[ "$pltest" = "y" ]] ; then
echo "Testing: mysql root setup at  $(dirname $script_root)/mysql.cnf"
cat > $(dirname $script_root)/mysql.cnf <<EOL
[client]
user=root
password=root
host=localhost
EOL
else
cat > $(dirname $script_root)/mysql.cnf <<EOL
[client]
user=root
password=root
host=localhost
EOL
#Check if mysql is installed
if type mysql >/dev/null 2>&1; then
# User needs to add mysql root credentials.
echo "mysql already installed. Please edit $(dirname $script_root)/mysql.cnf with your mysql root credentials."
fi
fi
else
echo "mysql.cnf already exists"
fi
#sudo chmod 0600 $(dirname $script_root)/mysql.cnf

fi

# Step 5
################################################################################
# Updating System..
################################################################################
if [ $step -lt 6 ]; then
  echo -e "$Cyan step 5: Updating System..  $Color_Off"
# see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
# Update packages and Upgrade system
sudo apt-get -qqy update && sudo apt-get -qqy upgrade


# Setup php 7.3
sudo apt-get -y install software-properties-common
sudo add-apt-repository -y ppa:ondrej/php
sudo add-apt-repository -y ppa:ondrej/apache2
#
sudo apt -qqy update

## Install AMP
echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
# php-gettext not installing on ubuntu 20
#sudo apt-get -qq install apache2 php libapache2-mod-php php-mysql php-gettext curl php-cli php-gd php-mbstring php-xml php-curl php-bz2 php-zip git unzip php-xdebug -y
sudo apt-get -y install apache2 php7.3 libapache2-mod-php7.3 php7.3-mysql php7.3-common curl php7.3-cli php7.3-gd php7.3-mbstring php7.3-xml php7.3-curl php7.3-bz2 php7.3-zip git unzip php-xdebug -y

fi

# Step 6
################################################################################
# Add github credentials
################################################################################
if [ $step -lt 7 ]; then
  echo -e "$Cyan step 6: Add github credentials $Color_Off"
#add github credentials
git config --global user.email $github_email
git config --global user.name $github_user
git config --global credential.helper store
fi

echo "github credentials added"
# Step 7
################################################################################
# Installing MySQL
################################################################################
if [ $step -lt 8 ]; then
  echo -e "$Cyan step 7: Installing MySQL $Color_Off"
#Check if mysql is installed
#if type mysql >/dev/null 2>&1; then
#echo "mysql already installed."
#else
# Not installed
# From: https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
#fi

fi

# Step 8
################################################################################
# Installing phpMyAdmin
################################################################################
if [ $step -lt 9 ]; then
  echo -e "$Cyan step 8: Installing phpMyAdmin $Color_Off"
sudo apt-get install phpmyadmin -y
fi

## TWEAKS and Settings
# Permissions
#echo -e "$Cyan \n Permissions for /var/www $Color_Off"
#sudo chown -R www-data:www-data /var/www
#echo -e "$Green \n Permissions have been set $Color_Off"

# Step 9
################################################################################
# Enabling Modules
################################################################################
if [ $step -lt 10 ]; then
  echo -e "$Cyan step 9: Enabling Modules  $Color_Off"
# Enabling Mod Rewrite, required for WordPress permalinks and .htaccess files
sudo a2enmod rewrite
sudo phpenmod xml

# Restart Apache
echo -e "$Cyan \n Restarting Apache $Color_Off"
sudo service apache2 restart
fi

# Step 10
################################################################################
#  Install Composer
################################################################################
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

# Not sure why this next line might be needed.... @rjzaar
#sudo chown -R $user .composer/
fi

# Step 11
################################################################################
# Install Drush globally
################################################################################
if [ $step -lt 12 ]; then
  echo -e "$Cyan step 11: Install Drush globally $Color_Off"
# Install drush globally with drush launcher
# see: https://github.com/drush-ops/drush-launcher  ### xdebug issues?
if [ ! -f /usr/local/bin/drush ]
then
wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar
sudo chmod +x drush.phar
sudo mv drush.phar /usr/local/bin/drush
echo "drush installed"
else
  echo "drush already present."
fi

# Also need to install drush globally so drush will work outside of drupal sites
# see https://www.jeffgeerling.com/blog/2018/drupal-vm-48-and-drush-900-some-major-changes
# see https://docs.drush.org/en/8.x/install-alternative/  and
# see https://github.com/consolidation/cgr
#
# if there is an issue with swap use this to fix it: https://www.digitalocean.com/community/tutorials/how-to-add-swap-space-on-ubuntu-16-04
comppres="false"
cd
#composer global require drush/drush
echo "composer install consoildation/cgr"
# sudo ls -la .config
if [[ -d "/home/$USER/.config" ]] ; then
sudo chown -R $USER "/home/$USER/.config"
comppres="true"
fi

if [[ -d "/home/$USER/.composer" ]] ; then
sudo chown -R $USER "/home/$USER/.composer"
comppres="true"
fi
if [[ "$comppres" == "false" ]] ; then
  echo "Don't know where composer is. I thought I installed it.1"
fi

# sudo chown -R $USER /home/travis/.composer/
composer global require consolidation/cgr
echo "echo path into bashrc"
cd
# ls -la

echo "composer home: $(composer config -g home)"
comphome=$(composer config -g home)

echo "export PATH=\"\$PATH:$comphome/vendor/bin:\"" >> ~/.bashrc
source ~/.bashrc
# cat .bashrc

# https://github.com/consolidation/cgr/issues/29#issuecomment-422852318
cd /usr/local/bin

if [[ -d "/home/$USER/.config" ]] ; then
  if [[ ! -L './cgr' ]] ; then
    echo "Creating symlink"
sudo ln -s $comphome/vendor/bin/cgr .
fi
#sudo ln -s ~/.config/composer/vendor/bin/drush .
cd
echo "export DRUSH_LAUNCHER_FALLBACK=$comphome/vendor/bin/drush" >> ~/.bashrc
elif [[ -d "/home/$USER/.composer" ]] ; then
if [[ ! -h ~/.composer/vendor/bin/cgr ]] ; then
    if [[ ! -L './cgr' ]] ; then
          echo "Creating symlink2"
sudo ln -s ~/.composer/vendor/bin/cgr .
fi
cd
echo "export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush" >> ~/.bashrc
fi
else
  echo "Don't know where composer is. I thought I installed it.2"
fi
cd
source ~/.bashrc
cgr drush/drush
fi

# Step 12
################################################################################
# Install Drupal console globally
################################################################################
if [ $step -lt 13 ]; then
  echo -e "$Cyan step 12: Install Drupal console globally  $Color_Off"
# Install drupal console
# see https://drupalconsole.com/articles/how-to-install-drupal-console
if [ ! -f /usr/local/bin/drupal ]
then
echo "curl"
curl https://drupalconsole.com/installer -L -o drupal.phar
#could test it
# php drupal.phar
sudo mv drupal.phar /usr/local/bin/drupal
sudo chmod +x /usr/local/bin/drupal
echo "drupal init"
drupal init --override --no-interaction
echo "drupal init finished"
#Bash or Zsh: Add this line to your shell configuration file:
#echo "set up source"
 #source "$HOME/.console/console.rc" 2>/dev/null
echo "put into bashrc"
 echo "source \"$HOME/.console/console.rc\" 2>/dev/null" >> ~/.bashrc
echo "reset source"
 cd
 source ~/.bashrc

#Fish: Create a symbolic link
echo "Make fish dir"
 mkdir -p ~/.config/fish/completions/
echo "set up symlink"
 ln -s ~/.console/drupal.fish ~/.config/fish/completions/drupal.fish

# drupal self-update no longer valid? https://github.com/hechoendrupal/drupal-console/issues/3198
#echo "drupal self-update"
#drupal self-update
else
  echo "Drupal console already present"
fi
fi

# Step 13
################################################################################
# setup /var/wwww/oc for websites
################################################################################
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

# @remove
#These lines are not needed since this is the setup up and update configs will be run after a site is installed.
#no_config_update="false"
#update_all_configs
fi

# Step 14
################################################################################
# Fix adding extra characters for vi
################################################################################
if [ $step -lt 15 ]; then
  echo -e "$Cyan step 14: Fix adding extra characters for vi  $Color_Off"
#Set up vi to not add extra characters
#From: https://askubuntu.com/questions/353911/hitting-arrow-keys-adds-characters-in-vi-editor
echo -e "$Cyan \n  $Color_Off"
cat > $(dirname $script_root)/.vimrc <<EOL
set nocompatible
EOL
fi
echo " open this link to add the xdebug extension for the browser you want to use"
echo "https://www.jetbrains.com/help/phpstorm/2019.3/browser-debugging-extensions.html?utm_campaign=PS&utm_medium=link&utm_source=product&utm_content=2019.3 "


# Step 15
################################################################################
# I don't think this step is needed since theming tools are added to each instance via pl install
################################################################################
# jump this step
if [[ -f ~/.bashrc ]] ; then
ocmsg "source ~/.bashrc" debug
source ~/.bashrc
fi
if [[ -f ~/.zshrc ]] ; then
ocmsg "source ~/.zshrc" debug
source ~/.zshrc
fi

if [ $step -lt 16 ]; then
  echo -e "$Cyan step 15: Now add theming tools $Color_Off"
#Now add theming tools


# This is the latest way to load it: https://docs.npmjs.com/downloading-and-installing-node-js-and-npm#using-a-node-version-manager-to-install-node-js-and-npm
# and: https://github.com/nvm-sh/nvm
ocmsg "Using nvm to install nodejs and npm" debug
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
# source ~/.bashrc
nvm install node
sudo apt install build-essential

# see https://github.com/Vardot/vartheme_bs4/tree/8.x-6.x/scripts
# use recommended version of Node.js
#ocmsg "getting setup from nodesource." debug
#curl -sL https://deb.nodesource.com/setup_13.x | sudo -E bash -
#ocmsg "install nodejs build-essential" debug
#sudo apt-get install -y nodejs build-essential
#
#
#ocmsg "getting npmjs install." debug
#sudo curl -L https://npmjs.com/install.sh | sudo sh
#ocmsg "sudo apt install npm" debug
#sudo apt install npm

ocmsg "sudo npm install gulp-cli -g" debug
npm install gulp-cli -g
ocmsg "sudo npm install gulp -D" debug
npm install gulp -D

ocmsg "Increase watch speed for gulp: requires sudo." debug
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
fi

if [ $step -lt 17 ]; then
  echo -e "$Cyan step 16: Setup drush aliases etc. $Color_Off"
source ~/.bashrc
update_all_configs
fi
echo "All done!"

exit 0

