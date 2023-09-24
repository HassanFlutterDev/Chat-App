import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Functions/ChatMnagement/chat_functions.dart';
import 'package:newchatapp/Widgets/Shimmer.dart';

class request_screen extends StatefulWidget {
  const request_screen({super.key});

  @override
  State<request_screen> createState() => _request_screenState();
}

class _request_screenState extends State<request_screen> {
  bool isLoading = false;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _currentUser = FirebaseAuth.instance;
  var userData = {};
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
          .doc(_currentUser.currentUser!.uid)
          .get();

      setState(() {
        userData = Usersnap.data()!;
      });
    } catch (e) {}
    setState(() {
      isLoading = false;
    });
  }

  Future getRequests() async {
    List<dynamic> requests = [];
    List<FriendModel> requestsList = [];
    await _firestore
        .collection('users')
        .doc(_currentUser.currentUser!.uid)
        .get()
        .then(
      (value) {
        requests = value.data()!["request"];
        log(value.data()!["requests"].toString());
      },
    );
    if (requests.isNotEmpty)
      requests.forEach((element) async {
        log(element.toString());
        String name = "";
        String uid = "";
        String url = "";
        String email = "";
        List searchIndex = [];
        if (element != "")
          await _firestore
              .collection('users')
              .where('uid', isEqualTo: element.toString())
              .get()
              .then(
            (value) {
              name = value.docs[0].data()["username"];
              uid = value.docs[0].data()["uid"];
              email = value.docs[0].data()["email"];
              url = value.docs[0].data()["photoUrl"];
              searchIndex = value.docs[0].data()["searchIndex"];
              log(name + uid);
              requestsList.add(
                FriendModel(
                    email: email,
                    name: name,
                    uid: element,
                    url: url,
                    searchIndex: searchIndex),
              );
            },
          );

        log(requests.toString());
      });
    await Future.delayed(
      Duration(seconds: 2),
    );
    return requestsList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: getRequests(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data.length == 0) {
                      return Column(
                        children: [
                          SizedBox(
                            height: 300,
                          ),
                          Center(
                            child: Text(
                                'You haven\'t recieved any friend Request!'),
                          )
                        ],
                      );
                    }

                    return Container(
                      height: MediaQuery.of(context).size.height - 120,
                      color: Colors.transparent,
                      child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Container(
                              height: 70,
                              color: Colors.transparent,
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          snapshot.data[index].url),
                                      radius: 30,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 5),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width -
                                          75,
                                      color: Colors.transparent,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                        snapshot
                                                            .data[index].name,
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .textTheme
                                                                .bodyText1!
                                                                .color!
                                                                .withOpacity(
                                                                    0.8),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16)),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        Container(
                                                          height: 30,
                                                          color: Colors
                                                              .transparent,
                                                          width: 210,
                                                          child: Wrap(
                                                            children: [
                                                              Text(
                                                                  snapshot
                                                                      .data[
                                                                          index]
                                                                      .email,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText1!
                                                                      .copyWith(
                                                                          color: Theme.of(context)
                                                                              .textTheme
                                                                              .bodyText1!
                                                                              .color!
                                                                              .withOpacity(
                                                                                  0.5),
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              12)),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                barrierDismissible:
                                                                    false,
                                                                builder:
                                                                    (context) =>
                                                                        Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        ));
                                                            firestore().CreateChatRoom(
                                                                snapshot
                                                                    .data[index]
                                                                    .uid,
                                                                userData[
                                                                    'username'],
                                                                snapshot
                                                                    .data[index]
                                                                    .name,
                                                                userData[
                                                                    'photoUrl'],
                                                                snapshot
                                                                    .data[index]
                                                                    .url,
                                                                snapshot
                                                                    .data[index]
                                                                    .searchIndex,
                                                                userData[
                                                                    'searchIndex'],
                                                                context);
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.green,
                                                            child: Icon(
                                                              EvaIcons
                                                                  .checkmark,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 9,
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'users')
                                                                .doc(FirebaseAuth
                                                                    .instance
                                                                    .currentUser!
                                                                    .uid)
                                                                .update({
                                                              "request": FieldValue
                                                                  .arrayRemove([
                                                                snapshot
                                                                    .data[index]
                                                                    .uid
                                                              ]),
                                                            });
                                                          },
                                                          child: CircleAvatar(
                                                            radius: 16,
                                                            backgroundColor:
                                                                Colors.red,
                                                            child: Icon(
                                                              EvaIcons.close,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                    // GestureDetector(
                                                    //   onTap: () async {
                                                    //     await FirebaseFirestore
                                                    //         .instance
                                                    //         .collection('users')
                                                    //         .doc(snap['uid'])
                                                    //         .update({
                                                    //       'request': FieldValue
                                                    //           .arrayUnion([
                                                    //         FirebaseAuth.instance
                                                    //             .currentUser!.uid
                                                    //       ]),
                                                    //     });
                                                    //   },
                                                    //   child: Container(
                                                    //     height: 34,
                                                    //     width: 40,
                                                    //     decoration: BoxDecoration(
                                                    //       color: kPrimaryColor,
                                                    //       borderRadius:
                                                    //           BorderRadius
                                                    //               .circular(7),
                                                    //     ),
                                                    //     child: Icon(
                                                    //       snap['request'].contains(
                                                    //               FirebaseAuth
                                                    //                   .instance
                                                    //                   .currentUser!
                                                    //                   .uid)
                                                    //           ? EvaIcons.checkmark
                                                    //           : EvaIcons
                                                    //               .personAdd,
                                                    //       color: Colors.white,
                                                    //     ),
                                                    //   ),
                                                    // )
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
                            );
                          }),
                    );
                  } else {
                    return ShimmerSearch();
                  }
                })
          ],
        ),
      ),
    );
  }
}

class FriendModel {
  String uid;
  String name;
  String url;
  String email;
  List searchIndex;
  FriendModel({
    required this.email,
    required this.name,
    required this.searchIndex,
    required this.url,
    required this.uid,
  });
}
