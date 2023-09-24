// ignore_for_file: non_constant_identifier_names, camel_case_types

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Screens/chat_screen.dart';
import 'package:newchatapp/Screens/message_screen.dart';
import 'package:newchatapp/Widgets/snackbar.dart';

class firestore extends GetxController {
  UploadTask? task;
  CreateChatRoom(String uid, name1, name2, String prof1, String prof2,
      List searchIndex1, List searchIndex, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(uid)
          .set({
        'uid': uid,
        'lastMessage': '',
        'username': name2,
        'profileImage': prof2,
        'typing': '',
        'searchIndex': searchIndex1,
        'online': false,
        'time': DateTime.now(),
        'wallpaperUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/HD_transparent_picture.png/640px-HD_transparent_picture.png'
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'username': name1,
        'lastMessage': '',
        'typing': '',
        'online': false,
        'searchIndex': searchIndex,
        'profileImage': prof1,
        'time': DateTime.now(),
        'wallpaperUrl':
            'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/HD_transparent_picture.png/640px-HD_transparent_picture.png'
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'friends': FieldValue.arrayUnion([uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'friends':
            FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid]),
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'request': FieldValue.arrayRemove([uid]),
      });
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'request':
            FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid]),
      });
      Get.back();
      Get.to(
          messageScreen(
            chatId: uid,
            uid: uid,
          ),
          transition: Transition.rightToLeft);
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
  }
}
