<?php
  $nids = \Drupal::entityQuery('node')
    ->condition('type', 'oc_doc')
    ->execute();
  $content="";
//$node = db_query(“select nid from node”)->fetchAll();

//Foreach ($nids as $nid) {
$nid="890";
  $node      = \Drupal\node\Entity\NODE::load($nid);
  $videos = $node->field_oc_video->getValue();
  foreach ($videos as $video) {

    $vid1 = \Drupal\media_entity\Entity\Media::load($video{"target_id"});
        $content=$content.'<drupal-entity data-align="right" data-embed-button="media" data-entity-embed-display="view_mode:media.small"
                   data-entity-type="media" data-entity-uuid="'.$vid1->uuid().'"></drupal-entity>';
  }

  $body1 = $node->body->getValue();
  $content=$content.$body1[0]['value'];
  $external = $node->field_oc_external_links->getValue();
  $content=$content."External Links</br>";
  foreach ($external as $elink){


    $exlink = \Drupal\node\Entity\NODE::load($elink{"target_id"});

    $content=$content.'<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" 
data-entity-uuid="'.$exlink->uuid().'"></drupal-entity>';

  }
  $external = $node->field_oc_internal_links->getValue();

  $content=$content."Internal Links</br>";
  foreach ($external as $elink) {


    $exlink = \Drupal\node\Entity\NODE::load($elink{"target_id"});


    $content = $content.'<drupal-entity data-embed-button="node" data-entity-embed-display="view_mode:node.embeded" data-entity-type="node" 
data-entity-uuid="'.$exlink->uuid().'"></drupal-entity>';
  }

 // }
$node->body->setValue($content);
  $node->save();
//}