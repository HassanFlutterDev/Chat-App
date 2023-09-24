// ignore_for_file: must_be_immutable, unused_import, unnecessary_import

import 'dart:async';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newchatapp/Functions/notifications/notifications.dart';
import 'package:newchatapp/Screens/home_screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class outgoing_call extends StatefulWidget {
  String callId;
  String name;
  String? nameO;
  String? email;
  String image;
  String uid;
  bool voice;
  String token;
  outgoing_call(
      {super.key,
      required this.callId,
      required this.image,
      this.nameO,
      this.email,
      required this.uid,
      required this.name,
      this.voice = true,
      required this.token});

  @override
  State<outgoing_call> createState() => _outgoing_callState();
}

class _outgoing_callState extends State<outgoing_call> {
  String hours = '00';
  String minutes = '00';
  String seconds = '00';
  int sec = 0;
  int min = 0;
  int hou = 0;
  bool show = false;
  @override
  void initState() {
    // TODO: implement initState
    // timer();
    super.initState();
    // exitCall();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('calls')
            .doc(widget.callId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: Colors.black,
            );
          }
          if (snapshot.data?['status'] == 'accept') {
            return callPage(
              uid1: widget.uid,
              image: widget.image,
              name: widget.name,
              uid: FirebaseAuth.instance.currentUser!.uid,
              callId: widget.callId,
              voice: snapshot.data?['type'] == 'voice' ? true : false,
            );
          }
          if (snapshot.data?['status'] == 'missed') {
            Get.back();
          }
          if (snapshot.data?['status'] == 'Hang Up') {
            Get.back();
          }
          if (snapshot.data?['status'] == 'declined') {
            // Future.delayed(Duration(milliseconds: 200));
            Fluttertoast.showToast(msg: 'Call Declined');
            FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .update({
              'call': false,
            });
            Get.back();
            return Scaffold(
              backgroundColor: Colors.black,
            );
          }
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.black,
              // leading: IconButton(
              //     onPressed: () {}, icon: Icon(Icons.arrow_back_ios_new)),
            ),
            body: Column(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.transparent,
                  child: Center(
                    child: CircleAvatar(
                      radius: 78,
                      backgroundColor: Colors.grey,
                      backgroundImage: NetworkImage(snapshot.data?['image']),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.nameO!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      snapshot.data?['status'],
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  ],
                ),
                Spacer(
                  flex: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        LocalNotificationService.sendcallInvitation(
                            'Missed Call',
                            widget.name,
                            widget.token,
                            widget.uid,
                            widget.callId,
                            'Missed',
                            '',
                            widget.name,
                            widget.email!,
                            widget.nameO!,
                            widget.image,
                            'Missed');
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('calls')
                            .doc(widget.callId)
                            .update({
                          'hang up': true,
                          'status': 'missed',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(widget.uid)
                            .collection('calls')
                            .doc(widget.callId)
                            .update({
                          'hang up': true,
                          'status': 'missed',
                        });

                        // await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('calls').doc()
                        Get.back();
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Image.asset(
                            "images/phone_hang.png",
                            height: 35,
                          )),
                    )
                  ],
                ),
                Spacer(
                  flex: 1,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🔒End-to-Encrypted',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          );
        });
  }
}

class callPage extends StatefulWidget {
  String? name;
  String? callId;
  String? image;
  String? uid;
  String? uid1;
  bool callBack;
  bool voice;
  callPage({
    super.key,
    this.callId,
    this.image,
    this.name,
    this.uid,
    this.uid1,
    this.callBack = false,
    this.voice = true,
  });

  @override
  State<callPage> createState() => _callPageState();
}

class _callPageState extends State<callPage> {
  String hours = '00';
  String minutes = '00';
  String seconds = '00';
  int sec = 0;
  int min = 0;
  int hou = 0;
  bool show = false;
  @override
  void initState() {
    // TODO: implement initState
    // timer();
    super.initState();
  }

  var box = GetStorage();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          ZegoUIKitPrebuiltCall(
              appID:
                  977371939, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
              appSign:
                  "64093e399768500a23b47f4c2ea86adfb08ba7df80b296da928865e6e36dc6fa", // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
              userID: FirebaseAuth.instance.currentUser!.uid,
              userName: widget.name!,
              callID: widget.callId!,
              // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
              config: widget.voice == true
                  ? ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall()
                  : ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
                ..audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
                  backgroundBuilder: (BuildContext context, Size size,
                      ZegoUIKitUser? user, Map extraInfo) {
                    return Container(
                      height: MediaQuery.of(context).size.height,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 37, 36, 43),
                        image: DecorationImage(
                            image: NetworkImage(widget.image!),
                            fit: BoxFit.cover),
                      ),
                    );
                    // : const SizedBox();
                  },
                )
                ..avatarBuilder = (BuildContext context, Size size,
                    ZegoUIKitUser? user, Map extraInfo) {
                  return user != null
                      ? BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: NetworkImage(
                                    widget.image!,
                                  ),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        )
                      : const SizedBox();
                }
                ..onHangUp = () async {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'callAccept': false,
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'callId': '',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid1)
                      .update({
                    'callAccept': false,
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .update({
                    'callId': '',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid1)
                      .update({
                    'callUid': '',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .update({
                    'callUid': '',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('calls')
                      .doc(widget.callId)
                      .update({
                    'hang up': true,
                    'status': 'Hang Up',
                  });
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid1)
                      .collection('calls')
                      .doc(widget.callId)
                      .update({
                    'hang up': true,
                    'status': 'Hang Up',
                  });

                  Get.back();
                }),
        ],
      )),
    );
  }
}
