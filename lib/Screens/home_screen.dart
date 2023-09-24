// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types, prefer_const_constructors_in_immutables, unused_local_variable

import 'dart:developer';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_event.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
// import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_incoming_call/flutter_incoming_call.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newchatapp/Functions/notifications/notifications.dart';
import 'package:newchatapp/Screens/call_screen.dart';
import 'package:newchatapp/Screens/calling/incoming_call.dart';
import 'package:newchatapp/Screens/calling/outgoing_call.dart';
import 'package:newchatapp/Screens/chat_screen.dart';
import 'package:newchatapp/Screens/community/community_screen.dart';
import 'package:newchatapp/Screens/message_screen.dart';
import 'package:newchatapp/Screens/people_screen.dart';
import 'package:newchatapp/Screens/requests/request_screen.dart';
import 'package:newchatapp/Screens/settings_screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:newchatapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
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
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
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
    Get.to(
      outgoing_call(
          callId: Usersnap.data()!['callId'],
          image: Usersnap.data()!['callImage'],
          uid: Usersnap.data()!['uid'],
          name: Usersnap.data()!['username'],
          token: Usersnap.data()!['token']),
    );
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

class homeScreen extends StatefulWidget {
  homeScreen({Key? key}) : super(key: key);

  @override
  State<homeScreen> createState() => _homeScreenState();
}

class _homeScreenState extends State<homeScreen> with WidgetsBindingObserver {
  int pageidx = 1;
  List pages = [
    peopleScreen(),
    // Community_screen(),
    // callScreen(),
    chatScreen(),
    settingsScreen(),
  ];
  FlutterCallkitIncoming callkitIncoming = FlutterCallkitIncoming();
  // String callId = '';
  // String uid = '';

