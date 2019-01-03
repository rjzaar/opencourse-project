#!/bin/bash
#testqa
#This will pull down the prod db and test it.
db="oc"
user="rob"

#restore qa db
cd
echo -e "\e[34mrestore qa database\e[39m"
mysqladmin -u $db -p$db -f drop $db;
echo -e "\e[34mrecreate database\e[39m"
mysql -u $db -p$db -e "CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;";
mysql -u $db -p$db $db < ocbackup/localdb/oc.sql




