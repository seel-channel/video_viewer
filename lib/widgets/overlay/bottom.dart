import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_viewer/widgets/overlay/background.dart';
import 'package:video_viewer/widgets/progress.dart';
import 'package:video_viewer/widgets/helpers.dart';
import 'package:video_viewer/utils/provider.dart';
import 'package:video_viewer/utils/styles.dart';
import 'package:video_viewer/utils/misc.dart';

class OverlayBottomButtons extends StatefulWidget {
  OverlayBottomButtons({
    Key key,
    @required this.onPlayAndPause,
    this.verticalPadding = 20.0,
  }) : super(key: key);

  final void Function() onPlayAndPause;
  final double verticalPadding;

  @override
  _OverlayBottomButtonsState createState() => _OverlayBottomButtonsState();
}

class _OverlayBottomButtonsState extends State<OverlayBottomButtons> {
  void toFullscreen() {
    if (kIsWeb) {
      html.document.documentElement.onFullscreenChange.listen((_) {
        setVideoFullScreen(context, html.document.fullscreenElement != null);
      });
      html.document.documentElement.requestFullscreen();
    } else
      PushRoute.page(
        context,
        FullScreenPage(
          style: _style,
          source: widget.source,
          looping: widget.looping,
          language: widget.language,
          controller: _controller,
          rewindAmount: widget.rewindAmount,
          forwardAmount: widget.forwardAmount,
          activedSource: _activedSource,
          fixedLandscape: widget.onFullscreenFixLandscape,
          settingsMenuItems: widget.settingsMenuItems,
          defaultAspectRatio: widget.defaultAspectRatio,
          changeSource: (controller, activedSource) {
            _changeVideoSource(controller, activedSource, false);
          },
        ),
        transition: false,
      );
  }

  void _exitFullscreen() {
    if (kIsWeb) {
      html.document.exitFullscreen();
    } else if (widget.exitFullScreen != null) widget.exitFullScreen();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getVideoController(context);
    final globalStyle = getVideoStyle(context);
    final style = globalStyle.progressBarStyle;

    String position = "00:00", remaing = "-00:00";
    double padding = style.paddingBeetwen;

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
          isDragging: true,
          text: position,
          style: globalStyle,
        ),
        GradientBackground(
          child: Row(children: [
            GestureDetector(
              onTap: onPlayAndPause,
              child: Container(
                padding: Margin.symmetric(
                  horizontal: padding,
                  vertical: verticalPadding,
                ),
                child: !controller.value.isPlaying
                    ? globalStyle.playAndPauseStyle.play
                    : globalStyle.playAndPauseStyle.pause,
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: controller,
                builder: (_, __) {
                  return VideoProgressBar(
                    controller,
                    style: style,
                    padding: Margin.vertical(verticalPadding),
                    isBuffering: _isBuffering,
                    changePosition: (double scale, double width) {
                      if (mounted) {
                        if (scale != null) {
                          setState(() {
                            _isDraggingProgress = true;
                            _progressScale = scale;
                            _progressBarWidth = width;
                          });
                          _cancelCloseOverlayButtons();
                        } else {
                          setState(() => _isDraggingProgress = false);
                          _startCloseOverlayButtons();
                        }
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
                  setState(() => _switchRemaingText = !_switchRemaingText);
                  _cancelCloseOverlayButtons();
                },
                child: _containerPadding(
                  child: Text(
                    _switchRemaingText ? position : remaing,
                    style: _style.textStyle,
                  ),
                ),
              ),
            ),
            _settingsIconButton(),
            GestureDetector(
              onTap: () async {
                if (!_isFullScreen)
                  toFullscreen();
                else
                  _exitFullscreen();
              },
              child: _containerPadding(
                child: _isFullScreen ? style.fullScreenExit : style.fullScreen,
              ),
            ),
            SizedBox(width: padding),
          ]),
        ),
      ]),
    );
  }
}

class _TextPositionProgress extends StatelessWidget {
  const _TextPositionProgress({
    Key key,
    this.isDragging,
    this.text,
    this.style,
  }) : super(key: key);

  final String text;
  final bool isDragging;
  final VideoViewerStyle style;

  @override
  Widget build(BuildContext context) {
    double width = 60;
    double margin = 20;

    return CustomFadeTransition(
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
