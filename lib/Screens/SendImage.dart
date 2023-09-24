// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/Functions/messageManagement/messageManagement.dart';
import 'package:newchatapp/Functions/notifications/notifications.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';

class sendImage extends StatefulWidget {
  XFile imagepath;
  String ChatId;
  sendImage({Key? key, required this.imagepath, required this.ChatId})
      : super(key: key);

  @override
  State<sendImage> createState() => _sendImageState();
}

class _sendImageState extends State<sendImage> {
  TextEditingController _title = TextEditingController();

  UploadTask? task;
  bool sending = false;
  bool isloading = false;
  var userData2 = {};
  var userData = {};
  chatManagement chat = chatManagement();
  @override
  void initState() {
    // TODO: implement initState
    getData();
    getotherData();
    super.initState();
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

  getotherData() async {
    setState(() {
      isloading = true;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ChatId)
          .get();
      setState(() {
        userData2 = Usersnap.data()!;
      });
    } catch (e) {}
    setState(() {
      isloading = false;
    });
  }

  Future login() async {
    setState(() {
      sending = true;
    });

    await chat.SendImage(
        widget.ChatId, File(widget.imagepath.path), _title.text);
    var Usersnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chatrooms')
        .doc(widget.ChatId)
        .get();
    if (Usersnap.data()!['online'] == false) {
      LocalNotificationService.sendPushMessage(
        '📷 Sent a Photo',
        userData['username'],
        userData2['token'],
        userData['photoUrl'],
        userData['uid'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              leading: CupertinoButton(
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context)
                                .bottomNavigationBarTheme
                                .backgroundColor ==
                            Colors.white
                        ? Colors.black
                        : Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              backgroundColor:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              // iconTheme: IconThemeData(color: Colors.white),
              actions: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.crop,
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.emoji_emotions,
                        )),
                  ],
                )
              ],
            ),
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  widget.imagepath.path.isEmpty
                      ? Container()
                      : InteractiveViewer(
                          child: Container(
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                  colorFilter: ColorFilter.mode(
                                      Colors.black.withOpacity(0.2),
                                      BlendMode.darken),
                                  image: FileImage(File(widget.imagepath.path)),
                                  fit: BoxFit.cover),
                            ),
                          ),
                        ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          // height: 40,
                          color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .backgroundColor,
                          child: sending
                              ? chat.buildSendFileStatus()
                              : Container(),
                        ),
                        Container(
                          height: 70,
                          width: MediaQuery.of(context).size.width,
                          color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .backgroundColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              AnimatedContainer(
                                duration: Duration(
                                  milliseconds: 500,
                                ),
                                width: MediaQuery.of(context).size.width - 87,
                                decoration: BoxDecoration(
                                    color: kPrimaryColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(30)),
                                child: TextFormField(
                                  maxLines: 2,
                                  controller: _title,
                                  minLines: 1,
                                  // autofocus: true,
                                  autocorrect: true,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Type a Message...',
                                      prefixIcon:
                                          Icon(Icons.closed_caption_outlined)),
                                ),
                              ),
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                child: CupertinoButton(
                                  onPressed: () async {
                                    Vibration.vibrate(
                                        duration: 100, amplitude: 2);

                                    await login();
                                    setState(() {
                                      _title.clear();
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 300),
                                    child: CircleAvatar(
                                      radius: 19,
                                      backgroundColor: kPrimaryColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ));
  }

//   Widget _buildSendFileStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
//         stream: task.snapshotEvents,
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             final snap = snapshot.data!;
//             final progress = snap.bytesTransferred / snap.totalBytes;
//             final percentage = (progress * 100).toStringAsFixed(2);
//             return Column(
//               children: [
//                 Stack(
//                   children: [
//                     percentage == '100.00'
//                         ? SizedBox(
//                             height: 200,
//                             width: 200,
//                             child: Icon(
//                               Icons.done_outline_rounded,
//                               size: 100,
//                               color: Colors.green,
//                             ))
//                         : SizedBox(
//                             height: 200,
//                             width: 200,
//                             child: CircularProgressIndicator(
//                               color: Colors.grey,
//                               value: 1,
//                               strokeWidth: 8.0,
//                             ),
//                           ),
//                     SizedBox(
//                       height: 200,
//                       width: 200,
//                       child: CircularProgressIndicator(
//                         color: Colors.green,
//                         value: progress,
//                         strokeWidth: 8.0,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   '${(snap.bytesTransferred / 1000000).toStringAsFixed(2)}/${(snap.totalBytes / 1000000).toStringAsFixed(2)}MB ($percentage%)',
//                   style: TextStyle(color: Colors.white),
//                 ),
//               ],
//             );
//           } else {
//             return const SizedBox(
//                 height: 200,
//                 width: 200,
//                 child: CircularProgressIndicator(
//                   color: Colors.green,
//                   // value: progress,
//                   strokeWidth: 8.0,
//                 ));
//           }
//         },
//       );
// }

  Widget _buildSendFileStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    width: MediaQuery.of(context).size.width - 70,
                    child: LinearProgressIndicator(
                      color: kPrimaryColor,
                      value: progress,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          } else {
            return Container(
                color: Colors.transparent,
                height: 10,
                child: LinearProgressIndicator());
          }
        },
      );
}
