import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/data/repositories/video.dart';

class VideoProgressBar extends StatefulWidget {
  VideoProgressBar({Key key}) : super(key: key);

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  final _query = VideoQuery();
  final animationMS = ValueNotifier<int>(1000);

  @override
  Widget build(BuildContext context) {
    final video = _query.video(context, listen: true);
    final style = _query.videoStyle(context).progressBarStyle;

    final controller = video.controller;
    final position = controller.value.position.inMilliseconds;
    final duration = controller.value.duration.inMilliseconds;

    return ListenableProvider.value(
      value: animationMS,
      child: LayoutBuilder(
        builder: (_, constraints) {
          double width = constraints.maxWidth;
          return _detectTap(
            width: width,
            child: Container(
              width: width,
              color: Colors.transparent,
              padding: Margin.vertical(style.paddingBeetwen),
              alignment: Alignment.centerLeft,
              child: controller.value.initialized
                  ? Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                          _ProgressBar(
                              width: width, color: style.barBackgroundColor),
                          _ProgressBar(
                              width: (video.maxBuffering / duration) * width,
                              color: style.barBufferedColor),
                          _ProgressBar(
                              width: (position / duration) * width,
                              color: style.barActiveColor),
                          _dotisDragging(width),
                          _dotIdentifier(width),
                        ])
                  : _ProgressBar(
                      width: width,
                      color: style.barBackgroundColor,
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _dotIdentifier(double maxWidth) => _dot(maxWidth);
  Widget _dotisDragging(double maxWidth) {
    final video = _query.video(context, listen: true);
    final style = _query.videoStyle(context).progressBarStyle;

    final controller = video.controller;
    final position = controller.value.position.inMilliseconds;
    final duration = controller.value.duration.inMilliseconds;

    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = style.barHeight * 2;
    return BooleanTween(
      animate: video.isDraggingProgressBar &&
          (widthPos > widthDot) &&
          (widthPos < maxWidth - widthDot),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (_, value, __) => _dot(maxWidth, value, 2),
    );
  }

  Widget _dot(double maxWidth, [double opacity = 1, int multiplicator = 1]) {
    final query = VideoQuery();
    final style = query.videoStyle(context).progressBarStyle;
    final controller = query.video(context, listen: true).controller;

    final height = style.barHeight;

    final double widthPos = (controller.value.position.inMilliseconds /
            controller.value.duration.inMilliseconds) *
        maxWidth;
    final double widthDot = height * 2;
    final double width =
        widthPos < height ? widthDot : widthPos + height * multiplicator;

    return ValueListenableBuilder(
      valueListenable: animationMS,
      builder: (_, int value, __) {
        return AnimatedContainer(
          width: width,
          duration: Duration(milliseconds: value),
          alignment: Alignment.centerRight,
          child: Container(
            height: height * 2 * multiplicator,
            width: height * 2 * multiplicator,
            decoration: BoxDecoration(
              color: style.barDotColor.withOpacity(opacity),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  void play() {
    _query.video(context).controller?.play();
    animationMS.value = 1000;
  }

  void pause() {
    _query.video(context).controller?.pause();
    animationMS.value = 0;
  }

  void _startDragging() {
    _query.video(context).isDraggingProgressBar = true;
  }

  void _endDragging() {
    _query.video(context).isDraggingProgressBar = false;
    Misc.delayed(50, () => play());
  }

  Widget _detectTap({Widget child, double width}) {
    void seekToRelativePosition(Offset local, [bool showText = false]) async {
      final controller = _query.video(context).controller;
      final double localPos = local.dx / width;
      final Duration position = controller.value.duration * localPos;
      await controller.seekTo(position);
    }

    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        _startDragging();
        pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.localPosition, true);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _endDragging();
      },
      onTapDown: (TapDownDetails details) {
        _startDragging();
        seekToRelativePosition(details.localPosition);
        pause();
      },
      onTapUp: (TapUpDetails details) {
        seekToRelativePosition(details.localPosition);
        _endDragging();
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    Key key,
    @required this.width,
    @required this.color,
  }) : super(key: key);

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = VideoQuery().videoStyle(context).progressBarStyle;

    return AnimatedContainer(
      width: width,
      height: style.barHeight,
      duration: Duration(milliseconds: animation.value),
      decoration: BoxDecoration(
        color: color,
        borderRadius: style.borderRadius,
      ),
    );
  }
}
