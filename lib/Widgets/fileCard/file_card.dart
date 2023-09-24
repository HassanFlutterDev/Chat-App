import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:newchatapp/Screens/profile_sections/pdf_view.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:intl/intl.dart';

class fileCard extends StatefulWidget {
  String name;
  String size;
  String type;
  String url;
  String postId;
  bool read;
  final time;
  fileCard(
      {Key? key,
      required this.name,
      required this.url,
      required this.postId,
      required this.size,
      required this.type,
      required this.read,
      required this.time})
      : super(key: key);

  @override
  State<fileCard> createState() => _fileCardState();
}

class _fileCardState extends State<fileCard> {
  bool download = true;
  File? file;
  double prog = 0.0;
  int percentage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.url, widget.postId, widget.name);
  }

  Future downloadFile(
    String url,
    String filename,
    String name,
  ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String file1 = '';

      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null) {
        await Permission.mediaLibrary.request();
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.apk";
        file1 = "$appStorage/Connect Me/$name";

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
            log((count / total).toString());
            setState(() {
              prog = (count / total);
              percentage = ((count / total) * 100).floor();
            });
          },
        );
        pref.setString(filename, file1);
      } else {
        file1 = pref.getString(filename)!;
        // log(pref.getString(filename)!);
      }
      setState(() {
        download = false;
        file = File(file1);
      });
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {
            if (widget.type == 'Pdf') {
              Get.to(pdf_viewer(name: widget.name, url: file!),
                  transition: Transition.rightToLeft);
            } else {
              log(file!.path);
              OpenFile.open(file!.path);
            }
          },
          child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 45,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: widget.type == 'Pdf'
                        ? download
                            ? 70
                            : 220
                        : 70,
                    width: MediaQuery.of(context).size.width / 1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: kPrimaryColor.withOpacity(1),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 11, vertical: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        widget.type == 'Pdf'
                            ? download
                                ? Container()
                                : Container(
                                    height: 150,
                                    decoration: BoxDecoration(
                                        color: Color.fromARGB(47, 0, 0, 0),
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10))),
                                    child: Center(
                                        child: Container(
                                            height: 130,
                                            width: 270,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: Colors.transparent,
                                            ),
                                            child: SfPdfViewer.file(file!))),
                                  )
                            : Container(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // SizedBox(
                            //   width: 8,
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: CircleAvatar(
                                radius: 24,
                                backgroundColor: Colors.white,
                                child: FaIcon(
                                  widget.type == 'Pdf'
                                      ? FontAwesomeIcons.filePdf
                                      : widget.type == 'Zip'
                                          ? FontAwesomeIcons.fileZipper
                                          : FontAwesomeIcons.android,
                                  color: widget.type == 'Pdf'
                                      ? Colors.red
                                      : widget.type == 'Zip'
                                          ? Colors.grey
                                          : Colors.green,
                                  size: 35,
                                ),
                              ),
                            ),
                            // SizedBox(
                            //   width: 5,
                            // ),
                            Text(
                              widget.name.length <= 21
                                  ? widget.name
                                  : widget.name.replaceRange(
                                      18, widget.name.length, '...'),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 70,
                                width: 64,
                                color: Colors.transparent,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    download
                                        ? Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Text(
                                                '$percentage%',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                ),
                                              ),
                                              CircularProgressIndicator(
                                                color: Colors.white,
                                                value: prog,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 6,
                                    ),
                                    Align(
                                        alignment: Alignment.bottomCenter,
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Text(
                                            widget.size,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                            ),
                                          ),
                                        )),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
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
                          Icon(
                            Icons.check,
                            size: 15,
                            color: widget.read ? kPrimaryColor : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}

class fileCard1 extends StatefulWidget {
  String name;
  String size;
  String type;
  String postId;
  String pic;
  String url;
  bool read;
  final time;
  fileCard1(
      {Key? key,
      required this.name,
      required this.url,
      required this.size,
      required this.postId,
      required this.type,
      required this.pic,
      required this.read,
      required this.time})
      : super(key: key);

