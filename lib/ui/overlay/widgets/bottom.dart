import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/progress_bar.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class OverlayBottomButtons extends StatefulWidget {
  OverlayBottomButtons({Key key}) : super(key: key);

  @override
  _OverlayBottomButtonsState createState() => _OverlayBottomButtonsState();
}

class _OverlayBottomButtonsState extends State<OverlayBottomButtons> {
  final VideoQuery _query = VideoQuery();
  bool _showRemaingText = false;
  bool _isDraggingBar = false;

  @override
  Widget build(BuildContext context) {
    final style = _query.videoStyle(context);
    final video = _query.video(context, listen: true);

    final isFullscreen = video.isFullScreen;
    final controller = video.controller;
    final barStyle = style.progressBarStyle;
    final padding = barStyle.paddingBeetwen;
    final edgeInset = Margin.vertical(padding);

    String position = "00:00", remaing = "-00:00";

    if (controller.value.initialized) {
      final value = controller.value;
      final seconds = value.position.inSeconds;
      position = _query.secondsFormatter(seconds);
      remaing = _query.secondsFormatter(seconds - value.duration.inSeconds);
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: SizedBox()),
        _TextPositionProgress(
          text: position,
          isDragging: _isDraggingBar,
        ),
        GradientBackground(
          child: Row(children: [
            PlayAndPause(
              type: PlayAndPauseType.bottom,
              padding: Margin.all(padding),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return VideoProgressBar(
                    controller,
                    style: barStyle,
                    padding: edgeInset,
                    isBuffering: video.isBuffering,
                    changePosition: (double scale, double width) {
                      if (mounted) {
                        setState(() => _isDraggingBar = scale != null);
                        video.cancelCloseOverlay();
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(width: padding),
            Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() => _showRemaingText = !_showRemaingText);
                  video.cancelCloseOverlay();
                },
                child: _ContainerPadding(
                  padding: edgeInset,
                  child: Text(
                    _showRemaingText ? position : remaing,
                    style: style.textStyle,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => video.isShowingSettingsMenu = true,
                child: Container(
                  color: Colors.transparent,
                  child: style.settingsStyle.settings,
                  padding: Margin.horizontal(padding) + edgeInset,
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                if (!isFullscreen)
                  await video.openFullScreen(context);
                else
                  await video.closeFullScreen(context);
              },
              child: _ContainerPadding(
                  child: isFullscreen
                      ? barStyle.fullScreenExit
                      : barStyle.fullScreen,
                  padding: edgeInset),
            ),
            SizedBox(width: padding),
          ]),
        ),
      ]),
    );
  }
}

class _ContainerPadding extends StatelessWidget {
  const _ContainerPadding({
    Key key,
    @required this.child,
    @required this.padding,
  }) : super(key: key);

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: child,
      padding: padding,
    );
  }
}

class _TextPositionProgress extends StatelessWidget {
  const _TextPositionProgress({
    Key key,
    this.isDragging,
    this.text,
  }) : super(key: key);

  final String text;
  final bool isDragging;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context);
    double width = 60;
    double margin = 20;

    return CustomOpacityTransition(
      visible: isDragging,
      child: Container(
        width: width,
        child: Text(text, style: style.textStyle),
        margin: Margin.left(margin < 0 ? 0 : margin),
        padding: Margin.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: style.progressBarStyle.backgroundColor,
          borderRadius: style.progressBarStyle.borderRadius,
        ),
      ),
    );
  }
}
