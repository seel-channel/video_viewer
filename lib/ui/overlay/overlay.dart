import 'package:helpers/helpers.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/settings_menu/settings_menu.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/overlay/widgets/bottom.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreOverlay extends StatelessWidget {
  const VideoCoreOverlay({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoMetadata(context, listen: true).style;
    final video = query.video(context, listen: true);

    final header = style.header;
    final visible = video.isShowingOverlay;
    final controller = video.controller;

    return CustomOpacityTransition(
      visible: !video.isShowingThumbnail,
      child: Stack(children: [
        if (header != null)
          CustomSwipeTransition(
            direction: SwipeDirection.fromTop,
            visible: visible,
            child: Align(
              alignment: Alignment.topLeft,
              child: GradientBackground(
                child: header,
                direction: Direction.top,
              ),
            ),
          ),
        CustomSwipeTransition(
          direction: SwipeDirection.fromBottom,
          visible: visible,
          child: OverlayBottomButtons(),
        ),
        AnimatedBuilder(
          animation: controller,
          builder: (_, __) => CustomOpacityTransition(
            visible: visible && !controller.value.isPlaying,
            child: Center(child: PlayAndPause(type: PlayAndPauseType.center)),
          ),
        ),
        CustomOpacityTransition(
          visible: video.isShowingSettingsMenu,
          child: SettingsMenu(),
        ),
      ]),
    );
  }
}
