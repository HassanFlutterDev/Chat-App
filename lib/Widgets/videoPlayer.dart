import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:newchatapp/Theme/theme.dart';
import 'package:video_player/video_player.dart';

class VideoPlayer1 extends StatefulWidget {
  const VideoPlayer1({Key? key, required this.file}) : super(key: key);
  final File file;

  @override
  State<VideoPlayer1> createState() => _VideoPlayer1State();
}

class _VideoPlayer1State extends State<VideoPlayer1> {
  late VideoPlayerController videoPlayerController;
  ChewieController? _chewieController;

  Future<void> initializePlayer() async {
    videoPlayerController = VideoPlayerController.file(widget.file);
    await videoPlayerController.initialize();
    _createChewieController();
    setState(() {});
  }

  void _createChewieController() {
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      autoPlay: true,
      materialProgressColors: ChewieProgressColors(
          playedColor: kPrimaryColor,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.green.shade200),
      maxScale: 1,
      looping: false,
      showControlsOnInitialize: false,
    );
  }

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _chewieController != null &&
              _chewieController!.videoPlayerController.value.isInitialized
          ? Chewie(controller: _chewieController!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
