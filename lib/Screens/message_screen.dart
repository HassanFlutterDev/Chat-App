// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, unused_element, unused_local_variable, prefer_final_fields, unused_import

import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:audioplayers_platform_interface/api/player_state.dart';
import 'package:animations/animations.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:audioplayers/src/audioplayer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
// import 'package:path/path.dart';
import 'package:external_path/external_path.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_audio/just_audio.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:newchatapp/Functions/audio/audio_functions.dart';
import 'package:newchatapp/Functions/messageManagement/messageManagement.dart';
import 'package:newchatapp/Functions/notifications/notifications.dart';
import 'package:newchatapp/Screens/SendImage.dart';
import 'package:newchatapp/Screens/calling/outgoing_call.dart';
import 'package:newchatapp/Screens/camera_screen.dart';
import 'package:newchatapp/Screens/profile_sections/pdf_view.dart';
import 'package:newchatapp/Screens/videoSend.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:newchatapp/Widgets/Shimmer.dart';
import 'package:newchatapp/Widgets/fileCard/file_card.dart';
import 'package:newchatapp/Widgets/imageCard/image_card.dart';
import 'package:newchatapp/Widgets/snackbar.dart';
import 'package:newchatapp/Widgets/videoCard/video_card.dart';
import 'package:newchatapp/Widgets/videoPlayer.dart';
import 'package:newchatapp/main.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as tgo;
import 'package:vibration/vibration.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class messageScreen extends StatefulWidget {
  final String chatId;
  final String uid;

  messageScreen({
    Key? key,
    required this.chatId,
    required this.uid,
  }) : super(key: key);

  @override
  State<messageScreen> createState() => _messageScreenState();
}

class _messageScreenState extends State<messageScreen>
    with WidgetsBindingObserver {
  bool typing = false;
  ScrollController _scrollController = ScrollController();
  TextEditingController _message = TextEditingController();
  String message1 = '';
  String message2 = '';
  bool show = false;
  bool loading = true;
  FocusNode focusNode = FocusNode();
  var userData = {};
  var userData2 = {};
  bool sending = false;
  bool delete = false;
  var userChatRoom = {};
  chatManagement chat = chatManagement();
  // bool delshow = false;
  List<String> delId = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
    getotherData();
    getChatRoom();
    load();
    initRecorder();
    // _scrollController;
    WidgetsBinding.instance.addObserver(this);
    // permissionHandler();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        show = false;
        setState(() {});
      }
    });
  }

  Future permissionHandler() async {
    await Permission.storage.request();
    await Permission.accessMediaLocation.request();
    await Permission.manageExternalStorage.request();
    await Permission.mediaLibrary.request();
  }

  Future load() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      loading = false;
    });
  }

  void setStatus(String status, DateTime time) async {
    if (status == 'Online') {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'status': status,
      });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'status': status,
        'statusT': time,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.chatId)
          .update({
        'typing': 'no',
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Online
      log('online');

      setStatus('Online', DateTime.now());
    } else {
      log('offline');
      setStatus('Offline', DateTime.now());
    }
  }

  getData() async {
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      setState(() {
        userData = Usersnap.data()!;
      });
    } catch (e) {}
  }

  bool isLoading = false;
  getChatRoom() async {
    setState(() {
      isLoading = true;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.chatId)
          .get();
      setState(() {
        userChatRoom = Usersnap.data()!;
      });
    } catch (e) {
      setState(() {
        isLoading = true;
      });
    }
  }

  bool isloading = false;
  getotherData() async {
    setState(() {
      isloading = true;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      setState(() {
        userData2 = Usersnap.data()!;
      });
    } catch (e) {}
    setState(() {
      isloading = false;
    });
  }

  PlatformFile? file;
  Future typing1(bool typing) async {
    if (typing) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.chatId)
          .update({
        'typing': 'yes',
      });
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(widget.chatId)
      //     .collection('Chatrooms')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .update({
      //   'typing': 'yes',
      // });
    } else {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.chatId)
          .update({
        'typing': 'no',
      });
      // await FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(widget.chatId)
      //     .collection('Chatrooms')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .update({
      //   'typing': 'no',
      // });
    }
  }

  bool mic = false;
  final recorder = FlutterSoundRecorder();

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'permission no granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future start() async {
    await recorder.startRecorder(
      toFile: 'Audio.aac',
    );
  }

  Future stop() async {
    final String? path = await recorder.stopRecorder();
    // final String filepath = path!;

    // print(filepath.toString());
    //  SendVoice(File(path.toString()));
  }

  UploadTask? task;

