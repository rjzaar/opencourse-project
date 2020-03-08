#!/bin/bash

# This will reset the defaults in the plextras.sh file. This is useful if you have done a git pull of pleasy and
# overwritten your default locations in plextras.sh.

echo running include files...
. "$script_root/_inc.sh"
echo parsing yml
echo "location: $folderpath/pl.yml"
if [ ! -f "$folderpath/pl.yml" ] ; then echo " Please copy example.pl.yml to pl.yml and modify. exiting. "; exit 1 ; fi

parse_pl_yml

#echo "wwwpath $www_path"

echo -e "$Cyan Adding pl command to bash commands, including plextras $Color_Off"
# Check correct user name
if [ ! -d "/home/$user" ] ; then echo "User name in pl.yml $user does not match the current user's home directory name. Please fix pl.yml."; exit 1; fi

schome="/home/$user/$project/bin"
sed -i "2s/.*/ocroot=\"\/home\/$user\/$project\"/" "$schome/plextras.sh"
#sed -i "3s/.*/ocroot=\"\/home\/$user\/$project\"/" "$schome/plextras.sh"
wwwp="${www_path////\\/}"
sed -i  "3s/.*/ocwroot=\"$wwwp\"/" "$schome/plextras.sh"
sr="${script_root////\\/}"
sed -i "4s/.*/script_root=\"$sr\"/" "$schome/plextras.sh"

