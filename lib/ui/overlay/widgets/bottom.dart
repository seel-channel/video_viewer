import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/overlay/widgets/progress_bar.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class OverlayBottom extends StatefulWidget {
  const OverlayBottom({Key? key}) : super(key: key);

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
    final controller = _query.video(context, listen: true);
    final metadata = _query.videoMetadata(context);
    final style = _query.videoStyle(context);
    final barStyle = style.progressBarStyle;

    final bool isFullscreen = controller.isFullScreen;
    final double padding = barStyle.paddingBeetwen;
    final Margin halfPadding = Margin.all(padding / 2);

    final Duration position = controller.position;
    final Duration duration = controller.duration;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: (style.textStyle.fontSize ?? 14) + barStyle.bar.height,
        ),
        GradientBackground(
          child: Row(children: [
            PlayAndPause(
              type: PlayAndPauseType.bottom,
              padding: Margin.all(padding),
            ),
            const Expanded(child: VideoProgressBar()),
            SizedBox(width: padding),
            ValueListenableBuilder(
              valueListenable: _showRemaingText,
              builder: (_, bool showText, __) => SplashCircularIcon(
                padding: halfPadding,
                onTap: () {
                  _showRemaingText.value = !showText;
                  controller.cancelCloseOverlay();
                },
                child: Text(
                  showText
                      ? _query.durationFormatter(position)
                      : _query.durationFormatter(position - duration),
                  style: style.textStyle,
                ),
              ),
            ),
            SplashCircularIcon(
              padding: halfPadding,
              onTap: () {
                controller.openSettingsMenu();
                controller.showAndHideOverlay(false);
              },
              child: style.settingsStyle.settings,
            ),
            if (metadata.enableChat)
              SplashCircularIcon(
                padding: halfPadding,
                onTap: () => controller.isShowingChat = true,
                child: style.chatStyle.chatIcon,
              ),
            SplashCircularIcon(
              padding: halfPadding + Margin.right(padding / 2),
              onTap: () => controller.openOrCloseFullscreen(),
              child:
                  isFullscreen ? barStyle.fullScreenExit : barStyle.fullScreen,
            ),
          ]),
        ),
      ],
    );
  }
}
