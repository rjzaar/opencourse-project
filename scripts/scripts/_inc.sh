#!/bin/bash
# set -e

[ "$DEBUG" = "true" ] && debug_mode=true

DROP_TYPE_DOCROOT="docroot"

DROP_TYPE_CONFIGFILE="configfile"

drop_config_init () {
	local _config_path=$1

	drop_config_set_defaults

	if [ -d $_config_path ]; then

		drop_type=DROP_TYPE_DOCROOT
		drop_root=$(_get_abs_path $_config_path)
		config_drupal_docroot=$drop_root

  else

		drop_type=DROP_TYPE_CONFIGFILE
		[ "$_config_path" = "--" ] && _config_path="./oc.yml"
		drop_root=$(_get_dir_path $_config_path)

		drop_read_config $_config_path

		drop_config_set_variables

  fi



}

# Config defaults set before is processed
drop_config_set_defaults () {
	# Set default configs and variables
	config_profile_name="" # Mandatory
	config_php_alias="php"
	config_drush_alias="drush"

	config_git_alias="git"
	config_git_path="git"

	config_drupal_docroot="_build"
	config_drupal_url=""
}

# Variables to be used across drop scripts.
# Calculated after config is processed
drop_config_set_variables() {
	# FIXME alias is treated as path. needs to be fixed.
	drop_docroot=$config_drupal_docroot
	drush=$config_drush_alias
	php=$config_php_alias
	git=$config_git_path
}

drop_config_set_docroot () {
	local docroot=$1
	config_drupal_docroot=$docroot
	drop_docroot=$config_drupal_docroot
}

drop_read_config () {
	local _config_path=$1

	# Initialise config file
	[ "$task" = "init" ] && cp $script_root/oc.yml $_config_path

	# Make sure the file exists
	_config_path=$(_get_abs_path $_config_path)
	[ ! -e "$_config_path" ] && echo "Config file could not be found at $config_path. To create one please @see example.config.yml" && exit 1


	cd $drop_root

	config_profile_path=$drop_root/profile
	config_profile_makefile="stub.make"
	config_install_features_revert_all=false
	config_install_rebuild_permissions=true
	config_install_print_uli=false
	config_build_symlink_to_profile=false
	config_install_settingsphp_generate=true

	# Read local config variables
	_load_config_file $config_path

	# Validate config variables:
	[ "$config_install_db_dump" = "true" ] && [[ ! -e $config_install_db_dump ]] && echo "Database dump not found at "$config_install_db_dump && exit 1
	[[ $config_build_files ]] && [[ ! -d $config_build_files ]] && echo "Could not locate specified files directory at"$config_build_files && exit 1
	[ "$config_install_post_script" ] && [[ ! -s $config_install_post_script ]] && echo "Could not locate post-install script at "$config_install_post_script && exit 1

	config_build_sitesdir=$(_get_abs_path $config_build_sitesdir)
	config_build_source=$(_get_abs_path $config_build_source)
	config_install_post_script=$(_get_abs_path $config_install_post_script)

	[ ! -z "$config_git_path" ] && alias git="$config_git_alias"

}

_load_config_file() {
	local _config_path=$1
	local _config_base_path=""
	local _config_prefix="config_"
	config_base=""
	. $script_root/scripts/parse_yaml.sh $_config_path $_config_prefix
	# If there is a base config we need to reload them both again
	if [ "$_load_config__load_base_disallowed" != "true" ] && [ "$config_base" ]
		then
		_config_base_path=$root/$config_base
		if [ ! -e "$_config_base_path" ]
			then
			echo "Base config file could not be faound at $_config_base_path (defined at $_config_path)"
			exit 1
		elif [ "$_config_base_path" = "$_config_path" ]; then
			echo "Config file cannot use itself as base. ($_config_path)"
			exit 1
		fi
		_load_config_file $_config_base_path
		# We make sure that we do not recursively load its base!
		_load_config__load_base_disallowed="true"
		_load_config_file $_config_path
	fi
}
_validate_profile() {
	# Finalize config variables
	if [ ! -e "$config_build_profile_path/$config_profile_name.info" ]
		then
		echo "Profile $config_profile_name not found at $config_build_profile_path"
		exit 1
	fi
}
_validate_makefile() {
	if [ ! -e "$config_makefile_path" ]
		then
		echo "Makefile not found at "$config_makefile_path
		exit 1
	fi
	config_makefile_path=$(_get_abs_path $config_makefile_path)
}

# put this before any command at it prints it to the screen before running it
debug() {
	command="$@"
	[ "$debug_mode" ] && echo "--> $command"
	$command
}

_exec_script() {
	path=$(_get_abs_path $1)
	cd $(dirname $path)
	. $(basename $path)
}

# should only be used for files which are supposed to exists
_get_abs_path() {
	[ ! -e "$1" ] && echo "" && exit
	echo $(cd $(dirname $1) && pwd)"/"$(basename $1)
}
_get_dir_path() {
	echo $(dirname $(_get_abs_path $1))
}
_config_review() {
	echo "Configuration summary:"
	echo "----------------------"
	echo "Profile name:" $config_profile_name
	echo "Profile path:" $config_profile_path
	echo "Makefile path:" $config_makefile_path
	echo "Build path:" $drop_docroot
	echo "Files directory path:" $config_build_files
	echo "Database URL:" $config_install_db_url
	echo "Database dump:" $config_install_db_dump
	echo "Revert all features:" $config_install_reatures_revert_all
	echo "Post-install script:" $([ -s "$config_install_post_script" ] &&  echo $config_install_post_script || echo "N/A")
	echo "----------------------"
}

_config_confirm() {
	if [ ! $(read -p "Are you sure? [y/n] ") = "y" ]
		then
		exit 1
	fi
}
