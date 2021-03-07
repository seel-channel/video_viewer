import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/overlay/widgets/progress_bar.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class OverlayBottomButtons extends StatefulWidget {
  OverlayBottomButtons({Key? key}) : super(key: key);

  @override
  _OverlayBottomButtonsState createState() => _OverlayBottomButtonsState();
}

class _OverlayBottomButtonsState extends State<OverlayBottomButtons> {
  final VideoQuery _query = VideoQuery();
  bool _showRemaingText = false;

  @override
  Widget build(BuildContext context) {
    final style = _query.videoStyle(context);
    final video = _query.video(context, listen: true);

    final isFullscreen = video.isFullScreen;
    final controller = video.controller!;
    final barStyle = style.progressBarStyle;
    final padding = barStyle.paddingBeetwen;

    final halfPadding = Margin.all(padding / 2);

    final value = controller.value;
    final position = value.position;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GradientBackground(
          child: Row(children: [
            PlayAndPause(
              type: PlayAndPauseType.bottom,
              padding: Margin.all(padding),
            ),
            Expanded(child: VideoProgressBar()),
            SizedBox(width: padding),
            SplashCircularIcon(
              padding: halfPadding,
              onTap: () {
                setState(() => _showRemaingText = !_showRemaingText);
                video.cancelCloseOverlay();
              },
              child: Text(
                _showRemaingText
                    ? _query.durationFormatter(position)
                    : _query.durationFormatter(position - value.duration),
                style: style.textStyle,
              ),
            ),
            SplashCircularIcon(
              padding: halfPadding,
              onTap: video.openSettingsMenu,
              child: style.settingsStyle.settings,
            ),
            SplashCircularIcon(
              padding: halfPadding + Margin.right(padding / 2),
              onTap: () async {
                if (!isFullscreen)
                  await video.openFullScreen(context);
                else
                  await video.closeFullScreen(context);
              },
              child:
                  isFullscreen ? barStyle.fullScreenExit : barStyle.fullScreen,
            ),
          ]),
        ),
      ],
    );
  }
}
