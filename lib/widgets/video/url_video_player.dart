import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PlayerWidget extends StatefulWidget {
  const PlayerWidget(
      {Key? key, required this.url, required this.name, this.path})
      : super(key: key);
  final String url;
  final String name;
  final String? path;

  @override
  _PlayerWidgetState createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  late VideoPlayerController videoController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.path == null) {
      videoController = VideoPlayerController.network(widget.url);
    } else {
      videoController = VideoPlayerController.file(File(widget.path ?? ""));
    }
    videoController.initialize().then((value) {
      setState(() {
        chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: true,
          aspectRatio: 16 / 9,
          looping: true,
        );
      });

      // controller
      //   ..addListener(() => setState(() {}))
      //   ..setLooping(true)
      //   ..initialize().then((_) => controller.play());
    });
  }

  @override
  void dispose() {
    videoController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
        alignment: Alignment.center,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back_ios)),
            centerTitle: true,
            title: Text(
              widget.name,
              style: TextStyle(fontFamily: 'Droid'),
            ),
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xff2D475F), Color(0xff3AA8F2)],
                ),
              ),
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              videoController.value.isInitialized
                  ? Expanded(
                      child: Chewie(controller: chewieController),
                    )
                  : Container(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )

              // VideoPlayerWidget(controller: controller),
            ],
          ),
        ),
      );
}
