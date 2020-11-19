import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoProgressBar extends StatefulWidget {
  VideoProgressBar(
    this.controller, {
    Key key,
    VideoProgressBarStyle style,
    this.isBuffering = false,
    this.changePosition,
  })  : this.style = style ?? VideoProgressBarStyle(),
        super(key: key);

  final bool isBuffering;
  final VideoProgressBarStyle style;
  final VideoPlayerController controller;
  final void Function(double) changePosition;

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  Color backgroundColor, bufferedColor, activeColor;
  int maxBuffering, duration, position;
  VideoPlayerController controller;
  int animationMS = 500;
  double height = 0;
  bool dragging = false;

  @override
  void initState() {
    backgroundColor = widget.style.backgroundColor;
    bufferedColor = widget.style.bufferedColor;
    activeColor = widget.style.activeColor;
    controller = widget.controller;
    if (controller.value.initialized)
      duration = controller.value.duration.inMilliseconds;
    height = widget.style.height;
    controller.addListener(progressListener);
    progressListener();
    Misc.onLayoutRendered(() {
      if (controller.value.isPlaying && !widget.isBuffering)
        setState(() {
          position = controller.value.position.inMilliseconds + 500;
        });
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.removeListener(progressListener);
    super.dispose();
  }

  void play() {
    if (!controller.value.isPlaying) controller.play();
  }

  void pause() {
    if (controller.value.isPlaying) controller.pause();
  }

  void progressListener() {
    if (mounted && controller.value.initialized)
      setState(() {
        if (controller.value.isPlaying && animationMS != 500) animationMS = 500;
        maxBuffering = 0;
        position = controller.value.position.inMilliseconds;
        for (DurationRange range in controller.value.buffered) {
          final int end = range.end.inMilliseconds;
          if (end > maxBuffering) maxBuffering = end;
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      double width = constraints.maxWidth;

      return _detectTap(
        width: width,
        child: Container(
          width: width,
          color: Colors.transparent,
          margin: widget.style.margin,
          alignment: Alignment.centerLeft,
          child: controller.value.initialized
              ? Stack(alignment: AlignmentDirectional.centerStart, children: [
                  _progressBar(width, backgroundColor),
                  _progressBar(
                      (maxBuffering / duration) * width, bufferedColor),
                  _progressBar((position / duration) * width, activeColor),
                  _dotDragging(width),
                  _dotIdentifier(width),
                ])
              : _progressBar(width, backgroundColor),
        ),
      );
    });
  }

  Widget _dotIdentifier(double maxWidth) => _dot(maxWidth);
  Widget _dotDragging(double maxWidth) {
    return BooleanTween(
      animate: dragging &&
          position != 0 &&
          position != controller.value.duration.inMilliseconds,
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (value) => _dot(maxWidth, value, 2),
    );
  }

  Widget _dot(double maxWidth, [double opacity = 1, int multiplicator]) {
    multiplicator = Misc.ifNull(multiplicator, 1);
    double width = position == 0
        ? height * 2
        : ((position / duration) * maxWidth) + height * multiplicator;

    return AnimatedContainer(
      width: width,
      duration: Duration(milliseconds: animationMS),
      alignment: Alignment.centerRight,
      child: Container(
        height: height * 2 * multiplicator,
        width: height * 2 * multiplicator,
        decoration: BoxDecoration(
          color: widget.style.dotColor.withOpacity(opacity),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _progressBar(double width, Color color) {
    return AnimatedContainer(
      width: width,
      height: height,
      duration: Duration(milliseconds: animationMS),
      decoration: BoxDecoration(
        color: color,
        borderRadius: widget.style.borderRadius,
      ),
    );
  }

  Widget _detectTap({Widget child, double width}) {
    void seekToRelativePosition(Offset local, [Offset global]) async {
      final double localPos = local.dx / width;
      final Duration position = controller.value.duration * localPos;
      await controller.seekTo(position);
      if (widget.changePosition != null && global != null) {
        if (local.dx > 0 && local.dx < width) widget.changePosition(global.dx);
      }
    }

    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) async {
        setState(() => dragging = true);
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.localPosition, details.globalPosition);
      },
      onHorizontalDragEnd: (DragEndDetails details) async {
        if (widget.changePosition != null) widget.changePosition(null);
        setState(() => dragging = false);
        play();
      },
      onTapDown: (TapDownDetails details) {
        setState(() {
          dragging = true;
          animationMS = 0;
        });
        pause();
        seekToRelativePosition(details.localPosition);
      },
      onTapUp: (TapUpDetails details) {
        setState(() => dragging = false);
        seekToRelativePosition(details.localPosition);
        Misc.delayed(50, () => play());
      },
    );
  }
}

class VideoVolumeBar extends StatelessWidget {
  const VideoVolumeBar({
    Key key,
    this.style,
    this.progress,
  }) : super(key: key);

  final double progress;
  final VideoVolumeBarStyle style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.padding,
        child: ClipRRect(
          borderRadius: style.borderRadius,
          child: Container(
            height: style.height,
            width: style.width,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(color: style.backgroundColor),
                AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  height: progress * style.height,
                  decoration: BoxDecoration(
                    color: style.color,
                    borderRadius: style.borderRadius,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
