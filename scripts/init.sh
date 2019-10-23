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

#set up d8fp to run without password
sudo $folderpath/scripts/lib/installd8fp.sh "$folderpath/scripts/lib/d8fp.sh" $user

