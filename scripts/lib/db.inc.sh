#!/bin/bash

set -e

db_command() {
  local __db_url="" && [ ! -z "$1" ] && __db_url=$1
  local __no_db=false && [ ! -z "$2" ] && __no_db=$2
  mysql_command=$($drush --root=$drop_docroot sql-connect --db-url=$__db_url)
  if [ "$__no_db" == true ]; then
    mysql_command=$(echo $mysql_command | sed 's/--database=[^-]*//g')
  fi
  echo $mysql_command
}

db_sql() {
  local __sql="" && [ ! -z "$1" ] && __sql=$1
  local __db_url="" && [ ! -z "$2" ] && __db_url=$2
  local __no_db=false && [ ! -z "$3" ] && __no_db=$3

  $(db_command "$__db_url" $__no_db) -A -e "$__sql"
}
