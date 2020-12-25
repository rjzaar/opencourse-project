<?php

namespace Drupal\mailmerge_emails\Plugin\WebformHandler;

use Drupal\Core\Form\FormStateInterface;
use Drupal\node\Entity\Node;
use Drupal\media\Entity\Media;
use Drupal\file\Entity\File;
use Drupal\webform\Plugin\WebformHandlerBase;
use Drupal\webform\WebformSubmissionInterface;
use Drupal\Core\Mail\MailManagerInterface;
use Drupal\Component\Utility\SafeMarkup;
use Drupal\Component\Utility\Html;
/**
 * Mail merge from a webform submission.
 *
 * @WebformHandler(
 *   id = "Mailmerge emails",
 *   label = @Translation("Mailmerge emails"),
 *   category = @Translation("Entity Creation"),
 *   description = @Translation("Mail merge the selected emails"),
 *   cardinality = \Drupal\webform\Plugin\WebformHandlerInterface::CARDINALITY_UNLIMITED,
 *   results = \Drupal\webform\Plugin\WebformHandlerInterface::RESULTS_PROCESSED,
 *   submission = \Drupal\webform\Plugin\WebformHandlerInterface::SUBMISSION_REQUIRED,
 * )
 */

class MailMergeWebformHandler extends WebformHandlerBase {

  /**
   * {@inheritdoc}
   */

  // Function to be fired after submitting the Webform.
  public function postSave(WebformSubmissionInterface $webform_submission, $update = TRUE) {
    // Get an array of the values from the submission.
    $values = $webform_submission->getData();

    // Go through each of the selected politicians and email each.

    $mailManager = \Drupal::service('plugin.manager.mail');
    $module = 'mailmerge_emails_form_handler';
    $key = 'mail_merge'; // Replace with Your key
    $to = "rjzaar@gmail.com";
    $params['message'] = $values['enter_your_message_below'];
    $params['title'] = $values['subject_of_your_email'];
    $params['from'] = $values['email'];
    $langcode = \Drupal::currentUser()->getPreferredLangcode();
    $send = true;

    $result = $mailManager->mail($module, $key, $to, $langcode, $params, NULL, $send);
    if ($result['result'] != true) {
      $message = t('There was a problem sending your email notification to @email.', array('@email' => $to));
      drupal_set_message($message, 'error');
      \Drupal::logger('mail-log')->error($message);
      return;
    }

    $message = t('An email notification has been sent to @email ', array('@email' => $to));
    drupal_set_message($message);
    \Drupal::logger('mail-log')->notice($message);

//
//    $node_args = [
//      'type' => 'event',
//      'langcode' => 'en',
//      'created' => time(),
//      'changed' => time(),
//      'uid' => 1,
//      'moderation_state' => 'draft',
//      'title' => $values['event_name'],
//      'field_start_date' => $values['start_date'],
//      'field_end_date' => $values['end_date'],
//      'field_location' => $values['location'],
//      'field_website' => $values['website'],
//      'body' => [
//        'value' => $values['event_description'],
//        'format' => 'full_html'
//      ]
//    ];
//
//    $node = Node::create($node_args);
//    $node->save();
//
//    $node_fr = $node->addTranslation('fr');
//    $node_fr->title = $values['event_name'];
//    $node_fr->body->value = $values['event_description'];
//    $node_fr->body->format = 'full_html';
//    $node_fr->field_start_date = $values['start_date'];
//    $node_fr->field_end_date = $values['end_date'];
//    $node_fr->field_location = $values['location'];
//    $node_fr->field_website = $values['website'];
//    $node_fr->save();
  }
}
/**
 * Implements hook_mail().
 */
function mailmerge_emails_form_handler_mail($key, &$message, $params) {
$options = array(
  'langcode' => $message['langcode'],
);
  switch ($key) {
    case 'mail_merge':
      $message['from'] = $params['from'];
      $message['subject'] = t('Your mail subject Here: @title', array('@title' => $params['title']), $options);
      $message['body'][] = Html::escape($params['message']);
      break;
  }
}

