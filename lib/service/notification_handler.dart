import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:overlay_support/overlay_support.dart';

class NotificationHandler {
  NotificationHandler._();

  /// FCM server key must NEVER be in client code. Use a backend (e.g. Cloud
  /// Functions) to send notifications. Pass via --dart-define only for local
  /// dev; rotate the key immediately if it was ever committed.
  String serverToken =
      String.fromEnvironment('FCM_SERVER_KEY', defaultValue: '');

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

      token = await fcm.getToken();
      initialized = true;
    }
    return token;
  }

  Future<void> sendMessage(title, body, nt) async {
    if (serverToken.isEmpty) return;
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
    if (serverToken.isEmpty) return;
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
