<?php
  $nids = \Drupal::entityQuery('node')
    ->condition('type', 'oc_doc')
    ->execute();
//$node = db_query(“select nid from node”)->fetchAll();

//Foreach ($nids as $nid) {
  $nid=890;
  $node      = \Drupal\node\Entity\NODE::load($nid);
  $videos = $node->field_oc_video->getValue();

  foreach ($videos as $video) {
    $content=$content.'<drupal-entity data-align="right" data-embed-button="media" data-entity-embed-display="view_mode:media.small"
                   data-entity-type="media" data-entity-uuid="'.$video->uuid().'"></drupal-entity>';
    
  }
  $node->save();
//}

// {{ node.uuid.0.value }}

// get list of all oc_docs

//For each oc_doc

//For each video

//Add the video according to
// <drupal-entity data-align="right" data-embed-button="media" data-entity-embed-display="view_mode:media.small" data-entity-type="media" data-entity-uuid="2cb25ace-c25f-408d-bec0-e022736e6394"></drupal-entity>

// Add the current content here

//External links
//For each link
// Add the link according to
//<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" data-entity-uuid="5fe0f2b6-e2c3-465a-904b-0ab77752c47f"></drupal-entity>


//Internal links
//For each doc
//Add the link accoring to
// <drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" data-entity-uuid="dd624427-4211-4a9a-9520-5c97c462aeb3"></drupal-entity>

//Save as the new body content



//old attempt
//This commented section is the start of trying to migrate videos etc into a single text field.
//  $videoinfo = [];
//  $nids = \Drupal::entityQuery('node')
//    ->condition('type', 'oc_doc')
//    ->execute();
//
// $variables['nids']=$variables['attributes'];
// if ( $variables['attributes']['id']= "block-oc-theme-content") {
//   $variables['nids']="yes";
//   //OK can get it to work here!
//   $nids = \Drupal::entityQuery('node')
//     ->condition('type', 'oc_doc')
//     ->execute();
//
//   $nid = 890;
//   $node      = \Drupal\node\Entity\NODE::load($nid);
//   $videos = $node->field_oc_video->getValue();
//   foreach ($videos as $video) {
//
//     $vnode = \Drupal\media_entity\Entity\Media::load($video['target_id']);
//     $videosarr[]  = $vnode;
//     $videoinfo[] = array('thumbnail' => $vnode->get('thumbnail'),'url' => $vnode->get('field_media_video_embed_field')->value);
////     ,'url' => $vnode->url()
////        $paragraph = Paragraph::create([
////          'title'          => $q,
////          'type'           => 'bp_simple',
////          'bp_text' => $q,
////        ]);
////        $paragraph->save();
////        $node->field_lp_paragraphs[] = $paragraph->id();
////        $node->paragraph_field_referenced->appendItem($paragraph);
//   }
//   $variables['videosarr']=$videosarr;
//   $variables['videos']=$videoinfo;
//
// }


