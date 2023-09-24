// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, dead_code

import 'dart:developer';
import 'dart:io';

import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
// import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Widgets/snackbar.dart';
import 'package:path/path.dart';
import 'package:newchatapp/Screens/full_photo.dart';
import 'package:intl/intl.dart';
import 'package:newchatapp/Screens/profile_sections/audio_player.dart';
import 'package:newchatapp/Screens/profile_sections/pdf_view.dart';
import 'package:newchatapp/Screens/profile_sections/video_player.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:open_file/open_file.dart';
// import 'package:path_provider/path_provider.dart';
import '../../Theme/theme.dart';
import 'package:external_path/external_path.dart';

class profile_media_screen extends StatefulWidget {
  String uid;
  profile_media_screen({super.key, required this.uid});

  @override
  State<profile_media_screen> createState() => _profile_media_screenState();
}

class _profile_media_screenState extends State<profile_media_screen>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    controller = TabController(length: 5, vsync: this);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 27,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: GestureDetector(
          onTap: () {},
          child: Text(
            'Storage',
            style: TextStyle(
                color: Colors.white, fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
        bottom: TabBar(
            automaticIndicatorColorAdjustment: false,
            controller: controller,
            indicatorColor: Theme.of(context).primaryColor == kPrimaryColor
                ? kPrimaryColor
                : Colors.white,
            tabs: [
              Tab(
                text: 'Photos',
              ),
              Tab(
                text: 'Videos',
              ),
              Tab(
                text: 'Audios',
              ),
              Tab(
                text: 'Links',
              ),
              Tab(
                text: 'Documents',
              )
            ]),
      ),
      body: TabBarView(controller: controller, children: [
        WidgetpROFILE(uid: widget.uid),
        wProfilev(uid: widget.uid),
        wProfileA(uid: widget.uid),
        Text('Document'),
        wProfileD(uid: widget.uid),
      ]),
    );
  }
}

class WidgetpROFILE extends StatefulWidget {
  final String uid;
  WidgetpROFILE({Key? key, required this.uid}) : super(key: key);

  @override
  State<WidgetpROFILE> createState() => _WidgetpROFILEState();
}

class _WidgetpROFILEState extends State<WidgetpROFILE> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.uid)
          .collection('messages')
          .orderBy(
            'time',
            descending: true,
          )
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  dragStartBehavior: DragStartBehavior.start,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    if (snap['type'] == 'image') {
                      return imageStorage(snap: snap);
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}

class imageStorage extends StatefulWidget {
  const imageStorage({
    Key? key,
    required this.snap,
  }) : super(key: key);

  final DocumentSnapshot<Object?> snap;

  @override
  State<imageStorage> createState() => _imageStorageState();
}

class _imageStorageState extends State<imageStorage> {
  bool download = true;
  File? file;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.snap['imageUrl'], widget.snap['postId']);
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
      if (pref.getString(filename) != null) {
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DCIM,
        );
        final Directory? directory = await getExternalStorageDirectory();
        print('Directory Path: ${directory!.path}');

        final storageDirectory = await Directory(directory.path + '/image/')
            .create(); // Create New Folder about the desire location

        file1 =
            "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.jpg";
        final String mediaFileLocalPath = "$appStorage/IMG-$filename.jpg";

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
            log('$count/$total');
          },
        );
        final respons = await Dio().download(
          url,
          mediaFileLocalPath,
          // queryParameters: appStorage,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ),
          onReceiveProgress: (count, total) {
            log('$count/$total');
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
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 30,
          decoration: BoxDecoration(
            color:
                Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.1),
          ),
          child: Center(
              child: Text(
                  '${DateFormat.yMd().format(widget.snap['time'].toDate())},${DateFormat.jm().format(widget.snap['time'].toDate())}')),
        ),
        download
            ? Container(
                height: 230,
                width: 300,
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(child: CircularProgressIndicator()),
              )
            : OpenContainer(
                closedColor: Colors.transparent,
                middleColor: Colors.transparent,
                openColor: Colors.transparent,
                closedShape: RoundedRectangleBorder(),
                openShape: RoundedRectangleBorder(),
                closedElevation: 15.0,
                transitionDuration: Duration(
                  milliseconds: 500,
                ),
                transitionType: ContainerTransitionType.fadeThrough,
                openBuilder: (_, __) {
                  return full_screen(url: file!.path);
                },
                closedBuilder: (_, __) {
                  return InkWell(
                      onTap: __,
                      child: Container(
                        height: 230,
                        width: 300,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            file!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ));
                }),
      ],
    );
  }
}

