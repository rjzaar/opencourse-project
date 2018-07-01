#!/bin/bash
# This script 
# Rolls back migrations
# removes all current migrations from config, 
# removes the current custom migration module, 
# reinstalls it and 
# runs all working migrations
echo "Custom_migration script"
#dir="$1"
#cd ~/$dir/docroot

case $1 in
  install)
  ;;
  *)
	# Roll back if not just install
	echo "Rolling back migrations and uninstalling custom_migration"
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_books
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_media_image
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_link_groupcontent
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_image_groupcontent
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_book_groupcontent
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_doc_groupcontent
/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_sequence_groupcontent
        /home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_sequence
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_doc
#        /home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_doc
        /home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_book
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_image
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_node_formation_link
        /home/rob/.composer/vendor/bin/drush mr upgrade_d7_youtube
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_files
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_taxonomy_term_oc_authors 
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_taxonomy_term_formation_courses
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_user
	/home/rob/.composer/vendor/bin/drush mr upgrade_d7_user_role

	# script to remove currently installed migrations so the migration module can be reinstalled.
	#/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_user_picture_field')->delete();"
        /home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_media_image')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_image')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_link')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_taxonomy_term_formation_courses')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_taxonomy_term_oc_authors')->delete();"
	#/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_taxonomy_vocabulary')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_user')->delete();"
	/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_user_role')->delete();"
	#/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_user_picture_entity_display')->delete();"
	#/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_user_picture_entity_form_display')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_file_private')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_files')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_book')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_doc')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_doc2')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_sequence')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_youtube')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_books')->delete();"	
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_book_groupcontent')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_doc_groupcontent')->delete();"
/home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_sequence_groupcontent')->delete();"
        /home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_image_groupcontent')->delete();"
        /home/rob/.composer/vendor/bin/drush ev "Drupal::configFactory()->getEditable('migrate_plus.migration.upgrade_d7_node_formation_link_groupcontent')->delete();"
/home/rob/.composer/vendor/bin/drush pm-uninstall -y custom_migration
	/home/rob/.composer/vendor/bin/drush cr
  ;;
esac
echo "Installing custom_migration and running basic migratations."
/home/rob/.composer/vendor/bin/drush en -y custom_migration
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_user_role
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_user
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_taxonomy_term_formation_courses
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_taxonomy_term_oc_authors 
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_files
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_youtube
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_link
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_image
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_book
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_doc
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_sequence
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_link_groupcontent
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_image_groupcontent
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_book_groupcontent
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_formation_doc_groupcontent
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_node_sequence_groupcontent
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_books
/home/rob/.composer/vendor/bin/drush mim upgrade_d7_media_image
