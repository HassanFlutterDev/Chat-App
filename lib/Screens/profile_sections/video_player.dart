// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/Widgets/videoPlayer.dart';
import 'package:video_player/video_player.dart';

class VideoSend extends StatefulWidget {
  String snap;
  VideoSend({Key? key, required this.snap}) : super(key: key);

  @override
  State<VideoSend> createState() => _VideoSendState();
}

class _VideoSendState extends State<VideoSend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 27,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer1(
                file:
                    // 'https://ak.picdn.net/shutterstock/videos/1065170830/preview/stock-footage-nature-river-waterfall-forest-sun-morning-magical.webm'
                    File(widget.snap),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
