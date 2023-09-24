import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Showsnackbar(BuildContext context, String text) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    // duration: Duration(seconds: 20),
    content: Text(
      text,
    ),
  ));
}