class wProfilev extends StatefulWidget {
  final String uid;
  wProfilev({Key? key, required this.uid}) : super(key: key);

  @override
  State<wProfilev> createState() => _wProfilevState();
}

class _wProfilevState extends State<wProfilev> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.uid)
          .collection('messages')
          .orderBy(
            'time',
            descending: true,
          )
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  dragStartBehavior: DragStartBehavior.start,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    if (snap['type'] == 'video') {
                      return Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.1),
                            ),
                            child: Center(
                                child: Text(
                                    '${DateFormat.yMd().format(snap['time'].toDate())},${DateFormat.jm().format(snap['time'].toDate())}')),
                          ),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Center(
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
                                    transitionType:
                                        ContainerTransitionType.fadeThrough,
                                    openBuilder: (_, __) {
                                      return VideoSend(snap: snap['videoUrl']);
                                    },
                                    closedBuilder: (_, __) {
                                      return InkWell(
                                          onTap: __,
                                          child: Container(
                                            height: 230,
                                            width: 300,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              child: CachedNetworkImage(
                                                imageUrl: snap['thumbnail'],
                                                placeholder: (context, url) =>
                                                    Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                  color: Colors.green,
                                                )),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ));
                                    }),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: Center(
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Colors.green,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}

class wProfileA extends StatefulWidget {
  final String uid;
  wProfileA({Key? key, required this.uid}) : super(key: key);

  @override
  State<wProfileA> createState() => _wProfileAState();
}

