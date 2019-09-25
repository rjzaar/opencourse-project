#!/usr/bin/env bash

prompt="Please select a backup:"
cd
cd ocbackup/localdb

options=( $(find -maxdepth 1 -name "*.sql" -print0 | xargs -0 ls -1 -t ) )

PS3="$prompt "
select opt in "${options[@]}" "Quit" ; do
    if (( REPLY == 1 + ${#options[@]} )) ; then
        exit

    elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
        echo  "You picked $REPLY which is file ocbackup/localdb/${opt:2}"
        break

    else
        echo "Invalid option. Try another one."
    fi
done
Name=${opt:2}
echo -e "\e[34mbackup files ${Name::-4}.tar.gz\e[39m"