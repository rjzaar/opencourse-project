#!/bin/bash

# Help menu
print_help() {
cat <<-HELP
This script is used to overwrite localprod with the actual external production site.
The choice of localprod is set in oc.yml under sites: localprod:
The external site details are also set in oc.yml under prod:
Note: once localprod has been locally backedup, then it can just be restored from there if need be.
HELP
exit 0
}


# Now get the database
#This command wasn't fully working.
#drush -y sql-sync @prod @localprod -y
# This one does
Namepath="$folderpath/sitebackups/localprod"
Name="$folderpath/sitebackups/localprod/prod$(date +%Y%m%d\T%H%M%S-).sql"
echo $Name
drush @prod sql-dump  --gzip > "$Name.gz"
#mv local.sql.gz  "$Name.gz"
gzip -d "$Name.gz"

echo "db $db"
#Now import it
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $Name 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Production database imported into database localprodopencat using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi



