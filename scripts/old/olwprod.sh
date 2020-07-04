#!/bin/bash
################################################################################
#                         olwprod For Pleasy Library
#
#  This script is used to overwrite localprod with the actual external
#  production site.  The choice of localprod is set in pl.yml under sites:
#  localprod: The external site details are also set in pl.yml under prod:
#  Note: once localprod has been locally backedup, then it can just be restored
#  from there if need be.
#
#  Change History
#  2019 - 2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  2020 James Lim  Getopt parsing implementation, script documentation
#  [Insert New]
#
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################

# Set script name for general file use
scriptname='pleasy-olwprod'

# Help menu
################################################################################
# Prints user guide
################################################################################
print_help() {
cat << HEREDOC

Usage: pl olwprod [OPTION] ... [SITE]
This script is used to overwrite localprod with the actual external production
site.  The choice of localprod is set in pl.yml under sites: localprod: The
external site details are also set in pl.yml under prod: Note: once localprod
has been locally backedup, then it can just be restored from there if need be.

Mandatory arguments to long options are mandatory for short options too.
  -h --help               Display help (Currently displayed)

Examples:
END HELP
HEREDOC
exit 0
}

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -o h -l help --name "$scriptname" -- "$@")

################################################################################
# If getopt outputs error to error variable, quit program displaying error
################################################################################
[ $? -eq 0 ] || {
    echo "please do 'pl olwprod --help' for more options"
    exit 1
}

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

################################################################################
# Case through each argument passed into script
# If no argument passed, default is -- and break loop
################################################################################
while true; do
  case "$1" in
  -h | --help)
    print_help; exit 0; ;;
  --)
    shift
    break; ;;
  *)
    "Programming error, this should not show up!"
    exit 1; ;;
  esac
done

parse_pl_yml
sitename_var="$sites_localprod"
echo "Importing production site into $sitename_var"

import_site_config $sitename_var

#First backup the current localprod site.
pl backup $sitename_var "presync"

#pull db and all files from prod
### going to need to fix security. settings.local.php only have hash. all other cred in settings so not shared.
echo "pre rsync"
drush -y rsync @prod @$sitename_var -- --omit-dir-times --delete
echo "post first rsync"
pl fixss $sitename_var
drush -y rsync @prod:../private @$sitename_var:../private -- --omit-dir-times  --delete
drush -y rsync @prod:../cmi @$sitename_var:../cmi -- --omit-dir-times  --delete

echo "Make sure the hash is present so drush sql will work."
# Make sure the hash is present so drush sql will work.
sfile=$(<"$site_path/$sitename_var/$webroot/sites/default/settings.php")
slfile=$(<"$site_path/$sitename_var/$webroot/sites/default/settings.local.php")
if [[ ! $sfile =~ (\'hash_salt\'\] = \') ]]
then
if [[ ! $slfile =~ (\'hash_salt\'\] = \') ]]
then
  hash=$(drush php-eval 'echo \Drupal\Component\Utility\Crypt::randomBytesBase64(55)')
echo "\$settings['hash_salt'] = '$hash';" >> "$site_path/$sitename_var/$webroot/sites/default/settings.local.php"
fi
fi

# Now get the database
#This command wasn't fully working.
# This one does
echo "Now get the database"
Name="prod$(date +%Y%m%d\T%H%M%S-).sql"
Namepath="$folderpath/sitebackups/localprod"
SFile="$folderpath/sitebackups/localprod/$Name"
# The next 2 commands don't work...
#drush @prod sql-dump  --gzip > "$SFile.gz"
#gzip -d "$SFile.gz"
# So try this instead
drush @prod sql-dump --gzip --result-file="../../../$Name"
scp cathnet:"$Name.gz" "$Namepath/$Name.gz"
gzip -d "$Namepath/$Name.gz"



#Now import it
result=$(mysql --defaults-extra-file="$folderpath/mysql.cnf" localprodopencat < $SFile 2>/dev/null | grep -v '+' | cut -d' ' -f2; echo ": ${PIPESTATUS[0]}")
if [ "$result" = ": 0" ]; then echo "Production database imported into database $db using root"; else echo "Could not import production database into database $db using root, exiting"; exit 1; fi

drush @localprod cr

pl backup $sitename_var "postsync"

# Make sure url is setup and open it!
pl sudoeuri localprod
pl open localprod
# End timer
################################################################################
# Finish script, display time taken
################################################################################
echo 'Finished in H:'$(($SECONDS/3600))' M:'$(($SECONDS%3600/60))' S:'$(($SECONDS%60))
exit 0
