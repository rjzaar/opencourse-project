#!/bin/bash


Color_Off='\033[0m'       # Text Reset

# Regular Colors
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan

echo -e "$Red hello red $Color_Off"
echo -e "hi again."
echo -e "$Green green $Color_Off"
sn=loc
install_locmodules=""
rp="install_${sn}modules"
rpv=${!rp}
if [ "$rpv" != "" ]
then
echo " $rp has value"
fi

if [[ ! -z "${"install_${sn}modules"+x}" ]]
then
echo " install_modules exits"
fi


rp="install"
rpv=${!rp}
if [ "$rpv" != "" ]
then
echo "$rp has value"
fi

if [[ ! -z "${install+x}" ]]
then
echo " install exits"
fi
