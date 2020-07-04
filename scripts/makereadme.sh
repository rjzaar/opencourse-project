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
        echo "View help with --help";

        ;;
esac

if [ -d $script_root ]; then
    cd "$script_root"
else
    echo 'ERROR: Either pleasy $script_root variable does not exist, or the value is set incorrectly.'
    exit 1
fi

if [ ! -f ../docs/README_TEMPLATE.md ]; then
    echo "Need a template file README_TEMPLATE.md in pleasy docs folder!"; exit 1
fi

cp ../docs/README_TEMPLATE.md ../README_TEMPLATE.md

(
documented_scripts=$(grep -l --directories=skip --exclude=makereadme*.sh '^args=$(getopt' *.sh)
undocumented_scripts=$(grep -L --directories=skip --exclude=makereadme*.sh '^args=$(getopt' *.sh)
working_dir=$(pwd)

for command in $documented_scripts; do
    help_documentation=$("$working_dir/$command" --help)
    echo $help_documentation | grep -q '^Usage:' && \
        sanitised_documentation=$help_documentation || \
        sanitised_documentation=$(cat <<HEREDOC
--**BROKEN DOCUMENTATION**--
$help_documentation
--**BROKEN DOCUMENTATION**--
HEREDOC
)

    cat <<HEREDOC
<details>

**<summary> pl ${command%%.sh} :white_check_mark: </summary>**
$sanitised_documentation

</details>

HEREDOC
done

for command in $undocumented_scripts; do
    cat <<HEREDOC
<details>

**<summary> pl ${command%%.sh} :question: </summary>**
**DOCUMENTATION NOT IMPLEMENTED**

</details>

HEREDOC
done
) >> ../README_TEMPLATE.md || \
    { echo "Failed to write to copied template file! aborting";
    rm ../README_TEMPLATE.md;
    exit 1; }

mv ../README_TEMPLATE.md ../README.md
echo "Functions and definitions have been generated"