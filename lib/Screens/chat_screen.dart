// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, unused_element, dead_code, nullable_type_in_catch_clause, unused_import, unused_local_variable

import 'dart:developer';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkit_incoming/entities/android_params.dart';
import 'package:flutter_callkit_incoming/entities/call_kit_params.dart';
import 'package:flutter_callkit_incoming/entities/ios_params.dart';
import 'package:flutter_callkit_incoming/entities/notification_params.dart';

import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
// import 'package:flutter_incoming_call/flutter_incoming_call.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:newchatapp/Screens/calling/outgoing_call.dart';
import 'package:newchatapp/Screens/encode/encode.dart';
import 'package:newchatapp/Screens/message_screen.dart';
import 'package:newchatapp/Screens/profile_screen.dart';
import 'package:newchatapp/Screens/requests/request_screen.dart';
import 'package:newchatapp/Screens/status/status_screen.dart';
import 'package:newchatapp/Screens/status_screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:newchatapp/Widgets/Shimmer.dart';
import 'package:newchatapp/Widgets/voice_recorder.dart';
import 'package:newchatapp/models/export_Chat.dart';
import 'package:story_view/story_view.dart';
import 'package:uuid/uuid.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class chatScreen extends StatefulWidget {
  chatScreen({Key? key}) : super(key: key);

  @override
  State<chatScreen> createState() => _chatScreenState();
}

class _chatScreenState extends State<chatScreen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  // Flutter _callKeep = FlutterCallkeep();

  @override
  void initState() {
    controller = TabController(length: 2, vsync: this);
    getData();
    // TODO: implement initState

    super.initState();
    // FlutterCallkitIncoming.onEvent.listen((event) {
    //   if (event == null) return;
    //   log('call event init');
    //   if (event.event == Event.ACTION_CALL_ACCEPT) {
    //     log('call event init');
    //     joinCalling();
    //   }
    // });
  }

  Future doNothing(String otherId) async {
    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('chatRooms')
        .doc(otherId)
        .collection('messages');
    var snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  UploadTask? uploa;
  var userData = {};
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

  // void joinCalling() async {
  //   log('joinCalling');
  //   Get.to(
  //     callPage(
  //         callId: GetStorage().read('callId'),
  //         image: GetStorage().read('image'),
  //         name: 'Hassan',
  //         uid: FirebaseAuth.instance.currentUser!.uid),
  //   );
  // }
  List<StoryItem> storyItems = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: GestureDetector(
            onTap: () {},
            child: Text(
              'Lets Talk',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            IconButton(
                onPressed: () async {
                  Get.to(request_screen(), transition: Transition.downToUp);
                },
                icon: Icon(
                  EvaIcons.personAdd,
                  color: Colors.white,
                ))
          ],
          bottom: TabBar(
              automaticIndicatorColorAdjustment: false,
              controller: controller,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              tabs: [
                Tab(
                  text: 'Chats',
                ),
                Tab(
                  text: 'Status',
                )
              ]),
        ),
        body: TabBarView(controller: controller, children: [
          CupertinoScrollbar(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  chats(),
                ],
              ),
            ),
          ),
          StatusScreen(),
        ]));
  }
}

class chats extends StatefulWidget {
  const chats({
    Key? key,
  }) : super(key: key);

  @override
  State<chats> createState() => _chatsState();
}

