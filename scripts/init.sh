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
#  [Insert New]
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
verbose="debug"
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

Examples:
    sudo ./pl init -h
    sudo ./pl init -y -s=5

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
args=$(getopt -o yhs: -l yes,help,step: --name "$scriptname" -- "$@")
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
# This is needed to avoid the "awk: line 43: functionWill
# need to install gawk - sudo required asorti never
# defined" error
sudo apt-get install gawk
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
echo parsing yml
echo "location: $folderpath/pl.yml"
if [ ! -f "$folderpath/pl.yml" ] ; then
  echo "Copying example.pl.yml to pl.yml and setting some defaults based on the system."
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

# Step 5
################################################################################
# Updating System..
################################################################################
if [ $step -lt 6 ]; then
  echo -e "$Cyan step 5: Updating System..  $Color_Off"
# see: https://www.drupal.org/docs/develop/local-server-setup/linux-development-environments/installing-php-mysql-and-apache-under
# Update packages and Upgrade system
sudo apt-get update -y && sudo apt-get upgrade -y

## Install AMP
echo -e "$Cyan \n Installing Apache2 etc $Color_Off"
sudo apt-get install apache2 php libapache2-mod-php php-mysql curl php-cli php-gd php-mbstring php-gettext php-xml php-curl php-bz2 php-zip git unzip php-xdebug -y
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


# Step 7
################################################################################
# Installing MySQL
################################################################################
if [ $step -lt 8 ]; then
  echo -e "$Cyan step 7: Installing MySQL $Color_Off"
# From: https://stackoverflow.com/questions/7739645/install-mysql-on-ubuntu-without-a-password-prompt
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
sudo apt-get -y install mysql-server
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

cd
#composer global require drush/drush
echo "composer install consoildation/cgr"
# sudo ls -la .config
if [[ "$USER" == "travis" ]] ; then
sudo chown -R $USER "/home/$USER/.config"
else
sudo chown -R $USER "/home/$USER/.composer"
fi
# sudo chown -R $USER /home/travis/.composer/
composer global require consolidation/cgr
echo "echo path into bashrc"
cd
# ls -la

echo "composer home: $(composer config -g home)"

echo "export PATH=\"$(composer config -g home)/vendor/bin:$PATH\"" >> ~/.bashrc
source ~/.bashrc
# cat .bashrc

# https://github.com/consolidation/cgr/issues/29#issuecomment-422852318
cd /usr/local/bin
if [[ "$USER" == "travis" ]] ; then

sudo ln -s ~/.config/composer/vendor/bin/cgr .
#sudo ln -s ~/.config/composer/vendor/bin/drush .
else
sudo ln -s ~/.composer/vendor/bin/cgr .
fi

cd
cgr drush/drush
echo "export DRUSH_LAUNCHER_FALLBACK=~/.composer/vendor/bin/drush" >> ~/.bashrc
source ~/.bashrc

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

no_config_update="false"
update_all_configs
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
exit 0

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



