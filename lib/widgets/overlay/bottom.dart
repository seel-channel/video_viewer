import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/widgets/overlay/widgets/play_and_pause.dart';
import 'package:video_viewer/widgets/overlay/widgets/background.dart';
import 'package:video_viewer/widgets/fullscreen.dart';
import 'package:video_viewer/widgets/progress.dart';
import 'package:video_viewer/widgets/helpers.dart';
import 'package:video_viewer/utils/misc.dart';

class OverlayBottomButtons extends StatefulWidget {
  OverlayBottomButtons({
    Key key,
    @required this.onShowSettings,
    this.onExitFullScreen,
    this.verticalPadding = 20.0,
  }) : super(key: key);

  final double verticalPadding;
  final void Function() onShowSettings;
  final void Function() onExitFullScreen;

  @override
  _OverlayBottomButtonsState createState() => _OverlayBottomButtonsState();
}

class _OverlayBottomButtonsState extends State<OverlayBottomButtons> {
  final VideoQuery query = VideoQuery();
  bool _showRemaingText = false;
  bool _isDraggingBar = false;

  void toFullscreen() {
    if (kIsWeb) {
      html.document.documentElement.onFullscreenChange.listen((_) {
        query.setVideoFullScreen(
            context, html.document.fullscreenElement != null);
      });
      html.document.documentElement.requestFullscreen();
    } else
      PushRoute.page(
        context,
        FullScreenPage(),
        transition: false,
      );
  }

  void _exitFullscreen() {
    if (kIsWeb)
      html.document.exitFullscreen();
    else
      widget?.onExitFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final style = query.getVideoStyle(context);
    final video = query.getVideo(context);
    final isFullscreen = query.getVideoFullScreen(context);
    final edgeInset = Margin.vertical(widget.verticalPadding);
    final barStyle = style.progressBarStyle;
    final padding = barStyle.paddingBeetwen;
    final controller = video.controller;

    String position = "00:00", remaing = "-00:00";

    if (controller.value.initialized) {
      final value = controller.value;
      final seconds = value.position.inSeconds;
      position = secondsFormatter(seconds);
      remaing = secondsFormatter(seconds - value.duration.inSeconds);
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
              padding: Margin.symmetric(
                horizontal: padding,
                vertical: widget.verticalPadding,
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return VideoProgressBar(
                    controller,
                    style: barStyle,
                    padding: edgeInset,
                    isBuffering: query.getVideoBuffering(context),
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
                onTap: widget.onShowSettings,
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
                  toFullscreen();
                else
                  _exitFullscreen();
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
    final style = VideoQuery().getVideoStyle(context);
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
