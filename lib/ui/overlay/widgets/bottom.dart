import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/overlay/widgets/progress_bar.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class OverlayBottom extends StatefulWidget {
  OverlayBottom({Key? key}) : super(key: key);

  @override
  _OverlayBottomState createState() => _OverlayBottomState();
}

class _OverlayBottomState extends State<OverlayBottom> {
  final ValueNotifier<bool> _showRemaingText = ValueNotifier<bool>(false);
  final VideoQuery _query = VideoQuery();

  @override
  void dispose() {
    _showRemaingText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = _query.videoStyle(context);
    final video = _query.video(context, listen: true);

    final isFullscreen = video.isFullScreen;
    final controller = video.video!;
    final barStyle = style.progressBarStyle;
    final padding = barStyle.paddingBeetwen;

    final halfPadding = Margin.all(padding / 2);

    final videoValue = controller.value;
    final position = videoValue.position;
    final duration = videoValue.duration;

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
            ValueListenableBuilder(
              valueListenable: _showRemaingText,
              builder: (_, bool showText, __) => SplashCircularIcon(
                padding: halfPadding,
                onTap: () {
                  _showRemaingText.value = !showText;
                  video.cancelCloseOverlay();
                },
                child: AutoSizeText(
                  showText
                      ? _query.durationFormatter(position)
                      : _query.durationFormatter(position - duration),
                  style: style.textStyle,
                ),
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
