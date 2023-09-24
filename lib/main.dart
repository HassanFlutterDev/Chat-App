// ignore_for_file: prefer_const_constructors, unused_local_variable, unused_import

import 'dart:developer';
// import 'dart:js';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';

import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newchatapp/Screens/call_screen.dart';
import 'package:newchatapp/Screens/calling/outgoing_call.dart';
import 'package:newchatapp/Screens/camera_screen.dart';
import 'package:newchatapp/Screens/home_screen.dart';
import 'package:newchatapp/Screens/requests/request_screen.dart';
import 'package:newchatapp/Screens/welcome_Screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'Functions/Auth/auth_functions.dart';
import 'Functions/notifications/notifications.dart';

String callId = '';
bool call = false;
String uid = '';
String name = '';
void listenCall(String uid, String callId) {}
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  //-- if caling
  // var isCalling = message.data['isCalling'];

  print('isCalling------>>>>>>>.');
  await Firebase.initializeApp();

  SharedPreferences pref = await SharedPreferences.getInstance();

  callId = message.data['callId'];
  if (message.data['type'] == 'call') {
    if (message.data['type1'] == 'Missed') {
      await FlutterCallkitIncoming.endCall(callId);
      String _currentUuid = Uuid().v4();
      CallKitParams params = CallKitParams(
        id: _currentUuid,
        nameCaller: message.data['name'],
        handle: 'Missed Call',
        avatar: message.data['image'],
        type: 0,
        missedCallNotification: NotificationParams(
          showNotification: true,
          isShowCallback: false,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
      );
      await FlutterCallkitIncoming.showMissCallNotification(params);
    } else {
      CallKitParams callKitParams = CallKitParams(
        id: callId,
        nameCaller: message.data['name'],
        appName: 'Connect Me',
        avatar: message.data['image'],
        handle: message.data['type1'] == 'voice' ? 'Voice Call' : 'Video Call',
        type: message.data['type1'] == 'voice' ? 0 : 1,
        textAccept: 'Accept',
        textDecline: 'Decline',
        missedCallNotification: NotificationParams(
          showNotification: true,
          isShowCallback: false,
          subtitle: 'Missed call',
          callbackText: 'Call back',
        ),
        duration: 30000,
        extra: <String, dynamic>{'userId': '1a2b3c4d'},
        headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
        android: AndroidParams(
            isCustomSmallExNotification: true,
            isCustomNotification: true,
            isShowLogo: false,
            ringtonePath: 'system_ringtone_default',
            backgroundColor: '#080808',
            backgroundUrl: message.data['image'],
            actionColor: '#18c446',
            incomingCallNotificationChannelName: "Incoming Call",
            missedCallNotificationChannelName: "Missed Call"),
        ios: IOSParams(
          iconName: 'CallKitLogo',
          handleType: 'generic',
          supportsVideo: true,
          maximumCallGroups: 2,
          maximumCallsPerCallGroup: 1,
          audioSessionMode: 'default',
          audioSessionActive: true,
          audioSessionPreferredSampleRate: 44100.0,
          audioSessionPreferredIOBufferDuration: 0.005,
          supportsDTMF: true,
          supportsHolding: true,
          supportsGrouping: false,
          supportsUngrouping: false,
          ringtonePath: 'system_ringtone_default',
        ),
      );
      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
      FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
        switch (event!.event) {
          case Event.actionCallIncoming:
            // TODO: received an incoming call
            FirebaseFirestore.instance
                .collection('users')
                .doc(message.data['uid'])
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'status': 'Ringing',
            });

            break;
          case Event.actionCallStart:
            // TODO: started an outgoing call
            // TODO: show screen calling in Flutter
            break;
          case Event.actionCallAccept:
            // TODO: accepted an incoming call
            // TODO: show screen calling in Flutter
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'status': 'accept',
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(message.data['uid'])
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'status': 'accept',
            });
            GetStorage().write('incoming call', 'true');
            GetStorage().write('callId', message.data['callId']);
            GetStorage().write('uid', message.data['uid']);
            GetStorage().write('token', message.data['token']);
            log(GetStorage().read('callId').toString());
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'callAccept': true,
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(message.data['uid'])
                .update({
              'call': true,
            });
            Get.to(callPage(
                uid1: message.data['uid'],
                // callBack: true,
                callId: message.data['callId'],
                // image: message.data['image'] ,
                image: message.data['image'],
                name: message.data['name'],
                uid: FirebaseAuth.instance.currentUser!.uid));

            call = true;
            pref.setBool('incoming call', true);

            log(call.toString());
            break;
          case Event.actionCallDecline:
            // TODO: declined an incoming call
            log('received Call True');
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'hang up': 'true',
              'status': 'declined',
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(message.data['uid'])
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'hang up': 'true',
              'status': 'declined',
            });
            break;
          case Event.actionCallEnded:
            // TODO: ended an incoming/outgoing call
            break;
          case Event.actionCallTimeout:
            // TODO: missed an incoming call
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'hang up': 'true',
              'status': 'missed',
            });
            FirebaseFirestore.instance
                .collection('users')
                .doc(message.data['uid'])
                .collection('calls')
                .doc(message.data['callId'])
                .update({
              'hang up': 'true',
              'status': 'missed',
            });
            break;

          case Event.actionCallCallback:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleHold:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleMute:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleDmtf:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleGroup:
            // TODO: Handle this case.
            break;
          case Event.actionCallToggleAudioSession:
            // TODO: Handle this case.
            break;
          case Event.actionCallCustom:
            // TODO: Handle this case.
            break;
          case Event.actionDidUpdateDevicePushTokenVoip:
            // TODO: Handle this case.
            break;
        }
      });
    }
  }
}

int theme = 0;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  camera = await availableCameras();
  GetStorage.init();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: LocalNotificationService.onActionReceivedMethod,
    onNotificationDisplayedMethod:
        LocalNotificationService.onNotificationDisplayedMethod,
  );
  LocalNotificationService.initialize();
  SharedPreferences pref = await SharedPreferences.getInstance();
  // theme = pref.getInt('theme')!;

  log(theme.toString());
  await Permission.storage.request();

  await Firebase.initializeApp(
          // options: FirebaseOptions(
          //     apiKey: "AIzaSyB4bbS4zXC8eX_YW9DZ8S6s69Hxau7muNk",
          //     projectId: "chatapp-fde18",
          //     messagingSenderId: "1001240436735",
          //     appId: "1:1001240436735:web:17e9a30bfbccfd42d391ca")
          )
      .then((value) => Get.put(AuthFunction()));

  FirebaseMessaging.onMessageOpenedApp.listen((message) async {
    log('background click ${message.notification!.title!}');
  });
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  ).then(
    (_) => runApp(const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    var box = GetStorage();
    // themeGet() async {
    //   SharedPreferences pref = await SharedPreferences.getInstance();
    //   theme = pref.getInt('theme')!;
    // }
    log('accept call true $call');
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Colors.grey
              : Colors.green,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Brightness.light
              : Brightness.dark,
    ));
    return GetMaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: lightThemeData(context),
      darkTheme: darkThemeData(context),
      themeMode: ThemeMode.system,

      // : theme == 1
      //     ? ThemeMode.dark
      //     : ThemeMode.light,
      scrollBehavior: const CupertinoScrollBehavior(),
      // initialRoute: 'homePage',
      home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return homeScreen();
            } else {
              return welcomeScreen();
            }
          }),
    );
  }
}
