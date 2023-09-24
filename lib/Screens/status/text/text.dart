// ignore_for_file: prefer_const_constructors, sort_child_properties_last, use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:uuid/uuid.dart';

class TextStatusScreen extends StatefulWidget {
  const TextStatusScreen({super.key});

  @override
  State<TextStatusScreen> createState() => _TextStatusScreenState();
}

class _TextStatusScreenState extends State<TextStatusScreen> {
  List<Color> color = [
    Colors.red,
    Colors.purple,
    Colors.green,
    Colors.yellow,
    Colors.orange,
  ];
  int index = 0;
  TextEditingController message = TextEditingController();
  var userData = {};
  bool load = false;
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
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: color[index],
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (message.text.isNotEmpty) {
            setState(() {
              load = true;
            });
            String id = Uuid().v1();
            await FirebaseFirestore.instance
                .collection('status')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .set({
              'image': userData['photoUrl'],
              'uid': FirebaseAuth.instance.currentUser!.uid,
              'name': userData['username'],
              'read': [],
              'createdAt': DateTime.now(),
            });
            await FirebaseFirestore.instance
                .collection('status')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('uploads')
                .doc(id)
                .set({
              'text': message.text,
              'id': id,
              'color': index == 0
                  ? 'red'
                  : index == 1
                      ? 'purple'
                      : index == 2
                          ? 'green'
                          : index == 3
                              ? 'yellow'
                              : 'orange',
              'type': 'text',
              'read': [],
              'createdAt': DateTime.now(),
            });
            setState(() {
              load = false;
            });
            Navigator.pop(context);
          }
        },
        child: load
            ? CircularProgressIndicator.adaptive()
            : Icon(
                EvaIcons.checkmark,
                color: Colors.white,
              ),
        backgroundColor: kPrimaryColor,
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              child: GestureDetector(
                  onTap: () {
                    if (index == 4) {
                      setState(() {
                        index = 0;
                      });
                    } else {
                      setState(() {
                        index++;
                      });
                    }
                  },
                  child: Icon(
                    Icons.color_lens,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
            cursorHeight: 50,
            cursorColor: Colors.white,
            minLines: 1,
            maxLines: 20,
            autofocus: true,
            controller: message,
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
