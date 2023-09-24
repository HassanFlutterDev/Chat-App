import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:newchatapp/Screens/calling/outgoing_call.dart';

import '../../Functions/notifications/notifications.dart';

class incoming_call extends StatefulWidget {
  String callId;
  String name;
  String? nameO;
  String? email;
  String image;
  String uid;
  bool voice;
  String token;
  incoming_call(
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
  State<incoming_call> createState() => _incoming_callState();
}

class _incoming_callState extends State<incoming_call> {
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
            GetStorage().remove('incoming call');
            GetStorage().remove('callId');
            return callPage(
              uid1: snapshot.data?['uid'],
              image: widget.image,
              name: widget.name,
              uid: FirebaseAuth.instance.currentUser!.uid,
              callId: widget.callId,
              voice: snapshot.data?['type'] == 'voice' ? true : false,
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
                      snapshot.data?['name'],
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
                      'Incoming Call',
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
                        AwesomeNotifications().cancel(124);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('calls')
                            .doc(snapshot.data?['callId'])
                            .update({
                          'hang up': true,
                          'status': 'declined',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .collection('calls')
                            .doc(snapshot.data?['callId'])
                            .update({
                          'hang up': true,
                          'status': 'declined',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'call': false,
                        });
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
                            .doc(snapshot.data?['uid'])
                            .update({
                          'call': false,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .update({
                          'callId': '',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .update({
                          'callUid': '',
                        });

                        // await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('calls').doc()
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.red,
                          child: Image.asset(
                            "images/phone_hang.png",
                            height: 35,
                          )),
                    ),
                    SizedBox(
                      width: 40,
                    ),
                    GestureDetector(
                      onTap: () async {
                        AwesomeNotifications().cancel(124);
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .collection('calls')
                            .doc(snapshot.data?['callId'])
                            .update({
                          'hang up': true,
                          'status': 'accept',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .collection('calls')
                            .doc(snapshot.data?['callId'])
                            .update({
                          'hang up': true,
                          'status': 'accept',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'call': false,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'callId': '',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .update({
                          'call': false,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(FirebaseAuth.instance.currentUser!.uid)
                            .update({
                          'callAccept': false,
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .update({
                          'callId': '',
                        });
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(snapshot.data?['uid'])
                            .update({
                          'callUid': '',
                        });

                        // await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).collection('calls').doc()
                        // Get.back();
                      },
                      child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.call,
                            size: 35,
                            color: Colors.white,
                          )),
                    ),
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
