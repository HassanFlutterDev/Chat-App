// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class full_screen extends StatelessWidget {
  String url;
  full_screen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.black,
        leading: CupertinoButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 27,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      backgroundColor: Colors.black,
      body: InteractiveViewer(
        alignPanAxis: true,
        child: Center(
          child: Image.file(File(url)),
        ),
      ),
    );
  }
}
