// ignore_for_file: prefer_const_constructors, prefer_typing_uninitialized_variables, unused_import

import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:encrypt/encrypt.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_aes_ecb_pkcs5/flutter_aes_ecb_pkcs5.dart';
import 'package:open_file/open_file.dart';
import 'package:steganograph/steganograph.dart';
import 'package:story_view/story_view.dart';
import 'package:story_view/widgets/story_view.dart';
import 'package:uuid/uuid.dart';

import 'convert_url.dart';
import 'encryption.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    addstory();
    super.initState();
  }

  List item = [
    'https://firebasestorage.googleapis.com/v0/b/chatapp-fde18.appspot.com/o/Svideos%2F0335bee0-abce-11ed-98f6-e77453785a2c?alt=media&token=5c4d6663-7b5f-4e39-b32b-43786923c54e&_gl=1*11echqt*_ga*ODc4MzYzOTA5LjE2NzQ4OTU1MjE.*_ga_CW55HF8NVT*MTY4NTc4ODk0Ny4zNi4xLjE2ODU3ODg5NjEuMC4wLjA.',
  ];
  List<StoryItem> storyItems = [];
  addstory() {
    storyItems.add(StoryItem.pageVideo(
        'https://firebasestorage.googleapis.com/v0/b/chatapp-fde18.appspot.com/o/Svideos%2F0335bee0-abce-11ed-98f6-e77453785a2c?alt=media&token=5c4d6663-7b5f-4e39-b32b-43786923c54e&_gl=1*11echqt*_ga*ODc4MzYzOTA5LjE2NzQ4OTU1MjE.*_ga_CW55HF8NVT*MTY4NTc4ODk0Ny4zNi4xLjE2ODU3ODg5NjEuMC4wLjA.',
        controller: controller,
        duration: Duration(minutes: 3),
        caption: 'Wow'));
    storyItems.add(StoryItem.text(
        title: 'New Video Uploaded', backgroundColor: Colors.purple));
    storyItems.add(StoryItem.text(
        title: 'New Video Uploaded', backgroundColor: Colors.green));
    storyItems.add(StoryItem.pageImage(
        url:
            'https://firebasestorage.googleapis.com/v0/b/chatapp-fde18.appspot.com/o/sendImage%2F09ec75b0-d0ab-11ed-8105-0b47c9e385fd.jpg?alt=media&token=e0dee5cd-beb6-444d-b501-65a650969811&_gl=1*529kjv*_ga*ODc4MzYzOTA5LjE2NzQ4OTU1MjE.*_ga_CW55HF8NVT*MTY4NTc4ODk0Ny4zNi4xLjE2ODU3ODkxMDEuMC4wLjA.',
        controller: controller));
  }

  StoryController controller = StoryController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoryView(
        storyItems: storyItems,
        controller: controller,
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