  @override
  State<fileCard1> createState() => _fileCard1State();
}

class _fileCard1State extends State<fileCard1> {
  bool download = true;
  File? file;
  double prog = 0.0;
  int percentage = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    downloadFile(widget.url, widget.postId, widget.name);
  }

  Future downloadFile(
    String url,
    String filename,
    String name,
  ) async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      String file1 = '';
      // if (!await Permission.storage.request().isGranted) {
      // await Permission.storage.request();
      // } else {
      // String fileS = pref.getString(filename)!;
      // log(fileS);
      if (pref.getString(filename) == null) {
        Permission.manageExternalStorage.request();
        final appStorage = await ExternalPath.getExternalStoragePublicDirectory(
          ExternalPath.DIRECTORY_DOWNLOADS,
        );
        // final Directory? directory = await getExternalStorageDirectory();
        // print('Directory Path: ${directory!.path}');

        // final storageDirectory = await Directory(directory.path + '/image/')
        //     .create(); // Create New Folder about the desire location

        // final String mediaFileLocalPath =
        //     "${storageDirectory.path}${DateTime.now().toString().split(" ").join("")}.apk";
        file1 = "$appStorage/Connect Me/$name";

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
      // Fluttertoast.showToast(msg: e.toString());
      log(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          if (widget.type == 'Pdf') {
            Get.to(pdf_viewer(name: widget.name, url: file!),
                transition: Transition.rightToLeft);
          } else {
            OpenFile.open(file!.path);
          }
        },
        child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width - 23,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: widget.type == 'Pdf'
                          ? download
                              ? 70
                              : 220
                          : 70,
                      width: MediaQuery.of(context).size.width / 1.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: kPrimaryColor.withOpacity(0.3),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      child: Column(
                        children: [
                          widget.type == 'Pdf'
                              ? download
                                  ? Container()
                                  : Container(
                                      height: 150,
                                      decoration: BoxDecoration(
                                          color: Color.fromARGB(47, 0, 0, 0),
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10))),
                                      child: Center(
                                          child: Container(
                                              height: 130,
                                              width: 270,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Colors.transparent,
                                              ),
                                              child: SfPdfViewer.file(file!))),
                                    )
                              : Container(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SizedBox(
                              //   width: 8,
                              // ),

                              // SizedBox(
                              //   width: 5,
                              // ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 5.0,
                                ),
                                child: CircleAvatar(
                                  radius: 24,
                                  backgroundColor: Colors.white,
                                  child: FaIcon(
                                    widget.type == 'Pdf'
                                        ? FontAwesomeIcons.filePdf
                                        : widget.type == 'Zip'
                                            ? FontAwesomeIcons.fileZipper
                                            : FontAwesomeIcons.android,
                                    color: widget.type == 'Pdf'
                                        ? Colors.red
                                        : widget.type == 'Zip'
                                            ? Colors.grey
                                            : Colors.green,
                                    size: 35,
                                  ),
                                ),
                              ),

                              Text(
                                widget.name.length <= 21
                                    ? widget.name
                                    : widget.name.replaceRange(
                                        18, widget.name.length, '...'),
                                style: TextStyle(
                                  fontSize: 13,
                                  // color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  height: 70,
                                  width: 60,
                                  color: Colors.transparent,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      download
                                          ? Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Text(
                                                  '$percentage%',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                CircularProgressIndicator(
                                                  color: Colors.white,
                                                  value: prog,
                                                ),
                                              ],
                                            )
                                          : Container(),
                                      Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 4),
                                            child: Text(
                                              widget.size,
                                              style: TextStyle(
                                                // color: Colors.white,
                                                fontSize: 11,
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.green,
                  backgroundImage: NetworkImage(widget.pic),
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
                        // Icon(
                        //   Icons.check,
                        //   size: 15,
                        //   color: read ? kPrimaryColor : Colors.grey,
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
