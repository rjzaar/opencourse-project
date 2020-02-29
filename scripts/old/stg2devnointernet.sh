#!/bin/bash
#stg2devnointernet

#install dev modules
cd
cd opencat/opencourse/docroot
drush en -y oc_dev

#turn on dev settings
drupal site:mode dev

#clear cache
drush cr