class _chatsState extends State<chats> {
  Future doNothing(String otherId) async {
    var collection = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chatrooms')
        .doc(otherId)
        .collection('messages');
    var snapshot = await collection.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chatrooms')
        .doc(otherId)
        .update({
      'lastMessage': '',
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    UploadTask? uploa;
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    String dateToday(DateTime Time) {
      String time = '';
      final dateToCheck = Time;
      final aDate =
          DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);
      if (aDate == today) {
        return time = DateFormat.jm().format(Time);
      } else {
        return time = DateFormat.yMd().format(Time);
      }
      return time;
    }

    return CupertinoScrollbar(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('Chatrooms')
              .orderBy(
                'time',
                descending: true,
              )
              .snapshots(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ShimmerSearch();
            }
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                dragStartBehavior: DragStartBehavior.start,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: snapshot.data!.docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var snap = snapshot.data!.docs[index].data();
                  CollectionReference<Map<String, dynamic>> collection;
                  return InkWell(
                    onTap: () async {
                      // Navigator.push(context, MaterialPageRoute(builder: (_) {
                      //   return messageScreen();
                      // }));
                      Get.to(
                          messageScreen(chatId: snap['uid'], uid: snap['uid']),
                          transition: Transition.rightToLeft);
                    },
                    child: Slidable(
                      key: const ValueKey(0),

                      // The start action pane is the one at the left or the top side.

                      // The end action pane is the one at the right or the bottom side.
                      endActionPane: ActionPane(
                        motion: ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (context) async =>
                                {await doNothing(snap['uid'])},
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Container(
                        height: 70,
                        color: Colors.transparent,
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: snap['profileImage'] == null
                                  ? CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                    )
                                  : CircleAvatar(
                                      radius: 30,
                                      backgroundImage:
                                          NetworkImage(snap['profileImage']),
                                      backgroundColor: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Container(
                                width: MediaQuery.of(context).size.width - 75,
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(snap['username'],
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .color!
                                                        .withOpacity(0.8),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            Text(
                                                dateToday(snap['time'].toDate())
                                                    .toString(),
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .textTheme
                                                        .bodyText1!
                                                        .color!
                                                        .withOpacity(0.5),
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 40,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      83,
                                                  color: Colors.transparent,
                                                  child: snap['lastMessage'] ==
                                                          ''
                                                      ? Container()
                                                      : StreamBuilder(
                                                          stream: FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'users')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid)
                                                              .collection(
                                                                  'Chatrooms')
                                                              .doc(snap['uid'])
                                                              .collection(
                                                                  'messages')
                                                              .orderBy('time',
                                                                  descending:
                                                                      true)
                                                              .snapshots(),
                                                          builder: (context,
                                                              AsyncSnapshot<
                                                                      QuerySnapshot<
                                                                          Map<String,
                                                                              dynamic>>>
                                                                  snapshot) {
                                                            if (snapshot
                                                                    .connectionState ==
                                                                ConnectionState
                                                                    .waiting) {
                                                              return Container();
                                                            } else if (snapshot
                                                                .hasData) {
                                                              return ListView
                                                                  .builder(
                                                                      itemCount:
                                                                          1,
                                                                      itemBuilder:
                                                                          (context,
                                                                              index) {
                                                                        var snap = snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .data();

                                                                        return index ==
                                                                                1
                                                                            ? Text('')
                                                                            : snap['type'] == 'text'
                                                                                ? RichText(
                                                                                    text: TextSpan(
                                                                                      style: const TextStyle(color: Colors.grey),
                                                                                      children: [
                                                                                        TextSpan(
                                                                                          text: snap['uid'] == FirebaseAuth.instance.currentUser!.uid ? 'You:' : '',
                                                                                          style: const TextStyle(
                                                                                            fontWeight: FontWeight.bold,
                                                                                          ),
                                                                                        ),
                                                                                        TextSpan(
                                                                                          text: snap['message'].toString().length <= 90 ? snap['message'] : snap['message'].toString().replaceRange(90, snap['message'].toString().length, '...'),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  )
                                                                                : snap['type'] == 'voice'
                                                                                    ? Row(
                                                                                        children: [
                                                                                          Text(
                                                                                            snap['uid'] == FirebaseAuth.instance.currentUser!.uid ? 'You:' : '',
                                                                                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                                                          ),
                                                                                          Icon(
                                                                                            CupertinoIcons.music_note,
                                                                                            size: 17,
                                                                                            color: kPrimaryColor,
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: 3,
                                                                                          ),
                                                                                          Text(
                                                                                            'Audio',
                                                                                            style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                                          ),
                                                                                        ],
                                                                                      )
                                                                                    : snap['type'] == 'image'
                                                                                        ? Row(
                                                                                            children: [
                                                                                              Text(
                                                                                                snap['uid'] == FirebaseAuth.instance.currentUser!.uid ? 'You:' : '',
                                                                                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                                                              ),
                                                                                              Icon(
                                                                                                CupertinoIcons.camera_fill,
                                                                                                size: 17,
                                                                                                color: kPrimaryColor,
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: 3,
                                                                                              ),
                                                                                              Text(
                                                                                                snap['type'],
                                                                                                style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                                              ),
                                                                                            ],
                                                                                          )
                                                                                        : snap['type'] == 'video'
                                                                                            ? Row(
                                                                                                children: [
                                                                                                  Text(
                                                                                                    snap['uid'] == FirebaseAuth.instance.currentUser!.uid ? 'You:' : '',
                                                                                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                                                                  ),
                                                                                                  Icon(
                                                                                                    CupertinoIcons.play_fill,
                                                                                                    size: 17,
                                                                                                    color: kPrimaryColor,
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    width: 3,
                                                                                                  ),
                                                                                                  Text(
                                                                                                    'Video',
                                                                                                    style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            : snap['type'] == 'file'
                                                                                                ? Row(
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        snap['uid'] == FirebaseAuth.instance.currentUser!.uid ? 'You:' : '',
                                                                                                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                                                                                                      ),
                                                                                                      Icon(
                                                                                                        CupertinoIcons.doc,
                                                                                                        size: 17,
                                                                                                        color: kPrimaryColor,
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        width: 3,
                                                                                                      ),
                                                                                                      Text(
                                                                                                        'File',
                                                                                                        style: TextStyle(fontSize: 14, color: Colors.grey),
                                                                                                      ),
                                                                                                    ],
                                                                                                  )
                                                                                                : Text('');
                                                                      });
                                                            } else {
                                                              return Container();
                                                            }
                                                          }),
                                                ),
                                              ],
                                            )
                                            // Container(
                                            //   decoration: BoxDecoration(
                                            //     color: kPrimaryColor,
                                            //     shape: BoxShape.circle,
                                            //   ),
                                            //   child: Center(
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(8.0),
                                            //       child: Text('1',
                                            //           style: TextStyle(
                                            //             color: Colors.white,
                                            //           )),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: 2,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyText1!
                                          .color!
                                          .withOpacity(0.1),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }
}
