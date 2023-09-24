// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:awesome_notifications/awesome_notifications_platform_interface.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/Screens/requests/request_screen.dart';
import 'package:newchatapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../Screens/message_screen.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

// after this create a method initialize to initialize  localnotification

  static void initialize() {
    // initializationSettings  for Android
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static sendPushMessage(
      String body, String title, String token, String image, String uid) async {
    try {
      print('sending');
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'key= AAAA6R6Un_8:APA91bEOcTvVCpR0SUIDcRB3TIobJdGtNgHbCDWsovhcxRXRTh5rvtHCthJlnUh2UES30LvNO785OZEGcyNwCGUMYkBEKOHPYa817eIQVTifeY6HuGLYG50q3MaZQKGnXTdPxwnbsbw3 ',
              },
              body: json.encode({
                "pirority": "high",
                "registration_ids": [
                  token,
                  // "cxDaTRu1T-eMCVEBycQAuj:APA91bFHXtHF20bGBRNVOcNKJ9hpxpSdjBbWL9QN0Es79hi4i_VpBlUYu8aNNHDovxibTvnIdu5EPmd6-85qbgtFUimiim6FfwTeieehy8_sUs_w7UNacJYRFq9wxWJVnEfVy9KhVhfM"
                ],
                "notification": {
                  "body": body,
                  "title": title,
                  "android_channel_id": "flutterNotification",
                  "sound": false
                },
                "data": {
                  'image': image,
                  'uid': uid,
                }
              }));
      print('sent ${response.statusCode}and ${response.request}');
    } catch (e) {
      print(e.toString());
    }
  }

/////////////////////////for audio/////////////////////////////////
  static sendPushAudio(
      String body, String title, String token, String imageurl) async {
    try {
      print('sending');
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'key= AAAA6R6Un_8:APA91bEOcTvVCpR0SUIDcRB3TIobJdGtNgHbCDWsovhcxRXRTh5rvtHCthJlnUh2UES30LvNO785OZEGcyNwCGUMYkBEKOHPYa817eIQVTifeY6HuGLYG50q3MaZQKGnXTdPxwnbsbw3 ',
              },
              body: json.encode({
                "pirority": "high",
                "registration_ids": [
                  token,
                  // "cxDaTRu1T-eMCVEBycQAuj:APA91bFHXtHF20bGBRNVOcNKJ9hpxpSdjBbWL9QN0Es79hi4i_VpBlUYu8aNNHDovxibTvnIdu5EPmd6-85qbgtFUimiim6FfwTeieehy8_sUs_w7UNacJYRFq9wxWJVnEfVy9KhVhfM"
                ],
                "notification": {
                  "body": body,
                  "title": title,
                  "image": imageurl,
                  "android_channel_id": "flutterNotification",
                  "sound": false
                }
              }));
      print('sent ${response.statusCode}and ${response.request}');
    } catch (e) {
      print(e.toString());
    }
  }

  static sendcallInvitation(
    String body,
    String title,
    String token,
    String uid,
    String callId,
    String status,
    String image,
    String name,
    String email,
    String name1,
    String image1,
    String type1,
  ) async {
    try {
      print('sending');
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'key= AAAA6R6Un_8:APA91bEOcTvVCpR0SUIDcRB3TIobJdGtNgHbCDWsovhcxRXRTh5rvtHCthJlnUh2UES30LvNO785OZEGcyNwCGUMYkBEKOHPYa817eIQVTifeY6HuGLYG50q3MaZQKGnXTdPxwnbsbw3 ',
              },
              body: json.encode({
                "pirority": "high",
                "registration_ids": [
                  token,
                  // "cxDaTRu1T-eMCVEBycQAuj:APA91bFHXtHF20bGBRNVOcNKJ9hpxpSdjBbWL9QN0Es79hi4i_VpBlUYu8aNNHDovxibTvnIdu5EPmd6-85qbgtFUimiim6FfwTeieehy8_sUs_w7UNacJYRFq9wxWJVnEfVy9KhVhfM"
                ],
                "notification": {
                  "body": body,
                  "title": title,
                  // "android_channel_id": "flutterNotification",
                  // "sound": true
                },
                "data": {
                  "type": 'call',
                  "uid": uid,
                  "callId": callId,
                  "image1": image1,
                  "name1": name1,
                  "type1": type1,
                  "image": image,
                  "email": email,
                  "name": name,
                  "status": status,
                }
              }));
      print('sent ${response.statusCode}and ${response.request}');
    } catch (e) {
      print(e.toString());
    }
  }

