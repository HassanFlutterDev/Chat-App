// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:newchatapp/Screens/message_screen.dart';
import 'package:story_view/story_view.dart';

class StroyView extends StatefulWidget {
  List<StoryItem> item;
  String image;
  String name;
  String uid;
  StroyView(
      {Key? key,
      required this.item,
      required this.image,
      required this.name,
      required this.uid})
      : super(key: key);
  @override
  _StroyViewState createState() => _StroyViewState();
}

class _StroyViewState extends State<StroyView> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  StoryController controller = StoryController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            StoryView(
              inline: true,
              storyItems: widget.item,
              controller: controller,
              onStoryShow: (value) {},
              onComplete: () {
                Navigator.pop(context);
              },
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) {
                  Navigator.pop(context);
                } else if (direction == Direction.up) {
                  Get.to(messageScreen(
                    uid: widget.uid,
                    chatId: widget.uid,
                  ));
                }
              },
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Platform.isAndroid
                                ? Icons.arrow_back
                                : Icons.arrow_back_ios,
                            color: Colors.white,
                          )),
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(widget.image),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        EvaIcons.arrow_ios_upward_outline,
                        color: Colors.white,
                        size: 46,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
