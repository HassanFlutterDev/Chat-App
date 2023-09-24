import 'dart:developer';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Theme_screen extends StatefulWidget {
  const Theme_screen({super.key});

  @override
  State<Theme_screen> createState() => _Theme_screenState();
}

class _Theme_screenState extends State<Theme_screen> {
  int select = 0;
  storeonboard() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt('theme', select);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            Theme.of(context).scaffoldBackgroundColor == Colors.black
                ? Colors.black
                : Colors.white,
        leading: CupertinoButton(
            child: Icon(
              EvaIcons.arrowIosBack,
              color: Colors.black,
            ),
            onPressed: () {}),
        title: Text('Theme'),
      ),
      body: Column(
        children: [
          ListTile(
            title: Text('Light Theme'),
            leading: Radio(
              value: 2,
              groupValue: select,
              onChanged: (v) {
                setState(() {
                  select = v!;
                  storeonboard();
                  log(select.toString());
                });
              },
              activeColor: kPrimaryColor,
            ),
          ),
          ListTile(
            title: Text('Dark Theme'),
            leading: Radio(
              value: 1,
              groupValue: select,
              onChanged: (v) {
                setState(() {
                  select = v!;
                  storeonboard();
                  log(select.toString());
                });
              },
              activeColor: kPrimaryColor,
            ),
          ),
          ListTile(
            title: Text('System Theme'),
            leading: Radio(
              value: 0,
              groupValue: select,
              onChanged: (v) {
                setState(() {
                  select = v!;
                  storeonboard();
                  log(select.toString());
                });
              },
              activeColor: kPrimaryColor,
            ),
          )
        ],
      ),
    );
  }
}
