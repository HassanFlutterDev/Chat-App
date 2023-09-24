// ignore_for_file: dead_code

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';

import '../../Widgets/snackbar.dart';

class chatManagement extends GetxController {
  SendMessage(
    String ChatId,
    String Message,
    String uid,
    String name,
    BuildContext context,
  ) async {
    try {
      if (Message.isNotEmpty) {
        String postId = Uuid().v1();
        var time = DateTime.now();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Chatrooms')
            .doc(ChatId)
            .collection('messages')
            .doc(postId)
            .set({
          'message': Message,
          'chatId': ChatId,
          'uid': uid,
          'name': name,
          'read': false,
          'type': 'text',
          'time': DateTime.now(),
          'postId': postId,
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ChatId)
            .collection('Chatrooms')
            .doc(uid)
            .collection('messages')
            .doc(postId)
            .set({
          'message': Message,
          'chatId': ChatId,
          'uid': uid,
          'read': false,
          'name': name,
          'type': 'text',
          'time': DateTime.now(),
          'postId': postId,
        });
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Chatrooms')
            .doc(ChatId)
            .update({'lastMessage': 'text'});
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ChatId)
            .collection('Chatrooms')
            .doc(uid)
            .update({'lastMessage': 'text'});
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('Chatrooms')
            .doc(ChatId)
            .update({'time': DateTime.now()});
        await FirebaseFirestore.instance
            .collection('users')
            .doc(ChatId)
            .collection('Chatrooms')
            .doc(uid)
            .update({'time': DateTime.now()});
      }
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
  }

  sendVideoStatus(
    String name,
    String image,
    String path,
    String caption,
  ) async {
    String id = Uuid().v1();
    String ImageUrl = await sendImage(File(path), id);
    await FirebaseFirestore.instance
        .collection('status')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'image': image,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'name': name,
      'read': [],
      'createdAt': DateTime.now(),
    });
    await FirebaseFirestore.instance
        .collection('status')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('uploads')
        .doc(id)
        .set({
      'video': ImageUrl,
      'id': id,
      'type': 'video',
      'read': [],
      'createdAt': DateTime.now(),
      'caption': caption,
    });
  }

  sendImageStatus(
    String name,
    String image,
    String path,
    String caption,
  ) async {
    String id = Uuid().v1();
    String ImageUrl = await sendImage(File(path), id);
    await FirebaseFirestore.instance
        .collection('status')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'image': image,
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'name': name,
      'read': [],
      'createdAt': DateTime.now(),
    });
    await FirebaseFirestore.instance
        .collection('status')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('uploads')
        .doc(id)
        .set({
      'image': ImageUrl,
      'type': 'image',
      'id': id,
      'read': [],
      'createdAt': DateTime.now(),
      'caption': caption,
    });
  }

  SendVoice(
    String ChatId,
    File voice,
    String uid,
    String name,
    String time,
    BuildContext context,
  ) async {
    try {
      String postId = Uuid().v1();
      String voiceUrl = await SendVoice1(voice, postId);
      // Int date = DateTime.now() as Int;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'voiceUrl': voiceUrl,
        'chatId': ChatId,
        'uid': uid,
        'read': false,
        'name': name,
        'duration': time,
        'type': 'voice',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'voiceUrl': voiceUrl,
        'chatId': ChatId,
        'uid': uid,
        'read': false,
        'name': name,
        'duration': time,
        'type': 'voice',
        'time': DateTime.now(),
        'postId': postId,
      });
      Fluttertoast.showToast(
          msg: 'Voice Sucessfully Sended!!', backgroundColor: kPrimaryColor);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'voice'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'lastMessage': 'voice'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'time': DateTime.now()});
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
  }

  UploadTask? task;
  Future<String> SendVoice1(File AudioPath, String postId) async {
    String? downloadurl;
    try {
      // var postId = Uuid().v1();

      Reference ref =
          FirebaseStorage.instance.ref().child('Svoice').child(postId);

      task = ref.putFile(
          AudioPath,
          SettableMetadata(
            contentType: 'audio/aac',
          ));

      TaskSnapshot snap = await task!;
      downloadurl = await snap.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('error 2 ', e.toString());
    }
    return downloadurl!;
  }

  Future<String> SendApk(File Apk, String postId) async {
    String? downloadurl;
    try {
      // var postId = Uuid().v1();

      Reference ref =
          FirebaseStorage.instance.ref().child('Sapk').child('$postId');

      task = ref.putFile(
          Apk,
          SettableMetadata(
            contentType: 'application/vnd.android.package-archive',
          ));

      TaskSnapshot snap = await task!;
      downloadurl = await snap.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('error 2 ', e.toString());
    }
    return downloadurl!;
  }

  Future<String> SendZip(File zip, String postId) async {
    String? downloadurl;
    try {
      // var postId = Uuid().v1();

      Reference ref =
          FirebaseStorage.instance.ref().child('Sapk').child('$postId.zip');

      task = ref.putFile(
          zip,
          SettableMetadata(
            contentType: 'application/x-zip-compressed',
          ));

      TaskSnapshot snap = await task!;
      downloadurl = await snap.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('error 2 ', e.toString());
    }
    return downloadurl!;
  }

  Future<String> SendPdf(Uint8List pdf, String postId) async {
    String? downloadurl;
    try {
      // var postId = Uuid().v1();
      var pdfFile = FirebaseStorage.instance.ref().child('Sfile').child(postId);
      task = pdfFile.putData(pdf);
      TaskSnapshot snapshot = await task!;
      downloadurl = await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('error 2 ', e.toString());
    }
    return downloadurl!;
  }

  SendFile1(
    String ChatId,
    Uint8List File,
    String fileName,
    String uid,
    String size,
    String name,
    String ext,
    BuildContext context,
  ) async {
    bool send = false;
    try {
      String postId = Uuid().v1();
      String FileUrl = await SendPdf(File, postId);
      // Int date = DateTime.now() as Int;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'filename': fileName,
        'read': false,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'read': false,
        'filename': fileName,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
    return 'ok';
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Chatrooms')
        .doc(ChatId)
        .update({'time': DateTime.now(), 'lastMessage': 'file'});
    await FirebaseFirestore.instance
        .collection('users')
        .doc(ChatId)
        .collection('Chatrooms')
        .doc(uid)
        .update({'time': DateTime.now(), 'lastMessage': 'file'});
    send = false;
  }

  SendApkFile(
    String ChatId,
    File File,
    String fileName,
    String uid,
    String size,
    String name,
    String ext,
    BuildContext context,
  ) async {
    try {
      String postId = Uuid().v1();
      String FileUrl = await SendApk(File, name);
      // Int date = DateTime.now() as Int;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'filename': fileName,
        'read': false,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'read': false,
        'filename': fileName,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'file'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'lastMessage': 'file'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'time': DateTime.now()});
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
  }

  SendZipFile(
    String ChatId,
    File File,
    String fileName,
    String uid,
    String size,
    String name,
    String ext,
    BuildContext context,
  ) async {
    try {
      String postId = Uuid().v1();
      String FileUrl = await SendZip(File, postId);
      // Int date = DateTime.now() as Int;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'filename': fileName,
        'read': false,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'FileUrl': FileUrl,
        'chatId': ChatId,
        'ext': ext,
        'size': size,
        'uid': uid,
        'read': false,
        'filename': fileName,
        'name': name,
        'type': 'file',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'file'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'lastMessage': 'file'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'time': DateTime.now()});
    } catch (e) {
      Showsnackbar(context, e.toString());
    }
  }

  SendImage(
    String ChatId,
    File image,
    String title,
  ) async {
    try {
      String postId = Uuid().v1();
      String ImageUrl = await sendImage(image, postId);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'imageUrl': ImageUrl,
        'chatId': ChatId,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'title': title,
        'read': false,
        'type': 'image',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('messages')
          .doc(postId)
          .set({
        'imageUrl': ImageUrl,
        'chatId': ChatId,
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'title': title,
        'read': false,
        'type': 'image',
        'time': DateTime.now(),
        'postId': postId,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'text'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'lastMessage': 'text'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'time': DateTime.now()});
      Get.back();
    } catch (e) {
      Get.snackbar('error', e.toString());
    }
  }

  Future sendImage(File image, String postId) async {
    // folder name & iamge name
    // String postId = const Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child('sendImage').child('$postId.jpg');
    // image is uploading from putData()

    task = ref.putFile(image);

    TaskSnapshot taskSnapshot = await task!;
    final snapshot = task!.whenComplete(() {});
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    return downloadUrl;
  }

  SendVideo(
    String ChatId,
    File videoUrl,
    String uid,
    String title,
  ) async {
    try {
      String postId = Uuid().v1();
      String videopath = await SendVideoS(videoUrl, postId);
      String Thumbnail = await SuploadImageVideo(videoUrl);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .collection('messages')
          .doc(postId)
          .set({
        'videoUrl': videopath,
        'thumbnail': Thumbnail,
        'chatId': ChatId,
        'uid': uid,
        'read': false,
        'title': title,
        'type': 'video',
        'time': DateTime.now(),
        'postId': postId
      });
      Get.back();
      Get.back();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .collection('messages')
          .doc(postId)
          .set({
        'videoUrl': videopath,
        'thumbnail': Thumbnail,
        'chatId': ChatId,
        'uid': uid,
        'title': title,
        'read': false,
        'type': 'video',
        'time': DateTime.now(),
        'postId': postId
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'lastMessage': 'Video'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'lastMessage': 'Video'});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('Chatrooms')
          .doc(ChatId)
          .update({'time': DateTime.now()});
      await FirebaseFirestore.instance
          .collection('users')
          .doc(ChatId)
          .collection('Chatrooms')
          .doc(uid)
          .update({'time': DateTime.now()});
      // Get.back();
    } catch (e) {
      Get.snackbar('error', e.toString());
    }
  }

  SgetThumbnails(File videopath) async {
    final thumbnail = await VideoCompress.getFileThumbnail(videopath.path);
    return thumbnail;
  }

  Future<String> SuploadImageVideo(File VideoPath) async {
    var postId = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child('SThumbnails').child(postId);
    UploadTask uploadTask = ref.putFile(await SgetThumbnails(VideoPath));
    TaskSnapshot snap = await uploadTask;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }

  Future<String> SendVideoS(File VideoPath, String postId) async {
    // var postId = Uuid().v1();
    Reference ref =
        FirebaseStorage.instance.ref().child('Svideos').child(postId);
    task = ref.putFile(await VideoPath);
    TaskSnapshot snap = await task!;
    String downloadurl = await snap.ref.getDownloadURL();
    return downloadurl;
  }

  buildSendFileStatus() => StreamBuilder<TaskSnapshot>(
        stream: task!.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    width: MediaQuery.of(context).size.width - 70,
                    child: LinearProgressIndicator(
                      color: Colors.green,
                      value: progress,
                    ),
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            );
          } else {
            return Container(
                color: Colors.transparent,
                height: 10,
                child: LinearProgressIndicator());
          }
        },
      );
}