class _wProfileAState extends State<wProfileA> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.uid)
          .collection('messages')
          .orderBy(
            'time',
            descending: true,
          )
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  dragStartBehavior: DragStartBehavior.start,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    if (snap['type'] == 'voice') {
                      return Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.1),
                            ),
                            child: Center(
                                child: Text(
                                    '${DateFormat.yMd().format(snap['time'].toDate())},${DateFormat.jm().format(snap['time'].toDate())}')),
                          ),
                          Container(
                            height: 70,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.blue,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4,
                                              left: 4,
                                              right: 4,
                                              bottom: 4),
                                          child: Icon(
                                            CupertinoIcons.headphones,
                                            size: 55,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        height: 60,
                                        width: 160,
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Audio $index',
                                                  style: TextStyle(
                                                    fontSize: 21,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  'Duration:${snap['duration']}',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Get.to(
                                        audio_player_media(
                                          url: snap['voiceUrl'],
                                          dur: snap['duration'],
                                        ),
                                        transition: Transition.cupertino);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 7, right: 4, bottom: 4),
                                      child: Icon(
                                        CupertinoIcons.play_arrow_solid,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}

class wProfileD extends StatefulWidget {
  final String uid;
  wProfileD({Key? key, required this.uid}) : super(key: key);

  @override
  State<wProfileD> createState() => _wProfileDState();
}

class _wProfileDState extends State<wProfileD> {
  Future openfile({
    required String url,
    required BuildContext context,
    String? filename,
  }) async {
    try {
      // var response = await http.get(Uri.parse(url));
      // Directory documentDirectory = await getApplicationDocumentsDirectory();
      // File file = new File(join(documentDirectory.path, 'imagetest.pdf'));
      // file.writeAsBytesSync(response.bodyBytes);
      SharedPreferences pref = await SharedPreferences.getInstance();
      // String path = await downloadFile(url, filename!);
      // pref.setString('imageApk', path);
      // log(path.toString());
      // if (path == null) return;
      // print('Path: ${path}');
      String Spath = pref.getString('imageApk')!;
      OpenFile.open(Spath).onError((error, stackTrace) {
        return Showsnackbar(context, error.toString());
      });
    } on PlatformException catch (e) {
      log(e.toString());
    } catch (e) {
      log(e.toString());
    }
  }

  Future downloadFile(String url, String filename) async {
    try {
      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
      // final Directory? directory = await getExternalStorageDirectory();
      // print('Directory Path: ${directory!.path}');

      // final storageDirectory = await Directory(directory.path + '/image/')
      //     .create(); // Create New Folder about the desire location

      // final String mediaFileLocalPath =
      //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.apk";
      final file = File(join(appStorage, "$filename.jpg"));
      // log(file.path);
      final response = await Dio().download(
        url,
        file.path,
        // queryParameters: appStorage,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: false,
        ),
        onReceiveProgress: (count, total) {
          log('$count/$total');
        },
      );
      // }
      // final raf = file.openSync(mode: FileMode.write);/
      // file.writeAsBytes(response.data);
      // await raf.close();
      return file.path;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  bool download = false;
  File? file;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('Chatrooms')
          .doc(widget.uid)
          .collection('messages')
          .orderBy(
            'time',
            descending: true,
          )
          .snapshots(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
        }
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  shrinkWrap: true,
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  dragStartBehavior: DragStartBehavior.start,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemBuilder: (context, index) {
                    DocumentSnapshot snap =
                        (snapshot.data! as dynamic).docs[index];
                    if (snap['type'] == 'file') {
                      return Column(
                        children: [
                          Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .color!
                                  .withOpacity(0.1),
                            ),
                            child: Center(
                                child: Text(
                                    '${DateFormat.yMd().format(snap['time'].toDate())},${DateFormat.jm().format(snap['time'].toDate())}')),
                          ),
                          Container(
                            height: 70,
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      download == true
                                          ? Container(
                                              height: 60,
                                              width: 100,
                                              child: Image.file(
                                                file!,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  stackTrace.printError(
                                                      info: error.toString());
                                                  // Showsnackbar(
                                                  //   context,
                                                  //   error.toString(),
                                                  // );
                                                  return Icon(Icons.error);
                                                },
                                              ),
                                            )
                                          : Container(
                                              decoration: BoxDecoration(
                                                color: snap['ext'] == 'Pdf'
                                                    ? Colors.red
                                                    : Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 4,
                                                    left: 4,
                                                    right: 4,
                                                    bottom: 4),
                                                child: Icon(
                                                  snap['ext'] == 'Pdf'
                                                      ? Icons.picture_as_pdf
                                                      : snap['ext'] == 'Zip'
                                                          ? Icons
                                                              .folder_zip_rounded
                                                          : Icons.android,
                                                  size: 55,
                                                  color: snap['ext'] == 'Pdf'
                                                      ? Colors.white
                                                      : snap['ext'] == 'Zip'
                                                          ? Colors.grey
                                                          : Colors.green,
                                                ),
                                              ),
                                            ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Container(
                                        height: 60,
                                        width: 170,
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  snap['filename']
                                                              .toString()
                                                              .length <=
                                                          16
                                                      ? snap['filename']
                                                          .toString()
                                                      : snap['filename']
                                                          .toString()
                                                          .replaceRange(
                                                              16,
                                                              snap['filename']
                                                                  .toString()
                                                                  .length,
                                                              '...'),
                                                  style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await Permission.storage.request();
                                    // openfile(
                                    //   context: context,
                                    //   url: snap['FileUrl'],
                                    //   filename: 'file.apk',
                                    // );
                                    SharedPreferences pref =
                                        await SharedPreferences.getInstance();
                                    // String path = await downloadFile(
                                    //     'https://th.bing.com/th/id/OIP.ewQ01WGeLzMa22dxsZly7gHaFX?pid=ImgDet&rs=1',
                                    //     'image');
                                    // pref.setString('image', path);
                                    String path = pref.getString('image')!;
                                    setState(() {
                                      download = true;
                                      file = File(path);
                                    });
                                    // Get.to(pdf_viewer(name: snap['filename'], url: snap['FileUrl']));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kPrimaryColor,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 4, left: 7, right: 4, bottom: 4),
                                      child: Icon(
                                        snap['ext'] == 'Pdf'
                                            ? CupertinoIcons.eye
                                            : Icons.download,
                                        size: 25,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }),
            ],
          ),
        );
      },
    );
  }
}