///////////////////////////////////////////////////////////
  static sendPushImage(
      String body, String title, String token, String imageUrl) async {
    try {
      print('sending');
      final response =
          await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization':
                    'key= AAAA6R6Un_8:APA91bEOcTvVCpR0SUIDcRB3TIobJdGtNgHbCDWsovhcxRXRTh5rvtHCthJlnUh2UES30LvNO785OZEGcyNwCGUMYkBEKOHPYa817eIQVTifeY6HuGLYG50q3MaZQKGnXTdPxwnbsbw3 ',
              },
              body: json.encode({
                "pirority": "high",
                "registration_ids": [
                  token,
                  // "cxDaTRu1T-eMCVEBycQAuj:APA91bFHXtHF20bGBRNVOcNKJ9hpxpSdjBbWL9QN0Es79hi4i_VpBlUYu8aNNHDovxibTvnIdu5EPmd6-85qbgtFUimiim6FfwTeieehy8_sUs_w7UNacJYRFq9wxWJVnEfVy9KhVhfM"
                ],
                "notification": {
                  "body": body,
                  "title": title,
                  "image": imageUrl,
                  "android_channel_id": "flutterNotification",
                  "sound": false
                }
              }));
      print('sent ${response.statusCode}and ${response.request}');
    } catch (e) {
      print(e.toString());
    }
  }

///////////////////////////////////////////////////////////
  static void createanddisplaynotification(RemoteMessage message) async {
    try {
      final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      NotificationDetails notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          "flutterNotification",
          "flutterNotificationchannel",
          // 'Task',
          // styleInformation:StyleInformation(

          // ),
          // usesChronometer: true,

          importance: Importance.max,
          priority: Priority.high,
          // tag: 'Hassan',/
          // ongoing: true,
          fullScreenIntent: true,
          // autoCancel: false,
          // color: Colors.blue,
          // largeIcon:AndroidBitmap()
          //     'https://th.bing.com/th/id/OIP.hxRValICG6OlXI56NUfSjAHaF1?w=223&h=180&c=7&r=0&o=5&dpr=1.6&pid=1.7',
          // audioAttributesUsage:
          //     AudioAttributesUsage.voiceCommunicationSignalling,
          enableLights: true,

          // colorized: true,
        ),
      );

      await _notificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,
        payload: message.data['_id'],
      );
    } on Exception catch (e) {
      print(e);
    }
  }

  static showMessageNotification(RemoteMessage message) async {
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    /// Use this method to detect when the user taps on a notification or action button

    // AwesomeNotifications().a
  }

  @pragma('vm:entry-point')
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    Firebase.initializeApp();
    log('received Call True');
    var Usersnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('calls')
        .doc(Usersnap.data()!['callId'])
        .update({
      'status': 'ringing',
    });
    FirebaseFirestore.instance
        .collection('users')
        .doc(Usersnap.data()!['callUid'])
        .collection('calls')
        .doc(Usersnap.data()!['callId'])
        .update({
      'status': 'ringing',
    });
    Future.delayed(Duration(seconds: 30)).then((value) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'missed',
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Usersnap.data()!['callUid'])
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'missed',
      });
    });
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    Firebase.initializeApp();
    var Usersnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (receivedAction.buttonKeyPressed == 'Accept') {
      GetStorage().write('incoming call', 'true');
      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setBool('incoming call', true);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'callAccept': true,
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'accept',
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Usersnap.data()!['callUid'])
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'accept',
      });
      AwesomeNotifications().cancel(124);
      pref.setBool('incoming call', true);

      log('pref incoming noti: ${pref.getBool('incoming call').toString()}');
    } else if (receivedAction.buttonKeyPressed == 'Declined') {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'call': false,
        'callId': '',
        'callUid': '',
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'declined',
      });
      FirebaseFirestore.instance
          .collection('users')
          .doc(Usersnap.data()!['callUid'])
          .collection('calls')
          .doc(Usersnap.data()!['callId'])
          .update({
        'status': 'declined',
      });
      AwesomeNotifications().cancel(124);
    }
  }
}
