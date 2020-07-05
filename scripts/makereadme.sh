#!/bin/sh
# Generates a readme with all function documentation using --help flag and a
# README template located in docs folder

# Get the helper functions etc.
. $script_root/_inc.sh;

print_help() {
  cat << HEREDOC
Generates a readme with all function documentation using --help flag and a
README template located in docs folder. No flags required
HEREDOC
}

case $1 in
    -h|--help)
        print_help
        exit 0
        ;;
    ?*)
        ;;
esac



makereadme