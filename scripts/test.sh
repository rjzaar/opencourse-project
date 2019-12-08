#!/bin/bash
#
## Help menu
#print_help() {
#cat <<-HELP
#This script is used to overwrite localprod with the actual external production site.
#The choice of localprod is set in pl.yml under sites: localprod:
#The external site details are also set in pl.yml under prod:
#Note: once localprod has been locally backedup, then it can just be restored from there if need be.
#HELP
#exit 0
#}
#
#
## Now get the database
##This command wasn't fully working.
##drush -y sql-sync @prod @localprod -y
## This one does
#Namepath="$folderpath/sitebackups/localprod"
#Name="$folderpath/sitebackups/localprod/prod$(date +%Y%m%d\T%H%M%S-).sql"
#echo $Name
#drush @prod sql-dump  --gzip > "$Name.gz"
##mv local.sql.gz  "$Name.gz"
#gzip -d "$Name.gz"
#
#echo "db $db"
##Now import it
#result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $Name 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
#if [ "$result" = ": 0" ]; then echo "Production database imported into database localprodopencat using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi
#!/bin/bash

# This will set up pleasy and initialise the sites as per pl.yml, including the current production shared database.

# TODO?
# install drupal console: run in user home directory:
# composer require drupal/console:~1.0 --prefer-dist --optimize-autoloader


# This is needed to avoid the "awk: line 43: function asorti never defined" error


. "$script_root/_inc.sh"

parse_pl_yml

if [ $user="" ]
then
  echo "user empty"
  user="rob"
  project="opencat"
fi


#add github credentials
git config --global user.email $github_email
git config --global user.name $github_user


