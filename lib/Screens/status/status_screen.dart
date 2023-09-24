// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, deprecated_member_use, use_build_context_synchronously

import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newchatapp/Screens/status/image/image.dart';
import 'package:newchatapp/Screens/status/mystatus/mystatus_screen.dart';
import 'package:newchatapp/Screens/status/story_view.dart';
import 'package:newchatapp/Screens/status/text/text.dart';
import 'package:newchatapp/Screens/status/video/video.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:story_view/story_view.dart';
import 'package:timeago/timeago.dart' as tgo;

class StatusScreen extends StatefulWidget {
  StatusScreen({Key? key}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  var userData = {};
  bool isLoading = false;
  List loading = [];
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
          .collection('users')
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

  Future getItems(String uid) async {
    List<StoryItem> storyItems = [];
    var userdoc = await FirebaseFirestore.instance
        .collection('status')
        .doc(uid)
        .collection('uploads')
        .where('createdAt',
            isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
        .get();
    final allata = userdoc.docs.map((doc) => doc.data()).toList();
    List status = allata.toList();
    for (var i = 0; i < status.length; i++) {
      if (status[i]['type'] == 'text') {
        storyItems.add(StoryItem.text(
            title: status[i]['text'],
            duration: Duration(
              seconds: status[i]['text'].toString().length > 50 ? 10 : 3,
            ),
            backgroundColor: status[i]['color'] == 'red'
                ? Colors.red
                : status[i]['color'] == 'purple'
                    ? Colors.purple
                    : status[i]['color'] == 'green'
                        ? Colors.green
                        : status[i]['color'] == 'yellow'
                            ? Colors.yellow
                            : Colors.orange));
      } else if (status[i]['type'] == 'image') {
        if (status[i]['caption'] == '') {
          storyItems.add(StoryItem.pageImage(
              url: status[i]['image'], controller: controller));
        } else {
          storyItems.add(StoryItem.pageImage(
              caption: status[i]['caption'],
              url: status[i]['image'],
              controller: controller));
        }
      } else if (status[i]['type'] == 'video') {
        if (status[i]['caption'] == '') {
          storyItems.add(
              StoryItem.pageVideo(status[i]['video'], controller: controller));
        } else {
          storyItems.add(StoryItem.pageVideo(status[i]['video'],
              caption: status[i]['caption'], controller: controller));
        }
      }
    }
    return storyItems;
  }

  Future getStatus() async {
    List<StatusPeoples> requestsList = [];
    List<StoryItem> storyItems = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('Chatrooms')
        .get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    List finalList = allData.toList();
    if (finalList.isNotEmpty) {
      for (var i = 0; i < finalList.length; i++) {
        var userDoc = await FirebaseFirestore.instance
            .collection('status')
            .where('uid', isEqualTo: finalList[i]['uid'])
            .where('createdAt',
                isGreaterThan: DateTime.now().subtract(Duration(hours: 24)))
            .get();
        final allData = userDoc.docs.map((doc) => doc.data()).toList();
        List data = allData.toList();
        // log(data.toString());
        if (data.isNotEmpty) {
          for (var i = 0; i < data.length; i++) {
            requestsList.add(StatusPeoples(
                name: data[i]['name'],
                read: data[i]['read'],
                url: data[i]['image'],
                time: data[i]['createdAt'],
                uid: data[i]['uid']));
            // storyItems.clear();
          }
        }
      }
      return requestsList;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
              context: context,
              builder: (BuildContext c) {
                return Container(
                  height: 220,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              child: GestureDetector(
                                onTap: () async {
                                  Get.to(TextStatusScreen());
                                },
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Text"),
                                      SizedBox(width: 12.0),
                                      Icon(EvaIcons.text_outline),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // for email
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              child: GestureDetector(
                                onTap: () async {
                                  XFile? video = await ImagePicker().pickVideo(
                                    source: ImageSource.gallery,
                                  );
                                  if (video != null) {
                                    Get.to(VideoStatus(
                                        imagepath: XFile(video.path)));
                                  }
                                },
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Video"),
                                      SizedBox(width: 12.0),
                                      Icon(EvaIcons.video_outline),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // for admin
                            GestureDetector(
                              onTap: () async {
                                XFile? image = await ImagePicker().pickImage(
                                  source: ImageSource.gallery,
                                );
                                if (image != null) {
                                  Get.to(ImageStatusSend(
                                      imagepath: XFile(image.path)));
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                child: Container(
                                  height: 50.0,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(20.0),
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Image"),
                                      SizedBox(width: 12.0),
                                      Icon(EvaIcons.image_outline),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // end
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
        backgroundColor: kPrimaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // SizedBox(height: 10),
              // // label
              // // Padding(
              // //   padding: const EdgeInsets.symmetric(horizontal: 8),
              // //   child: Row(
              // //     children: [
              // //       Text(
              // //         "Status",
              // //         style: TextStyle(
              // //           fontWeight: FontWeight.bold,
              // //           fontSize: 40,
              // //         ),
              // //       ),
              // //     ],
              // //   ),
              // // ),
              // SizedBox(
              //   height: 5,
              // ),
              Container(
                height: 32,
                width: double.infinity,
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(0.1),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'My Status',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              InkWell(
                onTap: () {
                  Get.to(MyStatus(
                    image: userData['photoUrl'],
                    name: userData['username'],
                  ));
                },
                child: Container(
                  height: 70,
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.amber,
                            backgroundImage: NetworkImage(!isLoading
                                ? userData['photoUrl']
                                : 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhW0hzwECDKq0wfUqFADEJaNGESHQ8GRCJIg&usqp=CAU'),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5),
                        child: Container(
                          width: MediaQuery.of(context).size.width - 75,
                          color: Colors.transparent,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                      isLoading
                                          ? 'loading..'
                                          : userData['username'],
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .bodyText1!
                                              .color!
                                              .withOpacity(0.8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      width: 230,
                                      child: Wrap(
                                        children: [
                                          Text('Your Status',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .copyWith(
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyText1!
                                                          .color!
                                                          .withOpacity(0.5),
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 32,
                width: double.infinity,
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .withOpacity(0.1),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Recent Update',
                        style: TextStyle(
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              FutureBuilder(
                  future: getStatus(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 100,
                          ),
                          Center(child: Text('There Is No Status Available.')),
                        ],
                      );
                    }
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        dragStartBehavior: DragStartBehavior.start,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: snapshot.data.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  loading.add(snapshot.data[index].uid);
                                });
                                List<StoryItem> items =
                                    await getItems(snapshot.data[index].uid);
                                if (snapshot.data[index].read.contains(
                                    FirebaseAuth.instance.currentUser!.uid)) {
                                  FirebaseFirestore.instance
                                      .collection('status')
                                      .doc(snapshot.data[index].uid)
                                      .update({
                                    'read': FieldValue.arrayRemove([
                                      FirebaseAuth.instance.currentUser!.uid
                                    ])
                                  });
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('status')
                                      .doc(snapshot.data[index].uid)
                                      .update({
                                    'read': FieldValue.arrayUnion([
                                      FirebaseAuth.instance.currentUser!.uid
                                    ])
                                  });
                                }
                                setState(() {
                                  loading.remove(snapshot.data[index].uid);
                                });
                                Get.to(StroyView(
                                  uid: snapshot.data[index].uid,
                                  item: items,
                                  image: snapshot.data[index].url,
                                  name: snapshot.data[index].name,
                                ));
                              },
                              child: Container(
                                height: 70,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4),
                                      child: Stack(
                                        children: [
                                          CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                snapshot.data[index].url),
                                            radius: 30,
                                          ),
                                          Container(
                                              height: 60,
                                              width: 60,
                                              child: loading.contains(
                                                      snapshot.data[index].uid)
                                                  ? CircularProgressIndicator()
                                                  : Container()),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                75,
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Text(snapshot.data[index].name,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .color!
                                                                  .withOpacity(
                                                                      0.8),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Container(
                                                        color:
                                                            Colors.transparent,
                                                        width: 230,
                                                        child: Wrap(
                                                          children: [
                                                            Text(
                                                                tgo
                                                                    .format(snapshot
                                                                        .data[
                                                                            index]
                                                                        .time
                                                                        .toDate())
                                                                    .toString(),
                                                                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText1!
                                                                        .color!
                                                                        .withOpacity(
                                                                            0.5),
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              height: 2,
                                              color: Theme.of(context)
                                                  .textTheme
                                                  .bodyText1!
                                                  .color!
                                                  .withOpacity(0.1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  })
            ],
          ),
        ),
      ),
    );
  }
}

class StatusPeoples {
  String uid;
  String name;
  String url;
  var time;
  List read;
  StatusPeoples({
    required this.name,
    required this.url,
    required this.read,
    required this.uid,
    required this.time,
  });
}