  @override
  void initState() {
    AwesomeNotifications()
        .setListeners(onActionReceivedMethod: onActionReceivedMethod);
    FirebaseMessaging.instance.getInitialMessage().then(
      (message) async {
        print("FirebaseMessaging.instance.getInitialMessage");
        // incom

        // LocalNotificationService.createanddisplaynotification(message!)
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) async {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          log(message.notification!.title!);
          log(message.notification!.body!);
          log("message.data11 ${message.data}");
          if (message.data['type'] == 'call') {
            String uid = message.data['callId'];
            setState(() {
              callId = uid;
              uid = message.data['uid'];
            });
            if (message.data['status'] == 'missed') {
              // FlutterCallkitIncoming.endCall(uid);
              log('missed call');
              LocalNotificationService.createanddisplaynotification(message);
            } else {
              AwesomeNotifications().initialize(null, [
                NotificationChannel(
                  channelKey: 'connect_me_call',
                  channelName: 'connect_me_call',
                  channelDescription: 'Connects',
                  importance: NotificationImportance.Max,
                  defaultRingtoneType: DefaultRingtoneType.Ringtone,
                  playSound: true,
                  locked: true,
                  channelShowBadge: true,
                ),
              ]);
              AwesomeNotifications().createNotification(
                  content: NotificationContent(
                    id: 124,
                    channelKey: 'connect_me_call',
                    color: Colors.green,
                    category: NotificationCategory.Call,
                    title: message.notification!.title,
                    body: message.notification!.body,
                    autoDismissible: false,
                    wakeUpScreen: true,
                    fullScreenIntent: true,
                    // badge: 1,
                    // displayOnForeground: false,
                    backgroundColor: Colors.green,
                    displayOnBackground: true,
                    // notificationLayout: NotificationLayout.Inbox,
                    actionType: ActionType.KeepOnTop,
                    largeIcon: message.data['image'],
                    // roundedLargeIcon: true,
                    // summary: '',
                  ),
                  actionButtons: [
                    NotificationActionButton(
                      key: 'Accept',
                      enabled: true,
                      label: 'accept',
                      color: Colors.green,
                      // actionType: ActionType.SilentAction,
                    ),
                    NotificationActionButton(
                        // actionType: ActionType.DismissAction,
                        key: 'Declined',
                        label: 'reject',
                        color: Colors.red),
                  ]);
              // onActionReceivedMethod(ReceivedAction());
              AwesomeNotifications().setListeners(
                onActionReceivedMethod: onActionReceivedMethod,
                onNotificationDisplayedMethod: onNotificationDisplayedMethod,
              );
            }
          } else {
            // LocalNotificationService.createanddisplaynotification(message);

            Get.snackbar(
              message.notification!.title!,
              message.notification!.body!,
              backgroundColor: Color.fromARGB(255, 134, 133, 133),

              colorText: Colors.white,
              duration: Duration(seconds: 5),

              icon: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: CircleAvatar(
                      radius: 17,
                      backgroundImage: NetworkImage(
                        message.data['image'],
                      ),
                    ),
                  ),
                ],
              ),
              // borderRadius: 9,
              onTap: (snack) async {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(message.data['uid'])
                    .collection('Chatrooms')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .update({
                  'online': true,
                });
                Get.closeAllSnackbars();
                Get.to(messageScreen(
                  uid: message.data['uid'],
                  chatId: message.data['uid'],
                ));
              },
              // borderWidth: 1,
              // borderColor: Colors.white,
              margin: EdgeInsets.symmetric(vertical: 15, horizontal: 14),
            );
          }
        }
      },
    );
    getData();
    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) async {
        log("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          log('background click ${message.notification!.title!}');
          log(message.notification!.body!);
          log("message.data22 ${message.data['_id']}");
          await FirebaseFirestore.instance
              .collection('users')
              .doc(message.data['uid'])
              .collection('Chatrooms')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'online': true,
          });
          // Get.closeAllSnackbars();
          Get.to(messageScreen(
            uid: message.data['uid'],
            chatId: message.data['uid'],
          ));
          // }
        }
      },
    );

    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus('Online', DateTime.now());
  }

  void setStatus(String status, DateTime time) async {
    if (status == 'Online') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'status': status,
      });
      SharedPreferences pref = await SharedPreferences.getInstance();
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (Usersnap.data()!['callAccept'] == true) {
        Get.to(
          outgoing_call(
              callId: Usersnap.data()!['callId'],
              image: Usersnap.data()!['callImage'],
              uid: Usersnap.data()!['uid'],
              name: Usersnap.data()!['username'],
              token: Usersnap.data()!['token']),
        );
      }
      // log('goto call page>>>>> true');
      // log('pref incoming: ${pref.getBool('incoming call').toString()}');
      // log('get incoming: ${GetStorage().read('incoming call').toString()}');
      // Get.to(callPage(
      //     uid1: pref.getString('uid')!,
      //     callBack: true,
      //     callId: pref.getString('callId')!,
      //     image: pref.getString('image')!,
      //     name: pref.getString('name')!,
      //     uid: FirebaseAuth.instance.currentUser!.uid));
      // if (pref.getBool('incoming call') == true &&
      //     GetStorage().read('incoming call') == 'true') {
      //   log('goto call page>>>>> true');
      //   Get.to(callPage(
      //       uid1: pref.getString('uid')!,
      //       callBack: true,
      //       callId: pref.getString('callId')!,
      //       image: pref.getString('image')!,
      //       name: pref.getString('name')!,
      //       uid: FirebaseAuth.instance.currentUser!.uid));
      // }
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'status': status,
        'statusT': time,
      });
    }
  }

  bool isLoading = false;
  var userData = {};

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        userData = Usersnap.data()!;
      });
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Online
      print('online');
      setStatus('Online', DateTime.now());
      getBool();
    } else {
      print('offline');
      // SystemNavigator.pop();
      setStatus('Offline', DateTime.now());
    }
  }

  Future getBool() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    log('goto call page>>>>> false');
    log('pref incoming: ${pref.getBool('incoming call').toString()}');
    log('get incoming: ${GetStorage().read('incoming call').toString()}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 55,
        color: Theme.of(context).bottomNavigationBarTheme.backgroundColor ==
                Color.fromARGB(255, 0, 0, 0)
            ? Color.fromARGB(255, 24, 24, 24)
            : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        pageidx = 0;
                      });
                    },
                    child: Icon(
                      pageidx == 0 ? EvaIcons.search : EvaIcons.searchOutline,
                      color: pageidx == 0
                          ? kPrimaryColor
                          : Theme.of(context).iconTheme.color,
                      size: 28,
                    )),
                Text(
                  'Search',
                  style: TextStyle(
                    color: pageidx == 0
                        ? kPrimaryColor
                        : Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.8),
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        pageidx = 1;
                      });
                    },
                    child: Icon(
                      pageidx == 1
                          ? EvaIcons.messageCircle
                          : EvaIcons.messageCircleOutline,
                      color: pageidx == 1
                          ? kPrimaryColor
                          : Theme.of(context).iconTheme.color,
                      size: 28,
                    )),
                Text(
                  'Chat',
                  style: TextStyle(
                    color: pageidx == 1
                        ? kPrimaryColor
                        : Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.8),
                  ),
                )
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                    onTap: () {
                      setState(() {
                        pageidx = 2;
                      });
                    },
                    child: Icon(
                      pageidx == 2
                          ? EvaIcons.settings2
                          : EvaIcons.settings2Outline,
                      color: pageidx == 2
                          ? kPrimaryColor
                          : Theme.of(context).iconTheme.color,
                      size: 28,
                    )),
                Text(
                  'Settings',
                  style: TextStyle(
                    color: pageidx == 2
                        ? kPrimaryColor
                        : Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .withOpacity(0.8),
                  ),
                )
              ],
            ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             pageidx = 3;
            //           });
            //         },
            //         child: Icon(
            //           pageidx == 3
            //               ? EvaIcons.messageCircle
            //               : EvaIcons.messageCircleOutline,
            //           color: pageidx == 3
            //               ? kPrimaryColor
            //               : Theme.of(context).iconTheme.color,
            //           size: 28,
            //         )),
            //     Text(
            //       'Chats',
            //       style: TextStyle(
            //         color: pageidx == 3
            //             ? kPrimaryColor
            //             : Theme.of(context)
            //                 .textTheme
            //                 .bodyText1!
            //                 .color!
            //                 .withOpacity(0.8),
            //       ),
            //     )
            //   ],
            // ),
            // Column(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     GestureDetector(
            //         onTap: () {
            //           setState(() {
            //             pageidx = 4;
            //           });
            //         },
            //         child: Icon(
            //           pageidx == 4
            //               ? EvaIcons.settings
            //               : EvaIcons.settingsOutline,
            //           color: pageidx == 4
            //               ? kPrimaryColor
            //               : Theme.of(context).iconTheme.color,
            //           size: 28,
            //         )),
            //     Text(
            //       'Settings',
            //       style: TextStyle(
            //         color: pageidx == 4
            //             ? kPrimaryColor
            //             : Theme.of(context)
            //                 .textTheme
            //                 .bodyText1!
            //                 .color!
            //                 .withOpacity(0.8),
            //       ),
            //     )
            //   ],
            // )
          ],
        ),
      ),
      body: pages[pageidx],
    );
  }
}

