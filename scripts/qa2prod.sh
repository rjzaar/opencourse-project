#!/bin/bash
#qa2prod
#This will backup prod, push qa to prod and import.
#This presumes testqa.sh worked, therefore opencat git is upto date with cmi export and all files.

#On prod:
# maintenance mode
ssh puregift "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode TRUE"

# backup db and private files
echo "backup proddb and private files"
ssh puregift "./backoc.sh"

# pull opencat
ssh puregift "./pull.sh"

#restore private files, just in case some were added between test and deploy
ssh puregift "cd opencat.org && rm -rf private"
ssh puregift "cd opencat.org && tar -zxf ../ocbackup/private.tar.gz"
echo "Fix permissions, requires sudo"
ssh -t puregift "cd opencat.org && sudo chown :www-data private -R"

#update drupal
ssh puregift "cd opencat.org/opencourse/docroot/ && drush updb -y"
ssh puregift "cd opencat.org/opencourse/docroot/ && drush fra -a"
ssh puregift "cd opencat.org/opencourse/docroot/ && drush cr"

# update/cmi import
ssh puregift "cd opencat.org/opencourse/docroot/ && drush cim --source=../../cmi/ -y"
ssh puregift "cd opencat.org/opencourse/docroot/ && drush cr"

# out of maintenance mode
ssh puregift "cd opencat.org/opencourse/docroot/ && drush sset system.maintenance_mode FALSE"

# test again.
