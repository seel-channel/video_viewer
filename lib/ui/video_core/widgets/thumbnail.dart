import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreThumbnail extends StatelessWidget {
  const VideoCoreThumbnail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final video = query.video(context, listen: true);
    final style = query.videoStyle(context);

    final Widget? thumbnail = style.thumbnail;

    return CustomOpacityTransition(
      visible: video.isShowingThumbnail,
      child: Stack(children: [
        if (thumbnail != null) Positioned.fill(child: thumbnail),
        Center(child: PlayAndPause(type: PlayAndPauseType.center)),
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              video.video!.play();
              video.showAndHideOverlay();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ]),
    );
  }
}
