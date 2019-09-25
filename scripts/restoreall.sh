#!/bin/bash
#restore STG database (or earlier backups).

db="oc"
user="rob"

# Prompt to choose which database to backup, 1 will be the latest.
prompt="Please select a backup:"
cd
cd ocbackup/localdb

options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )

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


#restore files
cd
if [ -d "opencat" ]; then
    read -p "opencat exists. If you proceed, opencat will first be deleted. Do you want to proceed?(y/n/c)" question
        case $question in
            n|c|no|cancel)
            echo exiting immediately, no changes made
            exit 1
            ;;
        esac
    rm -rf opencat
fi
echo -e "\e[34mrestoring files\e[39m"
tar -zxf ocbackup/devallfiles/${Name::-4}".tar.gz"
echo -e "\e[34msetting correct permissions - will require sudo password\e[39m"
chown $user:www-data opencat -R
sudo bash ./opencat/scripts/d8fp.sh --drupal_path=opencat/opencourse/docroot --drupal_user=$user
chmod g+w opencat/private -R

#restore stg db
cd
echo -e "\e[34mdrop current database\e[39m"
mysqladmin -u $db -p$db -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $db -p$db -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
echo -e "\e[34mrestore stg database\e[39m"
mysql -u $db -p$db $db < ocbackup/localdb/${opt:2}






