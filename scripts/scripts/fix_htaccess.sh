#!/bin/bash

# This is a helper script to fix .htaccess problem in Drupal
# 
# See: https://www.drupal.org/node/2625224

root=$1

# Copyright: https://www.virtualmin.com/node/24753#comment-111132
SUFFIX="IOSBUG" # in IOS -i must have some value. If we use -i '' syntax it would not work in Linux!
find $root -name ".htaccess" -type f -exec sed -i$SUFFIX 's/FollowSymLinks/SymLinksIfOwnerMatch/g' {} \;
find $root -name *$SUFFIX -exec rm {} \;
