// ignore_for_file: must_be_immutable, non_constant_identifier_names, prefer_typing_uninitialized_variables

import 'dart:developer';
import 'dart:io';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:dio/dio.dart';
// import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Audiocard extends StatefulWidget {
  String url;
  String Imageurl;
  String postId;
  bool read;
  final time;
  String dur;
  Audiocard(
      {Key? key,
      required this.url,
      required this.Imageurl,
      required this.read,
      required this.postId,
      required this.dur,
      required this.time})
      : super(key: key);

  @override
  State<Audiocard> createState() => _AudiocardState();
}

class _AudiocardState extends State<Audiocard> {
  final audioplayer = AudioPlayer();
  bool isplaying = false;
  bool buff = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    downloadFile(widget.url, widget.postId);
    // ignore: todo
    // TODO: implement initState

    Future.delayed(Duration(milliseconds: 12));
    audioplayer.pause();
    audioplayer.onDurationChanged.listen((NDuration) {
      setState(() {
        duration = NDuration;
      });
    });
    super.initState();
    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isplaying = state == PlayerState.playing;
      });
    });
    audioplayer.onPlayerComplete.listen((event) {
      isplaying = false;
      setState(() {});
    });

    audioplayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  @override
  void dispose() {
    audioplayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twodigets(int n) => n.toString().padLeft(2, '0');
    final hours = twodigets(duration.inHours);
    final twomin = twodigets(duration.inMinutes.remainder(60));
    final twomsec = twodigets(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, twomin, twomsec].join(':');
  }

  bool download = true;
  File? file;
  double prog = 0.0;
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
          ExternalPath.DIRECTORY_AUDIOBOOKS,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // log('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/audio/')
        //     .create(); // Create New Folder about the desire location

        // file1 =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}";
        file1 = "$appStorage/AAC-$filename.mp3";

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
            log('${(count / total)}');
            setState(() {
              prog = (count / total);
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
      await audioplayer.play(DeviceFileSource(file!.path));
      await audioplayer.pause();
    } catch (e) {
      log('audio$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(29),
                        color: kPrimaryColor.withOpacity(1),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: Stack(children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 3, left: 15, right: 8, bottom: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.green,
                                  backgroundImage:
                                      NetworkImage(widget.Imageurl),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                download
                                    ? CircularProgressIndicator(
                                        value: prog,
                                        color: Colors.white,
                                      )
                                    : InkWell(
                                        onTap: () async {
                                          if (isplaying) {
                                            await audioplayer.pause();
                                          } else {
                                            // await audioplayer
                                            //     .setSourceDeviceFile(
                                            //         file!.path);
                                            await audioplayer.play(
                                                DeviceFileSource(file!.path));
                                            buff = true;
                                            await Future.delayed(
                                                Duration(seconds: 2));
                                            buff = false;
                                          }

                                          setState(() {});
                                        },
                                        child: Icon(
                                          isplaying
                                              ? EvaIcons.pause_circle
                                              : EvaIcons.play_circle,
                                          color: Colors.white,
                                        ),
                                      ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: 8, top: 8, left: 6, right: 6),
                                  color: Colors.transparent,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: ProgressBar(
                                      barHeight: 3,
                                      thumbRadius: 5,
                                      progressBarColor: Colors.white,
                                      thumbColor: Colors.white,
                                      baseBarColor: Colors.grey,
                                      // activeColor: kPrimaryColor,
                                      // inactiveColor: Colors.grey,
                                      // min: 0,
                                      total: duration,
                                      progress: position,
                                      timeLabelTextStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      onSeek: (v) async {
                                        final position = v;
                                        await audioplayer.seek(position);
                                        await audioplayer.resume();
                                      }),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Text(
                                //   isplaying ? formatTime(position) : widget.dur,
                                //   style: TextStyle(color: Colors.white),
                                // ),
                              ],
                            )),
                        // Positioned(
                        //   bottom: 4,
                        //   right: 10,
                        //   child:
                        // )
                      ]),
                    ),
                  ],
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
                        )
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
      ),
    );
  }
}

class Audiocard1 extends StatefulWidget {
  String url;
  String Imageurl;
  String dur;
  String postId;
  final time;
  Audiocard1(
      {Key? key,
      required this.url,
      required this.postId,
      required this.Imageurl,
      required this.dur,
      required this.time})
      : super(key: key);

