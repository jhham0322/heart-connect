import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/foundation.dart';

class SmsSender {
  
  /// Sends an SMS to a list of phone numbers with a message.
  /// Note: Attachments (images) are not supported via 'sms:' scheme.
  Future<void> sendBatchSms(List<String> phoneNumbers, String message) async {
    if (phoneNumbers.isEmpty) return;

    // chunking logic is usually handled by the caller, but strictly for the intent:
    final separator = (defaultTargetPlatform == TargetPlatform.android) ? ',' : '&';
    final recipients = phoneNumbers.join(separator);
    
    // Encode the query parameters
    final uri = Uri(
      scheme: 'sms',
      path: recipients,
      queryParameters: {
        'body': message,
      },
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw Exception('Could not launch SMS app');
    }
  }
}
