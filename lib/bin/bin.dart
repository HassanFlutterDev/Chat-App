// Future initialize(context) async {
//   final callpro = Provider.of<callProvider>(context);
//   final provider = Provider.of<callProvider>(context, listen: false);
//   provider.toggle(true);
// }

// Future<void> showCallkitIncoming(
//     String uuid, var Message, SharedPreferences pref) async {
//   final params = CallKitParams(
//     id: uuid,
//     nameCaller: Message['name1'],
//     appName: 'Connect Me',
//     avatar: Message['image1'],
//     handle: Message['email'],
//     type: 2,
//     duration: 300,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     textMissedCall: 'Missed call',
//     textCallback: 'Call back',
//     extra: <String, dynamic>{'userId': '1a2b3c4d'},
//     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     android: AndroidParams(
//       isCustomNotification: true,
//       isShowLogo: true,
//       isShowCallback: true,
//       isShowMissedCallNotification: true,
//       ringtonePath: 'system_ringtone_default',
//       backgroundColor: '#090a09',
//       // backgroundUrl: 'assets/test.png',
//       actionColor: '#090a09',
//     ),
//     ios: IOSParams(
//       iconName: 'CallKitLogo',
//       handleType: '',
//       supportsVideo: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionMode: 'default',
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       ringtonePath: 'system_ringtone_default',
//     ),
//   );
//   await FlutterCallkitIncoming.showCallkitIncoming(params);
//   FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
//     switch (event!.event) {
//       case Event.ACTION_CALL_INCOMING:
//         // TODO: received an incoming call
//         log('received Call True');
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'status': 'ringing',
//         });
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(Message['uid'])
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'status': 'ringing',
//         });
//         break;
//       case Event.ACTION_CALL_START:
//         // TODO: started an outgoing call
//         // TODO: show screen calling in Flutter
//         break;
//       case Event.ACTION_CALL_ACCEPT:
//         // TODO: accepted an incoming call
//         // TODO: show screen calling in Flutter
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'status': 'accept',
//         });
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(Message['uid'])
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'status': 'accept',
//         });

//         // main();
//         // Get.testMode == true;
//         // Future initialize(context) async {
//         //   WidgetsFlutterBinding.ensureInitialized();
//         //   camera = await availableCameras();

//         //   FirebaseMessaging.onBackgroundMessage(
//         //       _firebaseMessagingBackgroundHandler);

//         //   LocalNotificationService.initialize();
//         //   SharedPreferences pref = await SharedPreferences.getInstance();
//         //   // theme = pref.getInt('theme')!;

//         //   log(theme.toString());
//         //   await Permission.storage.request();
//         //   await Permission.accessMediaLocation.request();
//         //   await Permission.manageExternalStorage.request();
//         //   await Permission.mediaLibrary.request();
//         //   await Firebase.initializeApp(
//         //           // options: FirebaseOptions(
//         //           //     apiKey: "AIzaSyB4bbS4zXC8eX_YW9DZ8S6s69Hxau7muNk",
//         //           //     projectId: "chatapp-fde18",
//         //           //     messagingSenderId: "1001240436735",
//         //           //     appId: "1:1001240436735:web:17e9a30bfbccfd42d391ca")
//         //           )
//         //       .then((value) => Get.put(AuthFunction()));
//         //   SystemChrome.setPreferredOrientations(
//         //     [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
//         //   ).then(
//         //     (_) => runApp(const MyApp()),
//         //   );
//         //   try {
//         //     Navigator.push(context, MaterialPageRoute(builder: (context) {
//         //       return callPage(
//         //           callId: Message['callId'],
//         //           image:
//         //               'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhW0hzwECDKq0wfUqFADEJaNGESHQ8GRCJIg&usqp=CAU',
//         //           name: 'Hassan',
//         //           uid: FirebaseAuth.instance.currentUser!.uid);
//         //     }));
//         //   } catch (e) {
//         //     log(e.toString());
//         //   }
//         // }
//         // Get.to();
//         call = true;
//         pref.setBool('incoming call', true);
//         pref.setString('image', Message['image']);
//         pref.setString('callId', Message['callId']);
//         log(call.toString());
//         log('pref back:${pref.getBool('incoming call')}');
//         break;
//       case Event.ACTION_CALL_DECLINE:
//         // TODO: declined an incoming call
//         log('received Call True');
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'hang up': 'true',
//           'status': 'declined',
//         });
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(Message['uid'])
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'hang up': 'true',
//           'status': 'declined',
//         });
//         break;
//       case Event.ACTION_CALL_ENDED:
//         // TODO: ended an incoming/outgoing call
//         break;
//       case Event.ACTION_CALL_TIMEOUT:
//         // TODO: missed an incoming call
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(FirebaseAuth.instance.currentUser!.uid)
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'hang up': 'true',
//           'status': 'missed',
//         });
//         FirebaseFirestore.instance
//             .collection('users')
//             .doc(Message['uid'])
//             .collection('calls')
//             .doc(Message['callId'])
//             .update({
//           'hang up': 'true',
//           'status': 'missed',
//         });
//         break;
//       case Event.ACTION_CALL_CALLBACK:
//         // TODO: only Android - click action `Call back` from missed call notification
//         break;
//       case Event.ACTION_CALL_TOGGLE_HOLD:
//         // TODO: only iOS
//         break;
//       case Event.ACTION_CALL_TOGGLE_MUTE:
//         // TODO: only iOS
//         break;
//       case Event.ACTION_CALL_TOGGLE_DMTF:
//         // TODO: only iOS
//         break;
//       case Event.ACTION_CALL_TOGGLE_GROUP:
//         // TODO: only iOS
//         break;
//       case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
//         // TODO: only iOS
//         break;
//       case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
//         // TODO: only iOS
//         break;
//     }
//   });
//   // Get.to(request_screen());
//   // await FlutterCallkitIncoming.startCall(params);
// }
