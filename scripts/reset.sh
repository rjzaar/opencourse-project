#!/bin/bash
# This task must be run by pl "task name" arguments
if [ -z $folder ]
then
echo "This task must be run by putting pl before it and no .sh, eg pl reset"
exit 1
fi
parse_oc_yml



