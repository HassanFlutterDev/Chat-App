import 'dart:developer';
import 'dart:io';
import 'package:animations/animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:newchatapp/Screens/full_photo.dart';
import 'package:path/path.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class image extends StatefulWidget {
  String imagee;
  String postId;
  final time;
  String url;
  image(
      {Key? key,
      required this.imagee,
      required this.time,
      required this.url,
      required this.postId})
      : super(key: key);

  @override
  State<image> createState() => _imageState();
}

class _imageState extends State<image> {
  bool download = true;
  File? file;
  double prog = 0.0;
  int percentage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.imagee, widget.postId);
  }

  Future downloadFile(String url, String filename) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String? file1;

      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null) {
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_PICTURES,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.apk";
        file1 = "$appStorage/Connect Me/IMG-$filename.jpg";

        // log(file.path);
        final response = await Dio().download(
          url,
          file1,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
          onReceiveProgress: (count, total) {
            setState(() {
              prog = (count / total);
              percentage = ((count / total) * 100).floor();
            });
          },
        );
        pref.setString(filename, file1);
      } else {
        file1 = pref.getString(filename);
      }
      setState(() {
        download = false;
        file = File(file1!);
      });
    } catch (e) {
      // Fluttertoast.showToast(msg: e.toString());
      log('Image$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 45,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: kPrimaryColor.withOpacity(0.3),
                ),
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 3, left: 2, right: 2, bottom: 5),
                    child: OpenContainer(
                        closedColor: Colors.transparent,
                        middleColor: Colors.transparent,
                        openColor: Colors.transparent,
                        closedShape: RoundedRectangleBorder(),
                        openShape: RoundedRectangleBorder(),
                        closedElevation: 15.0,
                        transitionDuration: Duration(
                          milliseconds: 500,
                        ),
                        // transitionType: ContainerTransitionType.fadeThrough,
                        openBuilder: (_, __) {
                          return full_screen(url: file!.path);
                        },
                        closedBuilder: (_, __) {
                          return GestureDetector(
                            onTap: __,
                            child: Container(
                              height: 210,
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: download
                                    ? Colors.black
                                    : Colors.transparent,
                              ),
                              child: download
                                  ? Center(
                                      child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Text(
                                          '$percentage%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                          ),
                                        ),
                                        Container(
                                          height: 50,
                                          width: 50,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5,
                                            color: Colors.white,
                                            value: prog,
                                          ),
                                        ),
                                      ],
                                    ))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.file(
                                        file!,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                          );
                        }),
                  ),
                  // Positioned(
                  //   bottom: 4,
                  //   right: 10,
                  //   child:
                  // )
                ]),
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
                alignment: Alignment.centerRight,
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

class image1 extends StatefulWidget {
  String imagee;
  final time;
  String title;
  String postId;
  bool read;
  image1(
      {Key? key,
      required this.read,
      required this.postId,
      required this.imagee,
      required this.time,
      required this.title})
      : super(key: key);

  @override
  State<image1> createState() => _image1State();
}

class _image1State extends State<image1> {
  bool download = true;
  File? file;
  double prog = 0.0;
  int percentage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.imagee, widget.postId);
  }

  Future downloadFile(String url, String filename) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String file1 = '';
      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null) {
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.apk";
        file1 = "$appStorage/IMG-$filename.jpg";

        // log(file.path);
        final response = await Dio().download(
          url,
          file1,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
          onReceiveProgress: (count, total) {
            // log('$count/$total');
            setState(() {
              prog = (count / total);
              percentage = ((count / total) * 100).floor();
            });
          },
        );
        pref.setString(filename, file1);
      } else {
        file1 = pref.getString(filename)!;
        log(pref.getString(filename)!);
      }
      setState(() {
        download = false;
        file = File(file1);
      });
    } catch (e) {
      log('Image$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 285,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                // width:MediaQuery.of(context).size.width - 45 ,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: kPrimaryColor.withOpacity(1),
                ),
                margin: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: Column(
                  children: [
                    Stack(alignment: Alignment.center, children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 3, left: 2, right: 2, bottom: 3),
                        child: OpenContainer(
                          closedColor: Colors.transparent,
                          middleColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedShape: RoundedRectangleBorder(),
                          openShape: RoundedRectangleBorder(),
                          closedElevation: 15.0,
                          transitionDuration: Duration(
                            milliseconds: 500,
                          ),
                          // transitionType: ContainerTransitionType.fade,
                          openBuilder: (_, __) {
                            return full_screen(url: file!.path);
                          },
                          closedBuilder: (_, __) {
                            return GestureDetector(
                              onTap: __,
                              child: Container(
                                height: 210,
                                width: 277,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: download
                                      ? Colors.black
                                      : Colors.transparent,
                                ),
                                child: download
                                    ? Center(
                                        child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            '$percentage%',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                          Container(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 5,
                                              color: Colors.white,
                                              value: prog,
                                            ),
                                          ),
                                        ],
                                      ))
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.file(
                                          file!,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                      // Positioned(
                      //   bottom: 4,
                      //   right: 10,
                      //   child:
                      // )
                    ]),
                    widget.title.isEmpty
                        ? Container()
                        : Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              // crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 1, left: 2, right: 8, bottom: 6),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        widget.title,
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                  ],
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
