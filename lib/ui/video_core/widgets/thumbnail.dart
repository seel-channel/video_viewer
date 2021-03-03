import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreThumbnail extends StatelessWidget {
  const VideoCoreThumbnail({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final style = query.videoStyle(context);

    return CustomOpacityTransition(
      visible: video.isShowingThumbnail,
      child: GestureDetector(
        onTap: video.controller.play,
        child: Container(
          color: Colors.transparent,
          child: style.thumbnail,
        ),
      ),
    );
  }
}
