// ignore_for_file: prefer_const_constructors, unused_import, unused_local_variable, prefer_const_literals_to_create_immutables, prefer_final_fields

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/Functions/messageManagement/messageManagement.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:uuid/uuid.dart';

class ImageStatusSend extends StatefulWidget {
  XFile imagepath;
  ImageStatusSend({Key? key, required this.imagepath}) : super(key: key);

  @override
  State<ImageStatusSend> createState() => _ImageStatusSendState();
}

class _ImageStatusSendState extends State<ImageStatusSend> {
  TextEditingController _title = TextEditingController();
  bool sending = false;
  bool isloading = false;
  var userData = {};
  chatManagement chat = chatManagement();
  @override
  void initState() {
    getData();
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
                                    await chat.sendImageStatus(
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
}
