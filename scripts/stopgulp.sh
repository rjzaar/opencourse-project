#!/bin/bash
# This will set the correct folder and file permissions for a drupal site.

# Help menu
print_help() {
cat <<-HELP
This script is used to kill any processes started by gulp.
HELP
exit 0
}
if [ "$1" = "-h" ]
then
print_help
exit 1
fi
 ps -ef | grep "browser-sync start"
 ps -ef | grep "gulp"
 echo "Now trying to stop the processes"
ps -ef | grep "browser-sync start" | awk '{print $2, $6}' | \
while read i
do
set $i
if [ "$2" == "?" ]
then
kill $1
fi
done
# ps -ef | grep "gulp"
ps -ef | grep "gulp" | awk '{print $2, $6}' | \
while read i
do
set $i
if [ "$2" == "?" ]
then
kill $1
fi
done
echo "Check to see if they have been stopped."
 ps -ef | grep "browser-sync start"
 ps -ef | grep "gulp"


