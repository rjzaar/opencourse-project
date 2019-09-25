#!/bin/bash
#devpush

#From: https://events.drupal.org/vienna2017/sessions/advanced-configuration-management-config-split-et-al
#Export configuration: drush cex
#Commit git add && git commit
#Merge: git pull
#Update dependencies: composer install
#run updates: drush updb
#Import configuration: drush cim
#Push: git push

# Start Timer
SECONDS=0
#Export configuration: drush cex
#Commit git add && git commit
#Merge: git pull
#Update dependencies: composer install
#run updates: drush updb
#Import configuration: drush cim
#Push: git push

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
#( speaker-test -t sine -f 1000 )& pid=$! ; sleep 0.1s ; kill -9 $pid
"sudo ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob"

# clear cache
echo "clear cache"
cd docroot
#don't know why, but for some reason video embed field is not installed when it is in composer and oc_prod.
drush en -y video_embed_field
drush cr

echo 'H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))



#Note database is the same between dev and stg in the forward direction.


