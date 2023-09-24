// import 'dart:html';

// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class pdf_viewer extends StatefulWidget {
  String name;
  File url;
  pdf_viewer({
    super.key,
    required this.name,
    required this.url,
  });

  @override
  State<pdf_viewer> createState() => _pdf_viewerState();
}

class _pdf_viewerState extends State<pdf_viewer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            )),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title: Text(
          widget.name,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SfPdfViewer.file(widget.url),
    );
  }
}
