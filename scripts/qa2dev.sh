#!/bin/bash
#qa2dev

# Need to check if there is an opencourse git or not.
# if not, then delete opencourse and clone a fresh opencourse and install (dev is default). 

# install feature modules?

# move opencourse git to opencourse
cd
cd opencat/ocgitstore
mv .git ../opencourse/

# turn on dev modules (composer)
cd
cd opencat/opencourse
composer install 
# patch .htaccess
sed -i '4iOptions +FollowSymLinks' docroot/.htaccess

# rebuild permissions
echo "Rebuild permissions, requires sudo."
sudo ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob
#make custom writable
cd
chmod g+w -R opencat/opencourse/docroot/modules/custom

#install dev modules
cd opencat/opencourse/docroot
drush en -y oc_dev

#turn on dev settings
drupal site:mode dev

#clear cache
drush cr
