import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCorePlayAndPause extends StatelessWidget {
  const VideoCorePlayAndPause({
    Key key,
    @required this.showAMoment,
  }) : super(key: key);

  final bool showAMoment;

  @override
  Widget build(BuildContext context) {
    final video = VideoQuery().video(context);
    final position = video.controller.value.position;
    final duration = video.controller.value.duration;

    return Center(
      child: CustomOpacityTransition(
        visible: showAMoment || position >= duration,
        child: PlayAndPause(type: PlayAndPauseType.center),
      ),
    );
  }
}
