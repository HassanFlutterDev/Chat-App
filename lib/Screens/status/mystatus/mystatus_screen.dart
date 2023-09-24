// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:newchatapp/Screens/status/story_view.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:story_view/story_view.dart';
import 'package:timeago/timeago.dart' as tgo;

class MyStatus extends StatefulWidget {
  String name;
  String image;
  MyStatus({super.key, required this.image, required this.name});

  @override
  State<MyStatus> createState() => _MyStatusState();
}

class _MyStatusState extends State<MyStatus> {
  bool isLoading = false;
  var userData = {};
  StoryController controller = StoryController();
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('status')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        userData = Usersnap.data()!;
      });
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          'My Status',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: [
                Text(
                  userData['read'] == null
                      ? '0'
                      : userData['read'].length.toString(),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  width: 3,
                ),
                Icon(
                  EvaIcons.eye_outline,
                  color: Colors.white,
                )
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('status')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection('uploads')
                  .where('createdAt',
                      isGreaterThan: DateTime.now().subtract(Duration(
                        hours: 24,
                      )))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 100,
                      ),
                      CircularProgressIndicator(),
                    ],
                  );
                }
                return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      var snap = snapshot.data!.docs[index].data();
                      return ListTile(
                        onTap: () {
                          if (snap['type'] == 'text') {
                            Get.to(StroyView(
                                item: [
                                  StoryItem.text(
                                      title: snap['text'],
                                      duration: Duration(
                                        seconds:
                                            snap['text'].toString().length > 50
                                                ? 10
                                                : 3,
                                      ),
                                      backgroundColor: snap['color'] == 'red'
                                          ? Colors.red
                                          : snap['color'] == 'purple'
                                              ? Colors.purple
                                              : snap['color'] == 'green'
                                                  ? Colors.green
                                                  : snap['color'] == 'yellow'
                                                      ? Colors.yellow
                                                      : Colors.orange)
                                ],
                                image: widget.image,
                                name: widget.name,
                                uid: FirebaseAuth.instance.currentUser!.uid));
                          }
                          if (snap['type'] == 'image') {
                            Get.to(StroyView(
                                item: [
                                  snap['caption'] == ''
                                      ? StoryItem.pageImage(
                                          url: snap['image'],
                                          controller: controller)
                                      : StoryItem.pageImage(
                                          caption: snap['caption'],
                                          url: snap['image'],
                                          controller: controller),
                                ],
                                image: widget.image,
                                name: widget.name,
                                uid: FirebaseAuth.instance.currentUser!.uid));
                          }
                          if (snap['type'] == 'video') {
                            Get.to(StroyView(
                                item: [
                                  snap['caption'] == ''
                                      ? StoryItem.pageVideo(snap['video'],
                                          controller: controller)
                                      : StoryItem.pageVideo(snap['video'],
                                          caption: snap['caption'],
                                          controller: controller),
                                ],
                                image: widget.image,
                                name: widget.name,
                                uid: FirebaseAuth.instance.currentUser!.uid));
                          }
                        },
                        leading: CircleAvatar(
                          backgroundColor: kPrimaryColor,
                          child: Icon(
                            snap['type'] == 'text'
                                ? EvaIcons.text_outline
                                : snap['type'] == 'image'
                                    ? EvaIcons.image_outline
                                    : EvaIcons.video_outline,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          tgo.format(snap['createdAt'].toDate()).toString(),
                        ),
                        trailing: GestureDetector(
                            onTap: () async {
                              await FirebaseFirestore.instance
                                  .collection('status')
                                  .doc(FirebaseAuth.instance.currentUser!.uid)
                                  .collection('uploads')
                                  .doc(snap['id'])
                                  .delete();
                            },
                            child: Icon(CupertinoIcons.delete)),
                      );
                    });
              }),
        ],
      ),
    );
  }
}
