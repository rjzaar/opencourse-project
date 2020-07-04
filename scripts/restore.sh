#!/bin/bash
################################################################################
#                       Restore site For Pleasy Library
#
#  This will restore files and database from a backup
#
#  Change History
#  2019 ~ 08/02/2020  Robert Zaar   Original code creation and testing,
#                                   prelim commenting
#  04/07/2020 Rob Zaar    Simplified and updated to new system.
#
################################################################################
################################################################################
#
#  Core Maintainer:  Rob Zaar
#  Email:            rjzaar@gmail.com
#
################################################################################
################################################################################
#                                TODO LIST
#
################################################################################
################################################################################
#                             Commenting with model
#
# NAME OF COMMENT (USE FOR RATHER SIGNIFICANT COMMENTS)
################################################################################
# Description - Each bar is 80 #, in vim do 80i#esc
################################################################################
#
################################################################################
################################################################################

# start timer
################################################################################
# Timer to show how long it took to run the script
################################################################################
SECONDS=0

#restore site and database
# $1 is the backup
# $2 if present is the site to restore into
# $sitename_var is the site to import into
# $bk is the backed up site.

# Set script name for general file use
scriptname='pleasy-restore'
verbose="none"

# Help menu
print_help() {
cat <<-HELP
Restore a particular site's files and database from backup
Usage: pl restore [FROM] [TO] [OPTION]
You just need to state the sitename, eg dev.
You can alternatively restore the site into a different site which is the second argument.

OPTIONS
  -h --help               Display help (Currently displayed)
  -d --debug              Provide debug information when running this script.
  -f --first              Usse the latest backup
  -y --yes                Auto delete current content

Examples:
pl restore loc
pl restore loc stg -fy
pl restore -h
pl restore loc -d
HELP
}

# Use of Getopt
################################################################################
# Getopt to parse script and allow arg combinations ie. -yh instead of -h
# -y. Current accepted args are -h and --help
################################################################################
args=$(getopt -a -o hdfy -l help,debug,first,yes --name "$scriptname" -- "$@")
# echo "$args"

echo "args: $args"

# Check number of arguments
################################################################################
# If no arguments given, prompt user for arguments
################################################################################
if [ "$#" = 0 ]; then
  print_help
  exit 0
fi

################################################################################
# Arguments are parsed by getopt, are then set back into $@
################################################################################
eval set -- "$args"

while true; do
  case "$1" in
  -h | --help)
    print_help
    exit 2 # works
    ;;
   -d | --debug)
  verbose="debug"
  shift
  ;;
  -f | --first)
  flag_first=1
  shift
  ;;
  -y | --yes)
  flag_auto=1
  shift
  ;;
  --)
    shift
    break
    ;;
  *)
    "Programming error, this should not show up!"
    exit 1
    ;;
  esac
done

parse_pl_yml

if [ $1 == "restore" ] && [ -z "$2" ]; then
    echo "No site specified"
    print_help
    exit 1
elif [ -z "$2" ]; then
  sitename_var=$1
  bk=$1
else
  sitename_var=$2
  bk=$1
fi

import_site_config $sitename_var

# Prompt to choose which database to backup, 1 will be the latest.
# Could be a better way to go: https://stackoverflow.com/questions/42789273/bash-choose-default-from-case-when-enter-is-pressed-in-a-select-prompt
cd
cd "$folder/sitebackups/$bk"
ocmsg "flag_first is $flag_first" debug
options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )
if [ $flag_first ]
then
  echo -e "\e[34mrestoring $1 to $2 with latest backup\e[39m"
  Name=${options[0]:2}
  echo "Restoring with $Name"
else
prompt="Please select a backup:"
PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit
    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $REPLY which is file ${opt:2}"
        Name=${opt:2}
        break
    else
        echo "Invalid option. Try another one."
    fi
done
fi

echo " site_path: $site_path/$sitename_var"
# Check to see if folder already exits.
if [ -d "$site_path/$sitename_var" ]; then
    if [ ! "$flag_yes" == "1" ]
    then
    read -p "$sitename_var exists. If you proceed, $sitename_var will first be deleted. Do you want to proceed?(Y/n)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    fi
    rm -rf "$site_path/$sitename_var"

fi
mkdir "$site_path/$sitename_var"
echo -e "\e[34mrestoring files\e[39m"
# Will need to first move the source folder ($bk) if it exists, so we can create the new folder $sitename_var
echo "path $site_path/$sitename_var folderpath $folderpath"
echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz into $site_path/$sitename_var"
# Check to see if the backup includes the root folder or not.
Dir_name=`tar -tzf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" | head -1 | cut -f1 -d"/"`
#echo "Dir_name = >$Dir_name<"
if [ $Dir_name == "." ]
then
tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C "$site_path/$sitename_var"
else
tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C "$site_path/$sitename_var" --strip-components=1
fi
# Move settings.php and settings.local.php out the way before they are overwritten just in case you might need them.
#echo "Moving settings.php and settings.local.php"
#setpath="$site_path/$sitename_var/$webroot/sites/default"
#if [ -f "$setpath/settings.php" ] ; then mv "$setpath/settings.php" "$setpath/settings.php.old" ; fi
#if [ -f "$setpath//settings.local.php" ] ; then mv "$setpath//settings.local.php" "$setpath/settings.local.php.old" ; fi
#if [ -f "$setpath//default.settings.php" ] ; then mv "$setpath//default.settings.php" "$setpath//settings.php" ; fi

### do I need to deal with services.yml?

pl fixss $sitename_var

echo "Set site permissions"
set_site_permissions $sitename_var

#restore db
db_defaults

restore_db

exit 0

# Old way
echo -e "\e[34mrestoring files\e[39m"
# Will need to first move the source folder ($bk) if it exists, so we can create the new folder $sitename_var
echo "path $site_path/$bk folderpath $folderpath"
if [ -d "$site_path/$bk" ]; then
    if [ -d "$site_path/$bk.tmp" ]; then
      echo "$site_path/$bk.tmp exits. There might have been a problem previously. I suggest you move $site_path/$bk.tmp to $site_path/$bk and try again."
      exit 1
    fi
    mv "$site_path/$bk" "$site_path/$bk.tmp"
    echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz"
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C $folderpath
    mv "$site_path/$bk" "$site_path/$sitename_var"
    mv "$site_path/$bk.tmp" "$site_path/$bk"
    else
    echo "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz  fp  $folderpath"
    tar -zxf "$folderpath/sitebackups/$bk/${Name::-4}.tar.gz" -C $folderpath
fi





