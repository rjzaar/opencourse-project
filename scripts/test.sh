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





auto="no"
if [ -z "$2" ]
  then
    sn=$1
    bk=$1
    echo -e "\e[34mrestore $1 \e[39m"
   elif [ "$2" = "-y" ]
     then
        auto="yes"
        sn=$1
        bk=$1
        echo -e "\e[34mrestore $1 with latest backup\e[39m"
      else
        if [ "$3" = "-y" ]
        then
          bk=$1
          sn=$2
          echo -e "\e[34mrestoring $1 to $2 with latest backup\e[39m"
          auto="yes"
        else
          bk=$1
          sn=$2
          echo -e "\e[34mrestoring $1 to $2 \e[39m"
        fi
    fi

echo "sn = $sn bk = $bk auto = $auto"

if [ $auto = "yes" ]
then
  Name="hello"
  echo "Restoring with $Name"
else
echo "prompt"
fi
