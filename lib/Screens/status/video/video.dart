// ignore_for_file: prefer_const_constructors, non_constant_identifier_names, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/Functions/messageManagement/messageManagement.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoStatus extends StatefulWidget {
  XFile imagepath;
  VideoStatus({Key? key, required this.imagepath}) : super(key: key);

  @override
  State<VideoStatus> createState() => _VideoStatusState();
}

class _VideoStatusState extends State<VideoStatus> {
  VideoPlayerController? _controller;
  var userData2 = {};
  var userData = {};
  bool isloading = false;
  bool sending = false;
  chatManagement chat = chatManagement();
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

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.imagepath.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    getData();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  TextEditingController _title = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    child: sending ? chat.buildSendFileStatus() : Container(),
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
                                hintText: 'Type a Caption...',
                                prefixIcon:
                                    Icon(Icons.closed_caption_outlined)),
                          ),
                        ),
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          child: CupertinoButton(
                            onPressed: () async {
                              setState(() {
                                sending = true;
                              });
                              await chat.sendVideoStatus(
                                userData['username'],
                                userData['photoUrl'],
                                widget.imagepath.path,
                                _title.text,
                              );
                              setState(() {
                                sending = false;
                                _title.clear();
                              });
                              Navigator.pop(context);
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
}
