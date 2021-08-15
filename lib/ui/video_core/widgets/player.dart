import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer/data/repositories/video.dart';

class VideoCorePlayer extends StatefulWidget {
  const VideoCorePlayer({Key? key}) : super(key: key);

  @override
  _VideoCorePlayerState createState() => _VideoCorePlayerState();
}

class _VideoCorePlayerState extends State<VideoCorePlayer> {
  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final style = query.videoStyle(context);
    final controller = VideoQuery().video(context, listen: true);

    return Center(
      child: AspectRatio(
        aspectRatio: controller.video!.value.aspectRatio,
        child: !controller.isChangingSource
            ? VideoPlayer(controller.video!)
            : Container(color: Colors.black, child: style.loading),
      ),
    );
  }
}
