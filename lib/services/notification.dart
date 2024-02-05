import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart';

class NotificationApi {
  final message = FirebaseMessaging.instance;

  Future<void> sendNotification(
      String username, String msg, String token) async {
    final body = {
      "to": token,
      "notification": {
        "title": username,
        "body": msg,
        "android_channel_id": "chats"
      },
    };

    var res = await post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader:
            'key=AAAAmPDoatI:APA91bHo91Nc1wQjZflcoZwZK3vc_4jUFJ53MnwjVLJVF4eUcaxP1u4h72sgCSIJdhDMkDyduFPlsBSf-5Mq22jiytaMTlpq2dxaI0bUT1MSguspTSqzPqj_RqU1aV_oaZKOQStkuiGI'
      },
      body: jsonEncode(body),
    );
    print('Response status: ${res.statusCode}');
    print('Response body: ${res.body}');
  }
}