// application/vnd.android.package-archive
  Future<String> SendFile(File assest) async {
    String? downloadurl;
    try {
      var postId = Uuid().v1();

      Reference ref =
          FirebaseStorage.instance.ref().child('Sfile').child(postId);
      setState(() {
        task = ref.putFile(
            assest,
            SettableMetadata(
              contentType: 'File/file',
            ));
      });
      TaskSnapshot snap = await task!;
      downloadurl = await snap.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('error 2 ', e.toString());
    }
    return downloadurl!;
  }

  pickedVideo(ImageSource src, BuildContext context) async {
    final video = await ImagePicker().pickVideo(source: src);
    if (video != null) {
      Get.to(
          // ConfirmedVideo(
          //   video: VideoPlayerController.file(File(video.path)),
          //   videoPath: video.path,
          // ),
          sendVideo(imagepath: video, ChatId: widget.chatId),
          transition: Transition.rightToLeft);
    }
  }

  void selectImage(ImageSource src) async {
    final image = await ImagePicker().pickImage(
      source: src,
    );
    if (image != null) {
      Get.to(sendImage(imagepath: image, ChatId: widget.chatId),
          transition: Transition.rightToLeft);
    }
  }

  // function to convert time stamp to date
  static DateTime returnDateAndTimeFormat(var time) {
    var dt = DateTime.tryParse(time.toDate().toString());
    var originalDate = DateFormat('MM/dd/yyyy').format(dt!);
    return DateTime(dt.year, dt.month, dt.day);
  }

  //function to return message time in 24 hours format AM/PM
  static String messageTime(var time) {
    var dt = DateTime.tryParse(time.toDate().toString());
    String difference = '';
    difference = DateFormat('jm').format(dt!).toString();
    return difference;
  }

  // function to return date if date changes based on your local date and time
  static String groupMessageDateAndTime(var time) {
    var dt = DateTime.tryParse(time.toDate().toString());
    var originalDate = DateFormat('MM/dd/yyyy').format(dt!);

    final todayDate = DateTime.now();

    final today = DateTime(todayDate.year, todayDate.month, todayDate.day);
    final yesterday =
        DateTime(todayDate.year, todayDate.month, todayDate.day - 1);
    String difference = '';
    final aDate = DateTime(dt.year, dt.month, dt.day);

    if (aDate == today) {
      difference = "Today";
    } else if (aDate == yesterday) {
      difference = "Yesterday";
    } else {
      difference = DateFormat.yMMMd().format(dt).toString();
    }

    return difference;
  }

  @override
  Widget build(BuildContext context) {
    String voicetimer = '00:00';
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Row(
          children: [
            InkWell(
                onTap: () async {
                  if (show) {
                    show = false;

                    Navigator.pop(context);
                    setState(() {});
                  } else if (typing) {
                    typing = false;
                    typing1(false);
                    _message.text = '';

                    Navigator.pop(context);
                    setState(() {});
                  } else {
                    typing1(false);

                    Navigator.pop(context);
                    setState(() {});
                  }
                  return Future.value(false);
                },
                child: Icon(Icons.arrow_back_ios)),
            userData2['photoUrl'] == null
                ? CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.white,
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white,
                    backgroundImage: NetworkImage(userData2['photoUrl']),
                  ),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        child: userData2['username'] == null
                            ? Text('')
                            : Text(
                                userData2['username'].toString().length <= 12
                                    ? userData2['username']
                                    : userData2['username']
                                        .toString()
                                        .replaceRange(
                                            12,
                                            userData2['username']
                                                .toString()
                                                .length,
                                            '...'),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 17),
                              ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // StreamBuilder<DocumentSnapshot>(
                      //     stream: FirebaseFirestore.instance
                      //         .collection('users')
                      //         .doc(userData2['uid'])
                      //         .snapshots(),
                      //     builder: (context, snapshot) {
                      //       return Text(
                      //         snapshot.data?['typing'] == 'yes'
                      //             ? 'Typing...'
                      //             : snapshot.data?['typing'] == 'recording'
                      //                 ? 'Voice Recording...'
                      //                 : snapshot.data?['status'] == 'Online'
                      //                     ? 'Online'
                      //                     : 'Last seen at ${tgo.format(snapshot.data?['statusT'].toDate())}',
                      //         style:
                      //             TextStyle(color: Colors.white, fontSize: 9),
                      //       );
                      //     }),
                      StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(userData2['uid'])
                              .snapshots(),
                          builder: (context, snapshot) {
                            return Text(
                              loading
                                  ? 'Loading...'
                                  : snapshot.data?['status'] == 'Online'
                                      ? 'Online'
                                      : 'Last seen at ${tgo.format(snapshot.data?['statusT'].toDate())}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 9),
                            );
                          })
                    ],
                  )
                ],
              ),
            )
          ],
        ),
        actions: [
          Container(
            width: 100,
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    String callId = Uuid().v1();
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return Center(
                            child: Container(
                              height: 60,
                              width: 100,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.black
                                        ? Color.fromARGB(255, 78, 77, 77)
                                            .withOpacity(0.4)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'call': true,
                      'callId': callId,
                      'callUid': widget.uid,
                      'callImage': userData2['photoUrl'],
                    });

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .update({
                      'call': true,
                      'callId': callId,
                      'callImage': userData['photoUrl'],
                      'callUid': FirebaseAuth.instance.currentUser!.uid,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('calls')
                        .doc(callId)
                        .set({
                      'name': userData2['username'],
                      'attend': false,
                      'hang up': false,
                      'status': 'calling',
                      'type': 'Video',
                      'email': userData2['email'],
                      'time': '',
                      'date': DateTime.now(),
                      'image': userData2['photoUrl'],
                      'uid': userData2['uid'],
                      'callId': callId,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .collection('calls')
                        .doc(callId)
                        .set({
                      'name': userData['username'],
                      'attend': false,
                      'hang up': false,
                      'status': 'calling',
                      'email': userData['email'],
                      'time': '',
                      'type': 'Video',
                      'date': DateTime.now(),
                      'image': userData['photoUrl'],
                      'uid': userData['uid'],
                      'callId': callId,
                    });
                    LocalNotificationService.sendcallInvitation(
                      'Incoming Video Call',
                      '${userData['username']}',
                      userData2['token'],
                      userData['uid'],
                      callId,
                      'outgoing',
                      userData['photoUrl'],
                      userData['username'],
                      userData['email'],
                      userData['username'],
                      userData2['photoUrl'],
                      'video',
                    );
                    Get.back();
                    Get.to(outgoing_call(
                      name: userData['username'],
                      token: userData2['token'],
                      callId: callId,
                      nameO: userData2['username'],
                      uid: userData2['uid'],
                      image: userData2['photoUrl'],
                      email: userData2['email'],
                    ));
                  },
                  child: Icon(
                    EvaIcons.videoOutline,
                    color: Colors.white,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String callId = Uuid().v1();
                    showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return Center(
                            child: Container(
                              height: 60,
                              width: 100,
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor ==
                                            Colors.black
                                        ? Color.fromARGB(255, 78, 77, 77)
                                            .withOpacity(0.4)
                                        : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: CupertinoActivityIndicator(),
                            ),
                          );
                        });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .update({
                      'call': true,
                      'callId': callId,
                      'callUid': widget.uid,
                      'callImage': userData2['photoUrl'],
                    });

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .update({
                      'call': true,
                      'callId': callId,
                      'callImage': userData['photoUrl'],
                      'callUid': FirebaseAuth.instance.currentUser!.uid,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('calls')
                        .doc(callId)
                        .set({
                      'name': userData2['username'],
                      'attend': false,
                      'hang up': false,
                      'status': 'calling',
                      'type': 'voice',
                      'email': userData2['email'],
                      'time': '',
                      'date': DateTime.now(),
                      'image': userData2['photoUrl'],
                      'uid': userData2['uid'],
                      'callId': callId,
                    });
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(widget.uid)
                        .collection('calls')
                        .doc(callId)
                        .set({
                      'name': userData['username'],
                      'attend': false,
                      'hang up': false,
                      'status': 'calling',
                      'email': userData['email'],
                      'time': '',
                      'type': 'voice',
                      'date': DateTime.now(),
                      'image': userData['photoUrl'],
                      'uid': userData['uid'],
                      'callId': callId,
                    });
                    LocalNotificationService.sendcallInvitation(
                      'Incoming Voice Call',
                      '${userData['username']}',
                      userData2['token'],
                      userData['uid'],
                      callId,
                      'outgoing',
                      userData['photoUrl'],
                      userData['username'],
                      userData['email'],
                      userData['username'],
                      userData2['photoUrl'],
                      'voice',
                    );
                    Get.back();
                    Get.to(outgoing_call(
                      name: userData['username'],
                      token: userData2['token'],
                      callId: callId,
                      nameO: userData2['username'],
                      uid: userData2['uid'],
                      image: userData2['photoUrl'],
                      email: userData2['email'],
                    ));
                  },
                  child: Icon(
                    EvaIcons.phoneCallOutline,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: WillPopScope(
        onWillPop: () async {
          if (show) {
            show = false;

            setState(() {});
          } else if (typing) {
            typing = false;
            typing1(false);
            _message.text = '';

            setState(() {});
          } else {
            typing1(false);

            Navigator.pop(context);
            setState(() {});
          }
          return Future.value(false);
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Colors.transparent,
              image: DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0), BlendMode.darken),
                  image: NetworkImage(isLoading
                      ? 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/HD_transparent_picture.png/640px-HD_transparent_picture.png'
                      : userChatRoom['wallpaperUrl']),
                  fit: BoxFit.cover)),
          child: Column(children: [
            Expanded(
              child: CupertinoScrollbar(
                controller: _scrollController,
                child: GestureDetector(
                  // onTap: () {
                  //   // setState(() {
                  //   //   show = false;
                  //   //   focusNode.unfocus();
                  //   // });
                  // },
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('Chatrooms')
                          .doc(widget.chatId)
                          .collection('messages')
                          .orderBy('time', descending: true)
                          .snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                              snapshot) {
                        // SchedulerBinding.instance.addPostFrameCallback((_) {
                        //   _scrollController.animateTo(
                        //       _scrollController.position.minScrollExtent,
                        //       duration: Duration(milliseconds: 300),
                        //       curve: Curves.bounceInOut);
                        // });
                        return loading
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ],
                              )
                            : Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ListView.builder(
                                    controller: _scrollController,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    shrinkWrap: true,
                                    reverse: true,
                                    itemCount: snapshot.data!.docs.length,
                                    itemBuilder: (context, index) {
                                      // if (index == -1) {
                                      //   return Container(
                                      //     height: 20,
                                      //     color: Colors.red,
                                      //   );
                                      // }
                                      var snap =
                                          snapshot.data!.docs[index].data();

                                      // FirebaseFirestore.instance
                                      //     .collection('users')
                                      //     .doc(FirebaseAuth.instance.currentUser!.uid)
                                      //     .collection('Chatrooms')
                                      //     .doc(widget.chatId)
                                      //     .collection('messages')
                                      //     .doc(snap['postId'])
                                      //     .update({
                                      //   'read': true,
                                      // });
                                      // if (snap['read'] == false) {
                                      FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(widget.chatId)
                                          .collection('Chatrooms')
                                          .doc(FirebaseAuth
                                              .instance.currentUser!.uid)
                                          .collection('messages')
                                          .doc(snap['postId'])
                                          .update({
                                        'read': true,
                                      });
                                      // }

                                      bool isSameDate = false;
                                      String? newDate = '';

                                      final DateTime date =
                                          returnDateAndTimeFormat(snapshot
                                              .data!.docs[index]
                                              .data()['time']);

                                      if (index == 0 &&
                                          snapshot.data!.docs.length == 1) {
                                        newDate = groupMessageDateAndTime(
                                                snapshot.data!.docs[index]
                                                    .data()['time'])
                                            .toString();
                                      } else if (index ==
                                          snapshot.data!.docs.length - 1) {
                                        newDate = groupMessageDateAndTime(
                                                snapshot.data!.docs[index]
                                                    .data()['time'])
                                            .toString();
                                      } else {
                                        final DateTime date =
                                            returnDateAndTimeFormat(snapshot
                                                .data!.docs[index]
                                                .data()['time']);
                                        final DateTime prevDate =
                                            returnDateAndTimeFormat(snapshot
                                                .data!.docs[index + 1]
                                                .data()['time']);
                                        isSameDate =
                                            date.isAtSameMomentAs(prevDate);
                                        // log("$date $prevDate $isSameDate");
                                        // if (kDebugMode) {
                                        //   print("$date $prevDate $isSameDate");
                                        // }
                                        newDate = isSameDate
                                            ? ''
                                            : groupMessageDateAndTime(snapshot
                                                    .data!.docs[index]
                                                    .data()['time'])
                                                .toString();
                                      }

                                      return Column(
                                        children: [
                                          if (newDate.isNotEmpty)
                                            Center(
                                                child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                                  .scaffoldBackgroundColor ==
                                                              Colors.black
                                                          ? Color.fromARGB(
                                                              255, 98, 98, 98)
                                                          : Color.fromARGB(255,
                                                              183, 183, 183),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(newDate),
                                                  )),
                                            )),
                                          GestureDetector(
                                              onLongPress: () {
                                                Vibration.vibrate(
                                                    duration: 300,
                                                    amplitude: 78);
                                                // setState(() {
                                                //   delshow = true;
                                                // });

                                                showDialog(
                                                    useRootNavigator: false,
                                                    context: context,
                                                    builder: (context) {
                                                      return Dialog(
                                                        child: Container(
                                                          height: 120,
                                                          color: Colors
                                                              .transparent,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              ListTile(
                                                                onTap: () {
                                                                  showModalBottomSheet(
                                                                      useRootNavigator:
                                                                          false,
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (context) {
                                                                        return Container(
                                                                          height:
                                                                              120,
                                                                          color:
                                                                              Colors.transparent,
                                                                          child:
                                                                              Column(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Text(
                                                                                      'Delete Option?',
                                                                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              Row(
                                                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                children: [
                                                                                  TextButton(
                                                                                      onPressed: () {
                                                                                        Get.back();
                                                                                      },
                                                                                      child: Text('Cancel')),
                                                                                  Container(
                                                                                      child: Padding(
                                                                                    padding: const EdgeInsets.all(8.0),
                                                                                    child: Row(
                                                                                      children: [
                                                                                        TextButton(
                                                                                            onPressed: () async {
                                                                                              Get.back();
                                                                                              Get.back();
                                                                                              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Chatrooms').doc(widget.chatId).collection('messages').doc(snap['postId']).delete();

                                                                                              await Future.delayed(Duration(milliseconds: 100));

                                                                                              await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Chatrooms').doc(widget.chatId).update({
                                                                                                'lastMessage': snap['type'] == '' ? '' : snap['type'],
                                                                                              });
                                                                                              await FirebaseFirestore.instance.collection('users').doc(widget.chatId).collection('Chatrooms').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                                                                                'lastMessage': snap['type'] == '' ? '' : snap['type'],
                                                                                              });
                                                                                            },
                                                                                            child: Text('From Me')),
                                                                                        snap['uid'] == FirebaseAuth.instance.currentUser!.uid
                                                                                            ? TextButton(
                                                                                                onPressed: () async {
                                                                                                  Get.back();
                                                                                                  Get.back();
                                                                                                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Chatrooms').doc(widget.chatId).collection('messages').doc(snap['postId']).delete();
                                                                                                  await FirebaseFirestore.instance.collection('users').doc(widget.chatId).collection('Chatrooms').doc(FirebaseAuth.instance.currentUser!.uid).collection('messages').doc(snap['postId']).delete();

                                                                                                  await Future.delayed(Duration(milliseconds: 100));

                                                                                                  await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Chatrooms').doc(widget.chatId).update({
                                                                                                    'lastMessage': snap['type'] == '' ? '' : snap['type'],
                                                                                                  });
                                                                                                  await FirebaseFirestore.instance.collection('users').doc(widget.chatId).collection('Chatrooms').doc(FirebaseAuth.instance.currentUser!.uid).update({
                                                                                                    'lastMessage': snap['type'] == '' ? '' : snap['type'],
                                                                                                  });
                                                                                                },
                                                                                                child: Text('Everyone'))
                                                                                            : Container(),
                                                                                      ],
                                                                                    ),
                                                                                  )),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      });
                                                                },
                                                                trailing:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .red,
                                                                  child: Icon(
                                                                    EvaIcons
                                                                        .trash2,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                    'Delete'),
                                                              ),
                                                              ListTile(
                                                                onTap: () {},
                                                                trailing:
                                                                    CircleAvatar(
                                                                  backgroundColor:
                                                                      Colors
                                                                          .purple,
                                                                  child: Center(
                                                                    child:
                                                                        FaIcon(
                                                                      FontAwesomeIcons
                                                                          .share,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ),
                                                                title: Text(
                                                                    'Forward'),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                              },
                                              child: snap['type'] == 'text'
                                                  ? snap['uid'] ==
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid
                                                      ? messageCard(
                                                          check: false,
                                                          check2: false,
                                                          read: snap['read'],
                                                          message:
                                                              snap['message'],
                                                          time: snap['time'])
                                                      : messageCard2(
                                                          message:
                                                              snap['message'],
                                                          time: snap['time'],
                                                          url: userData2[
                                                              'photoUrl'],
                                                        )
                                                  : snap['type'] == 'image'
                                                      ? snap['uid'] ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid
                                                          ? image1(
                                                              read:
                                                                  snap['read'],
                                                              postId: snap[
                                                                  'postId'],
                                                              title:
                                                                  snap['title'],
                                                              imagee: snap[
                                                                  'imageUrl'],
                                                              time:
                                                                  snap['time'])
                                                          : image(
                                                              postId: snap[
                                                                  'postId'],
                                                              imagee: snap[
                                                                  'imageUrl'],
                                                              time:
                                                                  snap['time'],
                                                              url: userData2[
                                                                  'photoUrl'],
                                                            )
                                                      : snap['type'] == 'video'
                                                          ? snap['uid'] ==
                                                                  FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid
                                                              ? video(
                                                                  postId: snap[
                                                                      'postId'],
                                                                  read: snap[
                                                                      'read'],
                                                                  title: snap[
                                                                      'title'],
                                                                  imagee:
                                                                      snap['thumbnail'],
                                                                  videoUrl: snap['videoUrl'],
                                                                  time: snap['time'])
                                                              : video1(
                                                                  postId: snap[
                                                                      'postId'],
                                                                  videoUrl: snap[
                                                                      'videoUrl'],
                                                                  title: snap[
                                                                      'title'],
                                                                  imagee: snap[
                                                                      'thumbnail'],
                                                                  time: snap[
                                                                      'time'],
                                                                  url: userData2[
                                                                      'photoUrl'],
                                                                )
                                                          : snap['type'] == 'file'
                                                              ? snap['uid'] == FirebaseAuth.instance.currentUser!.uid
                                                                  ? fileCard(postId: snap['postId'], name: snap['filename'], read: snap['read'], url: snap['FileUrl'], size: snap['size'], type: snap['ext'], time: snap['time'])
                                                                  : fileCard1(postId: snap['postId'], url: snap['FileUrl'], pic: userData2['photoUrl'], name: snap['filename'], read: snap['read'], size: snap['size'], type: snap['ext'], time: snap['time'])
                                                              : snap['uid'] == FirebaseAuth.instance.currentUser!.uid
                                                                  ? Audiocard(
                                                                      postId: snap[
                                                                          'postId'],
                                                                      dur: snap[
                                                                          'duration'],
                                                                      read: snap[
                                                                          'read'],
                                                                      url: snap[
                                                                          'voiceUrl'],
                                                                      time: snap[
                                                                          'time'],
                                                                      Imageurl:
                                                                          userData[
                                                                              'photoUrl'],
                                                                    )
                                                                  : Audiocard1(
                                                                      postId: snap[
                                                                          'postId'],
                                                                      dur: snap[
                                                                          'duration'],
                                                                      url: snap[
                                                                          'voiceUrl'],
                                                                      time: snap[
                                                                          'time'],
                                                                      Imageurl:
                                                                          userData2[
                                                                              'photoUrl'],
                                                                    )),
                                        ],
                                      );
                                    }),
                              );
                      }),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor ==
                        kContentColorLightTheme
                    ? Color.fromARGB(122, 0, 0, 0)
                    : Color.fromARGB(104, 255, 255, 255),
                child: Column(
                  children: [
                    Container(
                      // height: 40,
                      color: Colors.transparent,
                      child: sending ? chat.buildSendFileStatus() : Container(),
                    ),
                    Container(
                      // height: 50,
                      // color: Colors.transparent,
                      child: Column(
                        children: [
                          StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.chatId)
                                  .collection('Chatrooms')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return snapshot.data?['typing'] == 'yes'
                                    ? Container(
                                        height: 40,
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(3.0),
                                              child: CircleAvatar(
                                                radius: 15,
                                                backgroundColor: Colors.yellow,
                                                backgroundImage: NetworkImage(
                                                    userData2['photoUrl']),
                                              ),
                                            ),
                                            Container(
                                              height: 30,
                                              width: 70,
                                              // decoration: BoxDecoration(
                                              //     borderRadius: BorderRadius.circular(20),
                                              //     color: kPrimaryColor.withOpacity(0.9)),
                                              child: LottieBuilder.asset(
                                                'images/typ2.json',
                                                width: 50,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : Container();
                              }),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Row(children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 9, right: 3),
                                child: mic
                                    ? Container(
                                        height: 49,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                100,
                                        decoration: BoxDecoration(
                                            color:
                                                kPrimaryColor.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              IconButton(
                                                  onPressed: () {
                                                    recorder.stopRecorder();
                                                    setState(() {
                                                      mic = false;
                                                    });
                                                  },
                                                  icon: Icon(Icons.delete,
                                                      color: kPrimaryColor)),
                                              Icon(
                                                Icons.radio_button_on,
                                                color: Colors.red,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 4),
                                                child: StreamBuilder<
                                                        RecordingDisposition>(
                                                    stream: recorder.onProgress,
                                                    builder:
                                                        (context, snapshot) {
                                                      final duration =
                                                          snapshot.hasData
                                                              ? snapshot.data!
                                                                  .duration
                                                              : Duration.zero;
                                                      String twodigets(int n) =>
                                                          n
                                                              .toString()
                                                              .padLeft(2, '0');

                                                      final twomin = twodigets(
                                                          duration.inMinutes
                                                              .remainder(60));
                                                      final twomsec = twodigets(
                                                          duration.inSeconds
                                                              .remainder(60));

                                                      if (mic == false) {
                                                        voicetimer =
                                                            '$twomin:$twomin';
                                                      }

                                                      if (twomin == '20') {
                                                        mic = false;
                                                        recorder.stopRecorder();
                                                        Fluttertoast.showToast(
                                                            msg:
                                                                'Voice must be 20 mins only');

                                                        mic = false;
                                                      }
                                                      return Text(
                                                          '$twomin:$twomsec',
                                                          style: TextStyle(
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ));
                                                    }),
                                              ),
                                            ]))
                                    : AnimatedContainer(
                                        duration: Duration(
                                          milliseconds: 500,
                                        ),
                                        width: typing
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                87
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width -
                                                150,
                                        decoration: BoxDecoration(
                                            color:
                                                kPrimaryColor.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(30)),
                                        child: TextFormField(
                                          onChanged: ((value) {
                                            if (value.isNotEmpty) {
                                              setState(() {
                                                typing = true;
                                                typing1(true);
                                              });
                                            } else {
                                              setState(() {
                                                typing = false;
                                                typing1(false);
                                              });
                                            }
                                          }),
                                          controller: _message,
                                          focusNode: focusNode,
                                          maxLines: 2,
                                          minLines: 1,
                                          // autofocus: true,
                                          autocorrect: true,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: 'Type a Message...',
                                              prefixIcon: IconButton(
                                                onPressed: () {
                                                  if (!show) {
                                                    focusNode.unfocus();
                                                    focusNode.canRequestFocus =
                                                        false;
                                                    show = true;
                                                  } else {
                                                    show = false;
                                                  }
                                                  setState(() {});
                                                },
                                                icon: FaIcon(
                                                  FontAwesomeIcons.faceSmile,
                                                  color: show
                                                      ? kPrimaryColor
                                                          .withOpacity(0.6)
                                                      : Colors.grey,
                                                ),
                                              ),
                                              suffixIcon: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                // crossAxisAlignment: CrossAxisAlignment.end,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  SizedBox(
                                                    width: 9,
                                                  ),
                                                  typing
                                                      ? InkWell(
                                                          onTap: () {
                                                            Vibration.vibrate(
                                                                duration: 50,
                                                                amplitude: 5);
                                                            bottom(context);
                                                          },
                                                          child: Icon(
                                                              CupertinoIcons
                                                                  .add))
                                                      : Container(),
                                                  SizedBox(
                                                    width: 7,
                                                  ),
                                                ],
                                              )),
                                        ),
                                      ),
                              ),
                              typing
                                  ? Container()
                                  : SizedBox(
                                      width: 9,
                                    ),
                              typing
                                  ? Container()
                                  : mic
                                      ? Container()
                                      : OpenContainer(
                                          closedColor: Colors.transparent,
                                          middleColor:
                                              Color.fromARGB(255, 0, 0, 0),
                                          openColor:
                                              Color.fromARGB(255, 0, 0, 0),
                                          closedShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6)),
                                          openShape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(70)),
                                          closedElevation: 15.0,
                                          transitionDuration: Duration(
                                            milliseconds: 500,
                                          ),
                                          transitionType:
                                              ContainerTransitionType
                                                  .fadeThrough,
                                          openBuilder: (_, __) {
                                            return cameraScreen(
                                              chatId: widget.chatId,
                                            );
                                          },
                                          closedBuilder: (_, __) {
                                            return InkWell(
                                              onTap: __,
                                              child: Icon(
                                                EvaIcons.camera,
                                                size: 24,
                                              ),
                                            );
                                          },
                                        ),
                              typing
                                  ? Container()
                                  : SizedBox(
                                      width: 9,
                                    ),
                              typing
                                  ? Container()
                                  : mic
                                      ? Container()
                                      : InkWell(
                                          onTap: () {
                                            Vibration.vibrate(
                                                duration: 50, amplitude: 5);
                                            bottom(context);
                                          },
                                          child: Icon(CupertinoIcons.add)),
                              typing
                                  ? AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      child: CupertinoButton(
                                        onPressed: () async {
                                          Vibration.vibrate(
                                              duration: 30, amplitude: 2);

                                          var Usersnap = await FirebaseFirestore
                                              .instance
                                              .collection('users')
                                              .doc(FirebaseAuth
                                                  .instance.currentUser!.uid)
                                              .collection('Chatrooms')
                                              .doc(widget.uid)
                                              .get();
                                          if (Usersnap.data()!['online'] ==
                                              false) {
                                            LocalNotificationService
                                                .sendPushMessage(
                                              _message.text,
                                              userData['username'],
                                              userData2['token'],
                                              userData['photoUrl'],
                                              userData['uid'],
                                            );
                                          }
                                          chatManagement().SendMessage(
                                            widget.chatId,
                                            _message.text,
                                            FirebaseAuth
                                                .instance.currentUser!.uid,
                                            userData['username'],
                                            context,
                                          );

                                          setState(() {
                                            _message.text = "";
                                            _scrollController.animateTo(
                                                _scrollController
                                                    .position.minScrollExtent,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.bounceInOut);
                                            typing = false;
                                            typing1(false);
                                          });
                                        },
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          child: CircleAvatar(
                                            radius: 19,
                                            backgroundColor: kPrimaryColor,
                                            child: Center(
                                              child: FaIcon(
                                                FontAwesomeIcons
                                                    .solidPaperPlane,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : AnimatedContainer(
                                      duration: Duration(milliseconds: 300),
                                      child: CupertinoButton(
                                        onPressed: () async {
                                          if (recorder.isRecording) {
                                            mic = false;

                                            final String? path =
                                                await recorder.stopRecorder();
                                            final String filepath = path!;

                                            print(filepath.toString());
                                            AudioPlayer just = AudioPlayer();
                                            await just.setFilePath(filepath);
                                            final duration = just.duration!;
                                            String twodigets(int n) =>
                                                n.toString().padLeft(2, '0');

                                            final twomin = twodigets(duration
                                                .inMinutes
                                                .remainder(60));
                                            final twomsec = twodigets(duration
                                                .inSeconds
                                                .remainder(60));

                                            setState(() {
                                              print('$twomin:$twomsec');
                                              print(
                                                  'durationS ${just.duration!.toString().replaceAll('0:', '').split('.')[0]}');
                                            });
                                            setState(() {
                                              sending = true;
                                            });
                                            // String voiceUrl =
                                            //     await chat.SendVoice1(
                                            //   File(path.toString()),
                                            // );

                                            chatManagement().SendMessage(
                                              widget.chatId,
                                              _message.text,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['username'],
                                              context,
                                            );

                                            await chat.SendVoice(
                                              widget.chatId,
                                              File(path.toString()),
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              userData['username'],
                                              '$twomin:$twomsec',
                                              context,
                                            );
                                            var Usersnap =
                                                await FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .collection('Chatrooms')
                                                    .doc(widget.uid)
                                                    .get();
                                            if (Usersnap.data()!['online'] ==
                                                false) {
                                              LocalNotificationService
                                                  .sendPushMessage(
                                                '🎤 Sent a Voice',
                                                userData['username'],
                                                userData2['token'],
                                                userData['photoUrl'],
                                                userData['uid'],
                                              );
                                            }
                                            setState(() {
                                              sending = false;
                                            });
                                            // Fluttertoast.showToast(
                                            //     msg:
                                            //         'Voice Sucessfully Sended!!',
                                            //     backgroundColor: kPrimaryColor);
                                          } else {
                                            await start();
                                            mic = true;
                                            // typing('recording');
                                          }
                                          setState(() {});
                                        },
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          child: CircleAvatar(
                                            radius: 19,
                                            backgroundColor: kPrimaryColor,
                                            child: Center(
                                              child: FaIcon(
                                                mic
                                                    ? FontAwesomeIcons
                                                        .solidPaperPlane
                                                    : FontAwesomeIcons
                                                        .microphone,
                                                color: Colors.white,
                                                size: 19,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ))
                            ]),
                          ),
                        ],
                      ),
                    ),
                    show
                        ? Container(
                            height: 300,
                            color: Colors.transparent,
                            child: emoji())
                        : Container(),
                  ],
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }

  Future bottom(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            margin: EdgeInsets.all(15),
            height: 180,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OpenContainer(
                          closedColor: Colors.transparent,
                          middleColor: Color.fromARGB(255, 0, 0, 0),
                          openColor: Color.fromARGB(255, 0, 0, 0),
                          closedShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          openShape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(70)),
                          closedElevation: 15.0,
                          transitionDuration: Duration(
                            milliseconds: 500,
                          ),
                          transitionType: ContainerTransitionType.fadeThrough,
                          openBuilder: (_, __) {
                            return cameraScreen(
                              chatId: widget.chatId,
                            );
                          },
                          closedBuilder: (_, __) {
                            return GestureDetector(
                              onTap: __,
                              child: Column(
                                children: [
                                  Container(
                                    height: 55,
                                    width: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                          begin: Alignment.center,
                                          end: Alignment.bottomCenter,
                                          tileMode: TileMode.clamp,
                                          colors: [
                                            Color.fromARGB(255, 126, 33, 143),
                                            // Color.fromARGB(255, 69, 17, 78),
                                            Colors.purple,
                                            Colors.purple,
                                            Colors.purple,
                                          ]),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.camera,
                                        size: 29,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'Camera',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                            );
                          }),
                      GestureDetector(
                          onTap: () {
                            selectImage(ImageSource.gallery);
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 55,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      tileMode: TileMode.clamp,
                                      colors: [
                                        Color.fromARGB(255, 173, 59, 59),
                                        // Color.fromARGB(255, 69, 17, 78),
                                        Colors.red,
                                        Colors.red,
                                        Colors.red,
                                      ]),
                                ),
                                child: Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.image,
                                    size: 29,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                      GestureDetector(
                        onTap: () {
                          pickedVideo(ImageSource.gallery, context);
                        },
                        child: Column(
                          children: [
                            Container(
                              height: 55,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.clamp,
                                    colors: [
                                      Color.fromARGB(255, 39, 28, 133),
                                      // Color.fromARGB(255, 69, 17, 78),
                                      Color.fromARGB(255, 70, 55, 204),
                                      Color.fromARGB(255, 70, 55, 204),
                                      Color.fromARGB(255, 70, 55, 204),
                                    ]),
                              ),
                              child: Icon(
                                EvaIcons.videoOutline,
                                size: 29,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Video',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      GestureDetector(
                        onTap: () async {},
                        child: Column(
                          children: [
                            Container(
                              height: 55,
                              width: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    begin: Alignment.center,
                                    end: Alignment.bottomCenter,
                                    tileMode: TileMode.clamp,
                                    colors: [
                                      Color.fromARGB(255, 148, 87, 38),
                                      // Color.fromARGB(255, 69, 17, 78),
                                      Color.fromARGB(255, 184, 115, 37),
                                      Color.fromARGB(255, 184, 115, 37),
                                      Color.fromARGB(255, 184, 115, 37),
                                    ]),
                              ),
                              child: Icon(
                                EvaIcons.link2Outline,
                                size: 29,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Links',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      GestureDetector(
                          onTap: () async {
                            Get.back();
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(
                                    type: FileType.custom,
                                    allowedExtensions: [
                                  'apk',
                                  // 'doc',
                                  'pdf',
                                  'zip',
                                  // 'otf',
                                  // 'ttf',
                                  // 'txt'
                                ]);
                            File pick =
                                File(result!.files.single.path.toString());
                            var fil = pick.readAsBytesSync();
                            setState(() {
                              file = result.files.first;
                            });
                            // SendApk(File(file!.path!));
                            print(file!.name.isPDFFileName);
                            final kb = file!.size / 1024;
                            final mb = kb / 1024;
                            final size = (mb >= 1)
                                ? '${mb.toStringAsFixed(2)} MB'
                                : '${kb.toStringAsFixed(2)}Kb';

                            log(file!.name);
                            setState(() {
                              sending = true;
                            });
                            if (file!.name.isPDFFileName) {
                              await chat.SendFile1(
                                widget.chatId,
                                fil,
                                file!.name,
                                FirebaseAuth.instance.currentUser!.uid,
                                size,
                                userData['username'],
                                'Pdf',
                                context,
                              );
                              // log(send.toString());
                              sending = false;
                              setState(() {});
                            } else if (file!.name.isAPKFileName) {
                              await chat.SendApkFile(
                                widget.chatId,
                                File(file!.path!),
                                file!.name,
                                FirebaseAuth.instance.currentUser!.uid,
                                size,
                                userData['username'],
                                'Apk',
                                context,
                              );
                              sending = false;
                              setState(() {});
                            } else {
                              await chat.SendZipFile(
                                widget.chatId,
                                File(file!.path!),
                                file!.name,
                                FirebaseAuth.instance.currentUser!.uid,
                                size,
                                userData['username'],
                                'Zip',
                                context,
                              );
                            }
                            var Usersnap = await FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser!.uid)
                                .collection('Chatrooms')
                                .doc(widget.uid)
                                .get();
                            if (Usersnap.data()!['online'] == false) {
                              LocalNotificationService.sendPushMessage(
                                '📄 Sent a File',
                                userData['username'],
                                userData2['token'],
                                userData['photoUrl'],
                                userData['uid'],
                              );
                            }
                            sending = false;
                            setState(() {});
                            // setState(() {
                            //   sending = false;
                            // });
                            //
                          },
                          child: Column(
                            children: [
                              Container(
                                height: 55,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      tileMode: TileMode.clamp,
                                      colors: [
                                        Color.fromARGB(255, 33, 131, 58),
                                        // Color.fromARGB(255, 69, 17, 78),
                                        Color.fromARGB(255, 37, 184, 74),
                                        Color.fromARGB(255, 37, 184, 74),
                                        Color.fromARGB(255, 37, 184, 74),
                                      ]),
                                ),
                                child: Icon(
                                  EvaIcons.fileOutline,
                                  size: 29,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Document',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          )),
                      GestureDetector(
                        onTap: () {},
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () async {
                                Get.back();
                                final result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.audio,
                                );
                                setState(() {
                                  file = result!.files.first;
                                });
                                AudioPlayer just = AudioPlayer();
                                await just.setFilePath(file!.path!);
                                final duration = just.duration!;
                                String twodigets(int n) =>
                                    n.toString().padLeft(2, '0');

                                final twomin =
                                    twodigets(duration.inMinutes.remainder(60));
                                final twomsec =
                                    twodigets(duration.inSeconds.remainder(60));
                                setState(() {
                                  sending = true;
                                });
                                // String voiceUrl =
                                //     await chat.SendVoice1(File(file!.path!));

                                await chat.SendVoice(
                                  widget.chatId,
                                  File(file!.path!),
                                  FirebaseAuth.instance.currentUser!.uid,
                                  userData['username'],
                                  '$twomin:$twomsec',
                                  context,
                                );
                                setState(() {
                                  sending = false;
                                });
                                Fluttertoast.showToast(
                                    msg: 'Music Sucessfully Sended!!',
                                    backgroundColor: kPrimaryColor);
                              },
                              child: Container(
                                height: 55,
                                width: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                      begin: Alignment.center,
                                      end: Alignment.bottomCenter,
                                      tileMode: TileMode.clamp,
                                      colors: [
                                        Color.fromARGB(255, 33, 83, 150),
                                        // Color.fromARGB(255, 69, 17, 78),
                                        Color.fromARGB(255, 47, 112, 197),
                                        Color.fromARGB(255, 44, 107, 190),
                                        Color.fromARGB(255, 46, 105, 184),
                                      ]),
                                ),
                                child: Icon(
                                  EvaIcons.headphones,
                                  size: 29,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              'Audio',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          );
        });
  }

  Widget emoji() {
    return EmojiPicker(
        onEmojiSelected: (category, emoji) {
          // Do something when emoji is tapped
          print(emoji);
          _message.text = _message.text + emoji.emoji;
          typing = true;
          typing1(true);
          setState(() {});
        },
        config: Config(
            columns: 7,
            // Issue: https://github.com/flutter/flutter/issues/28894
            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            initCategory: Category.RECENT,
            bgColor: Theme.of(context).scaffoldBackgroundColor,
            indicatorColor: kPrimaryColor,
            iconColor: Colors.grey,
            iconColorSelected: kPrimaryColor,
            // progressIndicatorColor: kPrimaryColor,
            backspaceColor: kPrimaryColor,
            skinToneDialogBgColor: Colors.white,
            skinToneIndicatorColor: Colors.grey,
            enableSkinTones: true,
            // showRecentsTab: true,
            recentsLimit: 28,
            replaceEmojiOnLimitExceed: false,
            noRecents: const Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: const CategoryIcons(),
            buttonMode: ButtonMode.MATERIAL));
  }
}

class messageCard extends StatelessWidget {
  String message;
  bool check;
  bool check2;
  bool read;
  final time;
  messageCard(
      {Key? key,
      required this.check,
      required this.check2,
      required this.message,
      required this.read,
      required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: kPrimaryColor.withOpacity(1),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                  child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 3, left: 15, right: 20, bottom: 5),
                      child:
                          Text(message, style: TextStyle(color: Colors.white)),
                    ),
                    // Positioned(
                    //   bottom: 4,
                    //   right: 10,\\\\
                    //   child:
                    // )
                  ]),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateFormat.jm().format(time.toDate()),
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        Icon(
                          Icons.check,
                          size: 15,
                          color: read ? kPrimaryColor : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class messageCard2 extends StatelessWidget {
  String message;
  final time;
  String url;
  messageCard2(
      {Key? key, required this.message, required this.time, required this.url})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: kPrimaryColor.withOpacity(0.3),
                ),
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 3, left: 15, right: 20, bottom: 5),
                    child: Text(
                      message,
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyText1!.color,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                  // Positioned(
                  //   bottom: 4,
                  //   right: 10,
                  //   child:
                  // )
                ]),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.green,
                backgroundImage: NetworkImage(url),
              ),
              SizedBox(
                height: 6,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.jm().format(time.toDate()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
