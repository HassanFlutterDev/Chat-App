// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Functions/Auth/auth_functions.dart';
import 'package:newchatapp/Screens/setting/theme_screen.dart';
import 'package:newchatapp/Screens/welcome_Screen.dart';
import 'package:newchatapp/Theme/theme.dart';

class settingsScreen extends StatefulWidget {
  settingsScreen({Key? key}) : super(key: key);

  @override
  State<settingsScreen> createState() => _settingsScreenState();
}

class _settingsScreenState extends State<settingsScreen> {
  var userData = {};
  bool isLoading = false;
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

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Colors.black
              : Color.fromARGB(255, 235, 235, 235),
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Brightness.light
              : Brightness.dark,
    ));
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor == kContentColorLightTheme
              ? Colors.black
              : kContentColorDarkTheme,
      body: SafeArea(
          child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 70,
              color: Colors.transparent,
              child: Row(
                children: [
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: 100,
              color:
                  Theme.of(context).bottomNavigationBarTheme.backgroundColor ==
                          Color.fromARGB(255, 0, 0, 0)
                      ? Color.fromARGB(255, 24, 24, 24)
                      : Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.transparent,
                        image: DecorationImage(
                            image: NetworkImage(isLoading
                                ? 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhW0hzwECDKq0wfUqFADEJaNGESHQ8GRCJIg&usqp=CAU'
                                : userData['photoUrl']))),
                  ),
                  // SizedBox(
                  //   width: 8,
                  // ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 190,
                        child: Text(
                          isLoading ? 'Loading...' : userData['username'],
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width - 190,
                        child: Text(
                          isLoading ? 'Loading...' : userData['email'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  CupertinoButton(
                    onPressed: () {},
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                          child: Icon(
                        EvaIcons.edit2,
                        color: Colors.transparent,
                      )),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 30,
            ),
            setting_list_tile(
              ontap: () async {
                showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => Center(
                          child: CircularProgressIndicator(),
                        ));
                await AuthFunction().logout().then((value) {
                  Get.back();
                  Get.to(welcomeScreen(), transition: Transition.rightToLeft);
                });
              },
              title: 'LogOut',
              icon: Icon(EvaIcons.logOut),
            ),
            SizedBox(
              height: 18,
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      )),
    );
  }
}

// ignore: must_be_immutable
class setting_list_tile extends StatelessWidget {
  VoidCallback ontap;
  Icon icon;
  String title;
  setting_list_tile({
    Key? key,
    required this.icon,
    required this.ontap,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ontap,
      hoverColor: Colors.green.shade300,
      focusColor: Colors.green.shade300,
      tileColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor ==
              Color.fromARGB(255, 0, 0, 0)
          ? Color.fromARGB(255, 24, 24, 24)
          : Colors.white,
      leading: icon,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
      trailing: Icon(EvaIcons.arrowIosForward),
    );
  }
}
