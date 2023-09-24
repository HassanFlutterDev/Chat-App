// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class audio_player_media extends StatefulWidget {
  String url;
  String dur;
  audio_player_media({super.key, required this.dur, required this.url});

  @override
  State<audio_player_media> createState() => _audio_player_mediaState();
}

class _audio_player_mediaState extends State<audio_player_media> {
  final audioplayer = AudioPlayer();
  bool isplaying = false;
  bool buff = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  void initState() {
    // ignore: todo
    // TODO: implement initState
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: CupertinoButton(
            child: Icon(
              Icons.arrow_back_ios,
              size: 25,
              color: Colors.white,
            ),
            onPressed: () {}),
        title: Center(
          child: Text(
            'Audio',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 100,
          ),
          Center(
            child: Container(
              height: 200,
              width: 300,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Icon(
                  CupertinoIcons.headphones,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 90,
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Slider(
                      thumbColor: Colors.white,
                      activeColor: Colors.white,
                      inactiveColor: Colors.grey,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (v) async {
                        final position = Duration(seconds: v.toInt());
                        await audioplayer.seek(position);
                        await audioplayer.resume();
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formatTime(position),
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            if (isplaying) {
                              await audioplayer.pause();
                            } else {
                              await audioplayer.play(UrlSource(widget.url));
                              buff = true;
                              await Future.delayed(Duration(seconds: 2));
                              buff = false;
                            }

                            setState(() {});
                          },
                          child: Icon(
                            isplaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.dur,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