  @override
  State<Audiocard1> createState() => _Audiocard1State();
}

class _Audiocard1State extends State<Audiocard1> {
  final audioplayer = AudioPlayer();
  bool isplaying = false;
  bool buff = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
    downloadFile(widget.url, widget.postId);
    super.initState();
    audioplayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isplaying = state == PlayerState.playing;
      });
    });
    audioplayer.onPlayerComplete.listen((event) {
      isplaying = false;
      setState(() {});
    });
    audioplayer.onDurationChanged.listen((NDuration) {
      setState(() {
        duration = NDuration;
      });
    });
    audioplayer.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });
  }

  @override
  void dispose() {
    audioplayer.dispose();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twodigets(int n) => n.toString().padLeft(2, '0');
    final hours = twodigets(duration.inHours);
    final twomin = twodigets(duration.inMinutes.remainder(60));
    final twomsec = twodigets(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, twomin, twomsec].join(':');
  }

  bool download = true;
  File? file;
  double prog = 0.0;
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
          ExternalPath.DIRECTORY_AUDIOBOOKS,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // log('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/audio/')
        //     .create(); // Create New Folder about the desire location

        // file1 =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}";
        file1 = "$appStorage/AAC-$filename.mp3";

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
            log('${(count / total)}');
            setState(() {
              prog = (count / total);
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
      await audioplayer.play(DeviceFileSource(file!.path));
      await audioplayer.pause();
    } catch (e) {
      log('audio$e');
      // Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 30,
          ),
          child: Container(
            color: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      // height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(29),
                        color: kPrimaryColor.withOpacity(0.3),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 3, vertical: 3),
                      child: Stack(children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                top: 3, left: 15, right: 8, bottom: 5),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 17,
                                  backgroundColor: Colors.green,
                                  backgroundImage:
                                      NetworkImage(widget.Imageurl),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                download
                                    ? CircularProgressIndicator(
                                        value: prog,
                                        color: Colors.white,
                                      )
                                    : GestureDetector(
                                        onTap: () async {
                                          if (isplaying) {
                                            await audioplayer.pause();
                                          } else {
                                            // await audioplayer
                                            //     .setSourceDeviceFile(
                                            //         file!.path);
                                            await audioplayer.play(
                                                DeviceFileSource(file!.path));
                                            buff = true;
                                            await Future.delayed(
                                                Duration(seconds: 2));
                                            buff = false;
                                          }

                                          setState(() {});
                                        },
                                        child: Icon(
                                          isplaying
                                              ? EvaIcons.pause_circle
                                              : EvaIcons.play_circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                SizedBox(
                                  width: 6,
                                ),
                                Container(
                                  padding: EdgeInsets.only(
                                      bottom: 8, top: 8, left: 6, right: 6),
                                  color: Colors.transparent,
                                  width:
                                      MediaQuery.of(context).size.width / 2.5,
                                  child: ProgressBar(
                                      thumbColor: kPrimaryColor,
                                      barHeight: 3,
                                      thumbRadius: 5,
                                      // activeColor: kPrimaryColor,
                                      // inactiveColor: Colors.grey,
                                      // min: 0,
                                      timeLabelTextStyle: TextStyle(
                                        color: Theme.of(context)
                                                    .scaffoldBackgroundColor ==
                                                Colors.white
                                            ? Colors.black
                                            : Colors.white,
                                        fontSize: 14,
                                      ),
                                      total: duration,
                                      progress: position,
                                      onSeek: (v) async {
                                        final position = v;
                                        await audioplayer.seek(position);
                                        await audioplayer.resume();
                                      }),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                // Container(
                                //   color: Colors.transparent,
                                //   child: Text(
                                //     isplaying
                                //         ? formatTime(position)
                                //         : widget.dur,
                                //     style: TextStyle(
                                //         fontSize: 15, color: Colors.white),
                                //   ),
                                // ),
                              ],
                            )),
                        // Positioned(
                        //   bottom: 4,
                        //   right: 10,
                        //   child:
                        // )
                      ]),
                    ),
                  ],
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
            ),
          )),
    );
  }
}
