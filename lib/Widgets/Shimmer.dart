// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerSearch extends StatefulWidget {
  const ShimmerSearch({Key? key}) : super(key: key);

  @override
  State<ShimmerSearch> createState() => _ShimmerSearchState();
}

class _ShimmerSearchState extends State<ShimmerSearch> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 500),
        baseColor: Color.fromARGB(200, 199, 194, 194),
        highlightColor: Color.fromARGB(255, 120, 120, 120),
        child: SingleChildScrollView(
          child: Column(
            children: [
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
              tile(),
            ],
          ),
        ));
  }
}

class tile extends StatelessWidget {
  const tile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(radius: 20),
        title: Container(
          decoration: BoxDecoration(
              color: Colors.white70, borderRadius: BorderRadius.circular(5)),
          height: 20,
        ));
  }
}