Future<void> showCallkitIncomingForeground(
    String uuid, var Message, SharedPreferences pref) async {
  final params = CallKitParams(
    id: uuid,
    nameCaller: Message['name1'],
    appName: 'Connect Me',
    avatar: Message['image1'],
    handle: Message['email'],
    type: 2,
    duration: 300,
    textAccept: 'Accept',
    textDecline: 'Decline',
    extra: <String, dynamic>{'userId': '1a2b3c4d'},
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: AndroidParams(
      isCustomNotification: true,
      isShowLogo: true,
      ringtonePath: 'system_ringtone_default',
      backgroundColor: '#090a09',
      // backgroundUrl: 'assets/test.png',
      actionColor: '#4CAF50',
    ),
    ios: IOSParams(
      iconName: 'CallKitLogo',
      handleType: '',
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
  await FlutterCallkitIncoming.showCallkitIncoming(params);
  // FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
  //   switch (event!.event) {
  //     case Event.ACTION_CALL_INCOMING:
  //       // TODO: received an incoming call

  //       break;
  //     case Event.ACTION_CALL_START:
  //       // TODO: started an outgoing call
  //       // TODO: show screen calling in Flutter
  //       break;
  //     case Event.ACTION_CALL_ACCEPT:
  //       // TODO: accepted an incoming call
  //       // TODO: show screen calling in Flutter
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'status': 'accept',
  //       });
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(Message['uid'])
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'status': 'accept',
  //       });
  //       // GetStorage().write('incoming call', 'true');
  //       // GetStorage().write('callId', Message['callId']);
  //       // log(GetStorage().read('callId').toString());
  //       Get.to(callPage(
  //           uid1: Message['uid'],
  //           // callBack: true,
  //           callId: Message['callId'],
  //           // image: Message['image'] ,
  //           image: Message['image'],
  //           name: Message['name'],
  //           uid: FirebaseAuth.instance.currentUser!.uid));

  //       call = true;
  //       pref.setBool('incoming call', true);

  //       log(call.toString());
  //       break;
  //     case Event.ACTION_CALL_DECLINE:
  //       // TODO: declined an incoming call
  //       log('received Call True');
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'hang up': 'true',
  //         'status': 'declined',
  //       });
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(Message['uid'])
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'hang up': 'true',
  //         'status': 'declined',
  //       });
  //       break;
  //     case Event.ACTION_CALL_ENDED:
  //       // TODO: ended an incoming/outgoing call
  //       break;
  //     case Event.ACTION_CALL_TIMEOUT:
  //       // TODO: missed an incoming call
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(FirebaseAuth.instance.currentUser!.uid)
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'hang up': 'true',
  //         'status': 'missed',
  //       });
  //       FirebaseFirestore.instance
  //           .collection('users')
  //           .doc(Message['uid'])
  //           .collection('calls')
  //           .doc(Message['callId'])
  //           .update({
  //         'hang up': 'true',
  //         'status': 'missed',
  //       });
  //       break;
  //     case Event.ACTION_CALL_CALLBACK:
  //       // TODO: only Android - click action `Call back` from missed call notification
  //       break;
  //     case Event.ACTION_CALL_TOGGLE_HOLD:
  //       // TODO: only iOS
  //       break;
  //     case Event.ACTION_CALL_TOGGLE_MUTE:
  //       // TODO: only iOS
  //       break;
  //     case Event.ACTION_CALL_TOGGLE_DMTF:
  //       // TODO: only iOS
  //       break;
  //     case Event.ACTION_CALL_TOGGLE_GROUP:
  //       // TODO: only iOS
  //       break;
  //     case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
  //       // TODO: only iOS
  //       break;
  //     case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
  //       // TODO: only iOS
  //       break;
  //   }
  // });
  // Get.to(request_screen());
  // await FlutterCallkitIncoming.startCall(params);
}

Future<bool> hasAlreadyStarted() async {
  try {
    var box = GetStorage().read('incoming call');
    if (GetStorage().read('incoming call') == 'true') {
      log('Storage $box');
      return true;
    } else {
      log('true box');
      return false;
    }
  } catch (error) {
    print("error storage");
    return false;
  }
}
