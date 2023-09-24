// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, camel_case_types

import 'package:animations/animations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Screens/full_photo.dart';
import 'package:newchatapp/Screens/message_screen.dart';
import 'package:newchatapp/Screens/profile_sections/media_link_screen.dart';
import 'package:newchatapp/Screens/profile_sections/wallpaper_screen.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:newchatapp/Widgets/size_config.dart';

class profile_Screen extends StatefulWidget {
  String uid;
  profile_Screen({super.key, required this.uid});

  @override
  State<profile_Screen> createState() => _profile_ScreenState();
}

class _profile_ScreenState extends State<profile_Screen> {
  double? defualtSize = SizeConfig.defaultSize;
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    getData();
  }

  var userData = {};
  getData() async {
   setState(() {
      isLoading = true
      ;
    });
    try {
      var Usersnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
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
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Colors.black
              : kContentColorDarkTheme,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : kPrimaryColor,
        foregroundColor:
            Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : kPrimaryColor,
        leading: CupertinoButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 23,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: Center(
          child: Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
            ),
          ),
        ),
        actions: [
          CupertinoButton(
            child: Text(
              'Edit',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Column(children: [
        SizedBox(
          height: MediaQuery.of(context).size.height / 3,
          child: Stack(
            children: [
              ClipPath(
                clipper: CustomShape(),
                child: Container(
                  height: MediaQuery.of(context).size.height / 3.9,
                  color: Theme.of(context).scaffoldBackgroundColor ==
                          kContentColorLightTheme
                      ? Color.fromARGB(255, 56, 56, 56)
                      : kPrimaryColor,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    OpenContainer(
                        closedColor: Colors.transparent,
                        middleColor: Color.fromARGB(255, 0, 0, 0),
                        openColor: Color.fromARGB(255, 0, 0, 0),
                        closedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        openShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(70)),
                        closedElevation: 15.0,
                        transitionDuration: Duration(
                          milliseconds: 500,
                        ),
                        transitionType: ContainerTransitionType.fade,
                        openBuilder: (_, __) {
                          return full_screen(
                            url: userData['photoUrl'],
                          );
                        },
                        closedBuilder: (_, __) {
                          return CupertinoButton(
                            onPressed: __,
                            child: Container(
                              // margin: EdgeInsets.only(bottom: 10), //10
                              height: 130, //140
                              width: 130,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 8, //8
                                ),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(isLoading
                                      ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhW0hzwECDKq0wfUqFADEJaNGESHQ8GRCJIg&usqp=CAU'
                                      : userData['photoUrl']),
                                ),
                              ),
                            ),
                          );
                        }),
                    Text(
                      isLoading ? 'loading...' : userData['username'],
                      style: TextStyle(
                        fontSize: 17, // 22
                      ),
                    ),
                    SizedBox(height: 8), //5
                    Text(
                      isLoading ? 'Loading...' : userData['email'],
                      style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8492A2),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 8,
        ),
        OpenContainer(
            closedColor: Colors.transparent,
            middleColor: Color.fromARGB(255, 0, 0, 0),
            openColor: Color.fromARGB(255, 0, 0, 0),
            closedShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            openShape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
            closedElevation: 15.0,
            transitionDuration: Duration(
              milliseconds: 500,
            ),
            transitionType: ContainerTransitionType.fade,
            openBuilder: (_, __) {
              return messageScreen(
                chatId: userData['uid'],
                uid: userData['uid'],
              );
            },
            closedBuilder: (_, __) {
              return CupertinoButton(
                onPressed: __,
                child: Container(
                  height: 60,
                  // margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor ==
                            kContentColorLightTheme
                        ? Color.fromARGB(255, 56, 56, 56)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 7,
                      ),
                      Icon(
                        CupertinoIcons.chat_bubble_fill,
                        color: kPrimaryColor,
                        size: 25,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        'Chats',
                        style: TextStyle(
                          fontSize: 17,
                          color: kPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
        Container(
            // height: 50,
            // margin: EdgeInsets.symmetric(horizontal: 8),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor ==
                      kContentColorLightTheme
                  ? Color.fromARGB(255, 56, 56, 56)
                  : Colors.white,
              borderRadius: BorderRadius.circular(0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Text(
                isLoading ? 'Loading...' : userData['bio'],
              ),
            )),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 120,
          margin: EdgeInsets.symmetric(horizontal: 17),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor ==
                    kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 1.5,
              ),
              InkWell(
                onTap: () {
                  Get.to(
                      profile_media_screen(
                        uid: userData['uid'],
                      ),
                      transition: Transition.cupertino);
                },
                child: Container(
                  height: 78,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4, bottom: 4),
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Text(
                                  'Media,Links and Docs',
                                  style: TextStyle(
                                      // fontSize: 17,
                                      // color: Colors.green,
                                      // fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 22,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width - 90,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.1),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Get.to(HomePageWidget(),
                              transition: Transition.cupertino);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.pink,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 4, right: 4, bottom: 4),
                                      child: Icon(
                                        Icons.wallpaper,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 13,
                                  ),
                                  Text(
                                    'Wallpaper',
                                    style: TextStyle(
                                        // fontSize: 17,
                                        // color: Colors.green,
                                        // fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 22,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width - 90,
                    color: Theme.of(context)
                        .textTheme
                        .bodyText1!
                        .color!
                        .withOpacity(0.1),
                  ),
                ],
              ),
              InkWell(
                onTap: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 7,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 4, left: 4, right: 4, bottom: 4),
                              child: Icon(
                                Icons.volume_up,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 13,
                          ),
                          Text(
                            'Mute',
                            style: TextStyle(
                                // fontSize: 17,
                                // color: Colors.green,
                                // fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 22,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 80,
          margin: EdgeInsets.symmetric(horizontal: 17),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor ==
                    kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 1.5,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                  height: 78,
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4, bottom: 4),
                                    child: Icon(
                                      CupertinoIcons.lock_fill,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Text(
                                  'Encryption',
                                  style: TextStyle(
                                      // fontSize: 17,
                                      // color: Colors.green,
                                      // fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 22,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            height: 1,
                            width: MediaQuery.of(context).size.width - 90,
                            color: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .color!
                                .withOpacity(0.1),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 7,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 4, right: 4, bottom: 4),
                                      child: Icon(
                                        CupertinoIcons.profile_circled,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 13,
                                  ),
                                  Text(
                                    'Users Details',
                                    style: TextStyle(
                                        // fontSize: 17,
                                        // color: Colors.green,
                                        // fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 22,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 43,
          margin: EdgeInsets.symmetric(horizontal: 17),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor ==
                    kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 3.5,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                    height: 38,
                    color: Colors.transparent,
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4, bottom: 4),
                                    child: Icon(
                                      Icons.block,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Text(
                                  'Block ${isLoading ? '' : userData['username']}',
                                  style: TextStyle(
                                    // fontSize: 17,
                                    color: Colors.red,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ])),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Container(
          height: 43,
          margin: EdgeInsets.symmetric(horizontal: 17),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor ==
                    kContentColorLightTheme
                ? Color.fromARGB(255, 56, 56, 56)
                : Colors.white,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 3.5,
              ),
              InkWell(
                onTap: () {},
                child: Container(
                    height: 38,
                    color: Colors.transparent,
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 7,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4, left: 4, right: 4, bottom: 4),
                                    child: Icon(
                                      Icons.report,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 13,
                                ),
                                Text(
                                  'Report ${isLoading ? '' : userData['username']}',
                                  style: TextStyle(
                                    // fontSize: 17,
                                    color: Colors.red,
                                    // fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ])),
              ),
            ],
          ),
        ),
      ])),
    );
  }
}

class CustomShape extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    double height = size.height;
    double width = size.width;
    path.lineTo(0, height - 100);
    path.quadraticBezierTo(width / 2, height, width, height - 100);
    path.lineTo(width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
