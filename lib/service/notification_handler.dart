import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';

class NotificationHandler {
  NotificationHandler._();

  String serverToken =
      'AAAAzy-D9pI:APA91bEEV7znT__t-8EMXD8e1ftgrOwMSscndEhe9VO5pXwJkowLe2NHLQE9BHNv0zUIQapQA_njS04khM5LMVQRbYevE9XXr74GcbXpFS5VU7mRAO2M2J2eBYbKCoKOOLTZmg8dZ6Tw';

  factory NotificationHandler() => instance;
  static final NotificationHandler instance = NotificationHandler._();
  final FirebaseMessaging fcm = FirebaseMessaging();
  bool initialized = false;
  String token;

  Future<String> init(context) async {
    if (!initialized) {
      fcm.requestNotificationPermissions();
      fcm.configure(onMessage: (message) async {
        showSimpleNotification(
          Text(
            message['notification']['body'],
          ),
          autoDismiss: true,
          background: Color(0xffffaf00),
          foreground: Colors.black,
          duration: Duration(seconds: 5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          position: NotificationPosition.bottom,
        );
      });

      // For testing purposes print the Firebase Messaging token
      token = await fcm.getToken();
      initialized = true;
    }
    return token;
  }

  Future<void> sendMessage(title, body, nt) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'message'
          },
          'to': nt,
        },
      ),
    );
  }

  Future<void> sendStage(title, body, nt, stage, orderId) async {
    await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': '$body', 'title': '$title'},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done',
            'type': 'stage',
            'stage': stage,
            'order_id': orderId
          },
          'to': nt,
        },
      ),
    );
  }
}
