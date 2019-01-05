#!/bin/bash
#dev2qa
#Make changes to move from a dev to qa environment.
#This is the same folder with the same database, just some changes are made to setup.
#This presumes a single dev is able to work on dev and qa on his own, without a common qa server (for now).

#You would normally push opencourse to git before these steps.

#turn off dev settings
echo "turn off site dev settings."
cd
cd opencat/opencourse/docroot
drupal site:mode prod

#turn off dev modules
echo "turn off dev modules"
drupal mou oc_dev
drupal mou migrate_devel
drupal mou syslog
drupal mou  views_ui
drupal mou  block_place
drupal mou  devel
drupal mou kint
drupal mou features_ui
drupal mou  dblog
drupal mou  search_kint
drupal mou twig_xdebug
drupal mou migrate_plus
drupal mou migrate_tools

#drupal mou oc_dev, migrate_devel, syslog, views_ui, block_place, devel, kint, features_ui, dblog, search_kint, twig_xdebug



#drupal mou syslog, views_ui, migrate_devel, block_place, devel, kint, features_ui, oc_prod, default_content, dblog, search_kint, twig_xdebug, migrate_manifest, custom_migration, migrate_tools, migrate_plus, migrate_upgrade, twig_xdebug, oc_groups, oc_lp, oc_sequence, oc_content, oc_doc, oc_book, oc_link, oc_image, oc_taxonomy, oc_fields, oc_site

#push opencourse git. No need to move since it is ignored.
echo "push git"
cd
cd opencat/opencourse
#remove any extra options. Since each reinstall may add an extra one.
#following line has been fixed with a patch
#sed -i 's/Options +FollowSymLinks/Options +FollowSymLinks/g' .htaccess
ssh-add ~/.ssh/github
git add .
git commit -m "Backup."
git push
#mv .git ../ocgitstore/

#turn off composer dev
echo "Turn off composer dev"
cd
cd opencat/opencourse
composer install --no-dev

#following line has been fixed with a patch
# patch .htaccess
#echo "patch .htaccess"
#sed -i '4iOptions +FollowSymLinks' docroot/.htaccess

# rebuild permissions
echo "rebuilding permissions, requires sudo"

sudo ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob

# clear cache
echo "clear cache"
cd docroot
#don't know why, but for some reason video embed field is not installed when it is in composer and oc_prod.
drush en -y video_embed_field
drush cr





#Note database is the same between dev and qa in the forward direction.


