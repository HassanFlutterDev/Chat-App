// ignore_for_file: prefer_const_constructors, avoid_unnecessary_containers, unused_local_variable, non_constant_identifier_names, empty_catches, use_build_context_synchronously, sized_box_for_whitespace

import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newchatapp/Functions/ChatMnagement/chat_functions.dart';
import 'package:newchatapp/Widgets/Shimmer.dart';
import 'package:icons_plus/icons_plus.dart';
import '../Theme/theme.dart';

class peopleScreen extends StatefulWidget {
  peopleScreen({Key? key}) : super(key: key);

  @override
  State<peopleScreen> createState() => _peopleScreenState();
}

class _peopleScreenState extends State<peopleScreen> {
  var userData2 = {};
  getotherData() async {
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        userData2 = Usersnap.data()!;
      });
    } catch (e) {}
  }

  @override
  void initState() {
    getotherData();
    // TODO: implement initState
    load();
    super.initState();
  }

  Future load() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      isloading = false;
    });
  }

  bool isshow = false;
  String user = '';
  bool isloading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Lets Talk',
          style: TextStyle(
              color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 100,
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text('People',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                      color: kPrimaryColor,
                                      fontSize: 37,
                                      fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .textTheme
                              .bodyText1!
                              .color!
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10)),
                      child: TextFormField(
                        onChanged: (v) {
                          user = v;
                          isshow = true;
                          setState(() {});
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            prefixIcon: Icon(CupertinoIcons.search)),
                      ),
                    ),
                  ],
                ),
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
            isshow
                ? StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('searchIndex', arrayContains: user)
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ShimmerSearch();
                      } else {
                        return CupertinoScrollbar(
                          child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              scrollDirection: Axis.vertical,
                              dragStartBehavior: DragStartBehavior.start,
                              keyboardDismissBehavior:
                                  ScrollViewKeyboardDismissBehavior.onDrag,
                              itemCount: snapshot.data!.docs.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                var snap = snapshot.data!.docs[index].data();
                                return Container(
                                  // height: MediaQuery.of(context).size.height,
                                  // color: kPrimaryColor,
                                  child:
                                      snap['uid'] !=
                                              FirebaseAuth
                                                  .instance.currentUser!.uid
                                          ? InkWell(
                                              // onTap: () async {
                                              //   Fluttertoast.showToast(
                                              //       msg:
                                              //           'Please Wait We are Fetching Your Data!',
                                              //       backgroundColor: kPrimaryColor);
                                              //   String name = await getname();
                                              //   await firestore().CreateChatRoom(
                                              //       snap['uid'],
                                              //       name,
                                              //       snap['username'],
                                              //       userData2['photoUrl'],
                                              //       snap['photoUrl'],
                                              //       context);
                                              // },
                                              child: Container(
                                                height: 70,
                                                color: Colors.transparent,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: CircleAvatar(
                                                        backgroundImage:
                                                            NetworkImage(snap[
                                                                'photoUrl']),
                                                        radius: 30,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width -
                                                            75,
                                                        color:
                                                            Colors.transparent,
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Container(
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                          snap[
                                                                              'username'],
                                                                          style: TextStyle(
                                                                              color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.8),
                                                                              fontWeight: FontWeight.bold,
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
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          Container(
                                                                            height:
                                                                                30,
                                                                            color:
                                                                                Colors.transparent,
                                                                            width:
                                                                                210,
                                                                            child:
                                                                                Wrap(
                                                                              children: [
                                                                                Text(snap['bio'], style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 12)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      snap['friends'].contains(FirebaseAuth
                                                                              .instance
                                                                              .currentUser!
                                                                              .uid)
                                                                          ? Container()
                                                                          : GestureDetector(
                                                                              onTap: () async {
                                                                                await FirebaseFirestore.instance.collection('users').doc(snap['uid']).update({
                                                                                  'request': FieldValue.arrayUnion([
                                                                                    FirebaseAuth.instance.currentUser!.uid
                                                                                  ]),
                                                                                });
                                                                              },
                                                                              child: Container(
                                                                                height: 34,
                                                                                width: 40,
                                                                                decoration: BoxDecoration(
                                                                                  color: kPrimaryColor,
                                                                                  borderRadius: BorderRadius.circular(7),
                                                                                ),
                                                                                child: Icon(
                                                                                  snap['request'].contains(FirebaseAuth.instance.currentUser!.uid) ? EvaIcons.person_done : EvaIcons.person_add,
                                                                                  color: Colors.white,
                                                                                ),
                                                                              ),
                                                                            )
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              height: 2,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodyText1!
                                                                  .color!
                                                                  .withOpacity(
                                                                      0.1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                );
                              }),
                        );
                      }
                    })
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .snapshots(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return ShimmerSearch();
                      } else {
                        return isloading
                            ? ShimmerSearch()
                            : CupertinoScrollbar(
                                child: ListView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    scrollDirection: Axis.vertical,
                                    dragStartBehavior: DragStartBehavior.start,
                                    keyboardDismissBehavior:
                                        ScrollViewKeyboardDismissBehavior
                                            .onDrag,
                                    itemCount: snapshot.data!.docs.length,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      var snap =
                                          snapshot.data!.docs[index].data();
                                      return Container(
                                        // height: MediaQuery.of(context).size.height,
                                        // color: kPrimaryColor,
                                        child:
                                            snap['uid'] !=
                                                    FirebaseAuth.instance
                                                        .currentUser!.uid
                                                ? InkWell(
                                                    // onTap: () async {
                                                    //   Fluttertoast.showToast(
                                                    //       msg:
                                                    //           'Please Wait We are Fetching Your Data!',
                                                    //       backgroundColor: kPrimaryColor);
                                                    //   String name = await getname();
                                                    //   await firestore().CreateChatRoom(
                                                    //       snap['uid'],
                                                    //       name,
                                                    //       snap['username'],
                                                    //       userData2['photoUrl'],
                                                    //       snap['photoUrl'],
                                                    //       context);
                                                    //   setState(() {
                                                    //     isloading = false;
                                                    //   });
                                                    // },
                                                    child: Container(
                                                      height: 70,
                                                      color: Colors.transparent,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child: CircleAvatar(
                                                              backgroundImage:
                                                                  NetworkImage(snap[
                                                                      'photoUrl']),
                                                              radius: 30,
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 5),
                                                            child: Container(
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  75,
                                                              color: Colors
                                                                  .transparent,
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Text(snap['username'],
                                                                                style: TextStyle(color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.8), fontWeight: FontWeight.bold, fontSize: 16)),
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Column(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  height: 30,
                                                                                  color: Colors.transparent,
                                                                                  width: 210,
                                                                                  child: Wrap(
                                                                                    children: [
                                                                                      Text(snap['bio'], style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.5), fontWeight: FontWeight.bold, fontSize: 12)),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            snap['friends'].contains(FirebaseAuth.instance.currentUser!.uid)
                                                                                ? Container()
                                                                                : GestureDetector(
                                                                                    onTap: () async {
                                                                                      await FirebaseFirestore.instance.collection('users').doc(snap['uid']).update({
                                                                                        'request': FieldValue.arrayUnion([
                                                                                          FirebaseAuth.instance.currentUser!.uid
                                                                                        ]),
                                                                                      });
                                                                                    },
                                                                                    child: Container(
                                                                                      height: 34,
                                                                                      width: 40,
                                                                                      decoration: BoxDecoration(
                                                                                        color: kPrimaryColor,
                                                                                        borderRadius: BorderRadius.circular(7),
                                                                                      ),
                                                                                      child: Icon(
                                                                                        snap['request'].contains(FirebaseAuth.instance.currentUser!.uid) ? EvaIcons.person_done : EvaIcons.person_add,
                                                                                        color: Colors.white,
                                                                                      ),
                                                                                    ),
                                                                                  )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    height: 2,
                                                                    color: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .bodyText1!
                                                                        .color!
                                                                        .withOpacity(
                                                                            0.1),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                      );
                                    }),
                              );
                      }
                    }),
          ],
        ),
      ),
    );
  }
}

Future<String> getname() async {
  var Usersnap = await FirebaseFirestore.instance
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get();
  var userData = {};
  userData = Usersnap.data()!;
  String username = userData['username'];
  return username;
}
