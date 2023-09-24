// ignore_for_file: must_be_immutable, unused_import, unused_local_variable

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newchatapp/Widgets/videoPlayer.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Theme/theme.dart';

class video extends StatefulWidget {
  String imagee;
  String videoUrl;
  String postId;
  String title;
  final time;
  bool read;
  video(
      {Key? key,
      required this.imagee,
      required this.read,
      required this.postId,
      required this.time,
      required this.videoUrl,
      required this.title})
      : super(key: key);

  @override
  State<video> createState() => _videoState();
}

class _videoState extends State<video> {
  bool isshow = false;
  bool download = true;
  double prog = 0.0;
  File? file;
  File? fileV;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.imagee, widget.videoUrl, widget.postId);
  }

  Future downloadFile(String url, String urlV, String filename) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String file1 = '';
      String file2 = '';

      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null &&
          pref.getString('Thumbnail-$filename') == null) {
        final Directory? directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory!.path}');

        final storageDirectory = await Directory(directory.path + '/image/')
            .create(); // Create New Folder about the desire location

        file1 =
            "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.jpg";
        // file1 = "$appStorage/IMG-$filename.jpg";

        log(file1);
        final response = await Dio().download(
          url,
          file1,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            // receiveTimeout: 0
          ),
          onReceiveProgress: (count, total) {
            log('$count/$total');
          },
        );
        pref.setString('Thumbnail-$filename', file1);
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.jpg";
        file2 = "$appStorage/VID-$filename.mp4";
        log(file2);
        // log(file.path);
        final respons = await Dio().download(
          urlV,
          file2,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            // receiveTimeout: 0
          ),
          onReceiveProgress: (count, total) {
            log('$count/$total');
            setState(() {
              prog = (count / total);
            });
          },
        );
        pref.setString(filename, file2);
      } else {
        file2 = pref.getString(filename)!;
        file1 = pref.getString('Thumbnail-$filename')!;
        log(pref.getString(filename)!);
      }
      setState(() {
        download = false;
        file = File(file1);
        fileV = File(file2);
      });
    } catch (e) {
      log('video$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPrimaryColor.withOpacity(1),
                ),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 3, left: 2, right: 2, bottom: 5),
                  child: Column(
                    children: [
                      Stack(alignment: Alignment.center, children: [
                        isshow
                            ? Container(
                                height: 210,
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: VideoPlayer1(file: fileV!)))
                            : download
                                ? Container(
                                    height: 210,
                                    width: 300,
                                    child: Center(
                                        child: CircularProgressIndicator(
                                      color: Colors.white,
                                      value: prog,
                                    )))
                                : Container(
                                    height: 210,
                                    width: 300,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                        isshow
                            ? Container()
                            : download
                                ? Container()
                                : GestureDetector(
                                    onTap: () {
                                      isshow = true;
                                      setState(() {});
                                    },
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: kPrimaryColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                        // Positioned(
                        //   bottom: 4,
                        //   right: 10,
                        //   child:
                        // )
                      ]),
                      widget.title.isEmpty
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3, left: 2, right: 5, bottom: 1),
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        DateFormat.jm().format(widget.time.toDate()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat.yMd().format(widget.time.toDate()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      Icon(
                        Icons.check,
                        size: 15,
                        color: widget.read ? kPrimaryColor : Colors.grey,
                      ),
                      // Text(
                      //   ',',
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                      // Text(
                      //   DateFormat.LLL().format(time.toDate()),
                      //   style: TextStyle(color: Colors.grey, fontSize: 10),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}

class video1 extends StatefulWidget {
  String imagee;
  String videoUrl;
  String title;
  final time;
  String postId;
  String url;
  video1(
      {Key? key,
      required this.imagee,
      required this.postId,
      required this.time,
      required this.videoUrl,
      required this.url,
      required this.title})
      : super(key: key);

  @override
  State<video1> createState() => _video1State();
}

class _video1State extends State<video1> {
  bool isshow = false;
  bool download = true;
  double prog = 0.0;
  File? file;
  File? fileV;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.imagee, widget.videoUrl, widget.postId);
  }

  Future downloadFile(String url, String urlV, String filename) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String file1 = '';
      String file2 = '';

      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null &&
          pref.getString('Thumbnail-$filename') == null) {
        final Directory? directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory!.path}');

        final storageDirectory = await Directory(directory.path + '/image/')
            .create(); // Create New Folder about the desire location

        file1 =
            "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.jpg";
        // file1 = "$appStorage/IMG-$filename.jpg";

        // log(file.path);
        final response = await Dio().download(
          url,
          file1,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            // receiveTimeout: 0
          ),
          onReceiveProgress: (count, total) {
            log('$count/$total');
          },
        );
        pref.setString('Thumbnail-$filename', file1);
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.jpg";
        file2 = "$appStorage/VID-$filename.mp4";

        // log(file.path);
        final respons = await Dio().download(
          urlV,
          file2,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            // receiveTimeout: 0),
          ),
          onReceiveProgress: (count, total) {
            log('$count/$total');
            setState(() {
              prog = (count / total);
            });
          },
        );
        pref.setString(filename, file2);
      } else {
        file2 = pref.getString(filename)!;
        file1 = pref.getString('Thumbnail-$filename')!;
        log(pref.getString(filename)!);
      }
      setState(() {
        download = false;
        file = File(file1);
        fileV = File(file2);
      });
    } catch (e) {
      log('video$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 300,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPrimaryColor.withOpacity(0.3),
                ),
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 3, left: 2, right: 2, bottom: 5),
                  child: Column(
                    children: [
                      Stack(alignment: Alignment.center, children: [
                        isshow
                            ? Container(
                                height: 210,
                                width: 300,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: VideoPlayer1(file: fileV!)))
                            : download
                                ? Container(
                                    height: 210,
                                    width: 300,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        value: prog,
                                      ),
                                    ),
                                  )
                                : Container(
                                    height: 210,
                                    width: 300,
                                    color: Colors.transparent,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.file(
                                        file!,
                                        fit: BoxFit.cover,
                                      ),
                                    )),
                        isshow
                            ? Container()
                            : download
                                ? Container()
                                : GestureDetector(
                                    onTap: () {
                                      isshow = true;
                                      setState(() {});
                                    },
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundColor: kPrimaryColor,
                                      child: Center(
                                        child: Icon(
                                          Icons.play_arrow,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                        // Positioned(
                        //   bottom: 4,
                        //   right: 10,
                        //   child:
                        // )
                      ]),
                      widget.title.isEmpty
                          ? Container()
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 3, left: 5, right: 2, bottom: 1),
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            )
                    ],
                  ),
                ),
              ),
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.green,
                backgroundImage: NetworkImage(widget.url),
              ),
              SizedBox(
                height: 6,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat.jm().format(widget.time.toDate()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        DateFormat.yMd().format(widget.time.toDate()),
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                      // Text(
                      //   ',',
                      //   style: TextStyle(color: Colors.grey),
                      // ),
                      // Text(
                      //   DateFormat.LLL().format(time.toDate()),
                      //   style: TextStyle(color: Colors.grey, fontSize: 10),
                      // ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );
  }
}
