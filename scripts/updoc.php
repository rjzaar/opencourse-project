<?php
$nids = \Drupal::entityQuery('node')
  ->condition('type', 'oc_doc')
  ->execute();
$content="";
//$node = db_query(“select nid from node”)->fetchAll();
$file_storage = \Drupal::entityTypeManager()->getStorage('media_type');


Foreach ($nids as $nid) {
  print $nid." ";
  $node = \Drupal\node\Entity\NODE::load($nid);
  $content="";


  //}

  // {{ node.uuid.0.value }}

  // get list of all oc_docs

  //For each oc_doc

  //For each video
  $videos = $node->field_oc_video->getValue();
  foreach ($videos as $video) {
    $fid = implode($video);
    $vfile = \Drupal\media\Entity\MEDIA::load($fid);
    $content = $content . '<drupal-entity data-align="right" data-embed-button="media" data-entity-embed-display="view_mode:media.small"
                   data-entity-type="media" data-entity-uuid="' . $vfile->uuid() . '"></drupal-entity>';
  }
  //Add the video according to
  // <drupal-entity data-align="right" data-embed-button="media" data-entity-embed-display="view_mode:media.small" data-entity-type="media" data-entity-uuid="2cb25ace-c25f-408d-bec0-e022736e6394"></drupal-entity>

  // Add the current content here
  $content = $content . $node->body->value;
  //External links
  //For each link
  $enodes = $node->field_oc_external_links->getValue();

  if (  !is_null($enodes[0]['target_id']) ) {
    $content = $content . "External links<br>";
  }

  foreach ($enodes as $enode) {

    $exid = $enode['target_id'];
    $exnode = \Drupal\node\Entity\NODE::load($exid);
    $content = $content . '<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node"
 data-entity-uuid="' . $exnode->uuid() . '"></drupal-entity>';
  }
  // Add the link according to
  //<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" data-entity-uuid="5fe0f2b6-e2c3-465a-904b-0ab77752c47f"></drupal-entity>


  //Internal links

  //For each doc
  //Add the link accoring to
  $inodes = $node->field_oc_internal_links->getValue();
  if (  !is_null($inodes[0]['target_id']) ) {
    $content = $content . "Internal links<br>";
  }
  foreach ($inodes as $inode) {
    $iid = $inode['target_id'];
    $inode = \Drupal\node\Entity\NODE::load($iid);
    $content = $content . '<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded"
 data-entity-type="node" data-entity-uuid="' . $inode->uuid() . '"></drupal-entity>';
  }
  // <drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" data-entity-uuid="dd624427-4211-4a9a-9520-5c97c462aeb3"></drupal-entity>

  //Save as the new body content
  //print $content;
  $node->body->value = $content;
  $node->save();

}



#echo "db $db dbuser $dbuser dbpass $dbpass"
#
#RESULT=`mysqlshow --user=$dbuser --password=$dbpass $db| grep -v Wildcard | grep -o $db`
#if [ "$RESULT" == "$db" ]; then
#    echo "yes"
#    else
#    echo "No"
#fi

# ../scripts/d8fp.sh  --drupal_path=docroot --drupal_user=rob