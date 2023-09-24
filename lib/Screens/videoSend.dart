// ignore_for_file: prefer_const_constructors, non_constant_identifier_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/Functions/notifications/notifications.dart';
import 'package:newchatapp/Widgets/snackbar.dart';
import 'package:uuid/uuid.dart';
import 'package:vibration/vibration.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

import '../Theme/theme.dart';

class sendVideo extends StatefulWidget {
  XFile imagepath;
  String ChatId;
  sendVideo({Key? key, required this.imagepath, required this.ChatId})
      : super(key: key);

  @override
  State<sendVideo> createState() => _sendVideoState();
}

class _sendVideoState extends State<sendVideo> {
  VideoPlayerController? _controller;
  var userData2 = {};
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.imagepath.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    getData();
    getotherData();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  TextEditingController _title = TextEditingController();
  SendImage(
    String ChatId,
    File videoUrl,
    String uid,
    String title,
  ) async {
    try {
      String postId = Uuid().v1();
      String videopath = await SendVideo(videoUrl);
      String Thumbnail = await SuploadImageVideo(videoUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'videoUrl': videopath,
        'thumbnail': Thumbnail,
        'chatId': ChatId,
        'uid': uid,
        'read': false,
        'title': title,
        'type': 'video',
        'time': DateTime.now(),
        'postId': postId
      });
      Get.back();
      Get.back();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'videoUrl': videopath,
        'thumbnail': Thumbnail,
        'chatId': ChatId,
        'uid': uid,
        'title': title,
        'read': false,
        'type': 'video',
        'time': DateTime.now(),
        'postId': postId
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'Video'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'lastMessage': 'Video'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'time': DateTime.now()});
      // Get.back();
    } catch (e) {
      Get.snackbar('error', e.toString());
    }
  }

  UploadTask? task;
  bool isloading = false;
  SgetThumbnails(File videopath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videopath.path);
    return thumbnail;
  }

  Future<String> SuploadImageVideo(File VideoPath) async {
    var postId = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child('SThumbnails').child(postId);
    UploadTask uploadTask = ref.putFile(await SgetThumbnails(VideoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }

  Future<String> SendVideo(File VideoPath) async {
    var postId = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child('Svideos').child(postId);
    task = ref.putFile(await VideoPath);
    TaskSnapshot snap = await task!;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }

  bool sending = false;
  Future login() async {
    setState(() {
      sending = true;
    });
    await SendImage(widget.ChatId, File(widget.imagepath.path),
        FirebaseAuth.instance.currentUser!.uid, _title.text);
    var Usersnap = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chatrooms')
        .doc(widget.ChatId)
        .get();
    if (Usersnap.data()!['online'] == false) {
      LocalNotificationService.sendPushMessage(
        '🎥 Sent a Video',
        userData['username'],
        userData2['token'],
        userData['photoUrl'],
        userData['uid'],
      );
    }
    // await SendVideo(File(widget.imagepath.path));
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
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: AspectRatio(
                      aspectRatio: _controller!.value.aspectRatio,
                      child: VideoPlayer(_controller!),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (_controller!.value.isPlaying) {
                          setState(() {
                            _controller!.pause();
                          });
                        } else {
                          setState(() {
                            _controller!.play();
                          });
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.4),
                        radius: 24,
                        child: Center(
                          child: Icon(
                            _controller!.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        // height: 40,
                        color: Theme.of(context)
                            .bottomNavigationBarTheme
                            .backgroundColor,
                        child:
                            sending ? _buildSendFileStatus(task!) : Container(),
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
                                  // _controller!.dispose();l

                                  await login();
                                  setState(() {
                                    _title.text = '';
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
                  )
                ],
              ),
            ));
  }

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
