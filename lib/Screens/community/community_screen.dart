import 'package:flutter/material.dart';

class Community_screen extends StatefulWidget {
  const Community_screen({super.key});

  @override
  State<Community_screen> createState() => _Community_screenState();
}

class _Community_screenState extends State<Community_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Text(
        'This Is In Build!',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      )),
    );
  }
}
