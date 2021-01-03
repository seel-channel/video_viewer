import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoProgressBar extends StatefulWidget {
  VideoProgressBar(
    this.controller, {
    Key key,
    this.padding,
    ProgressBarStyle style,
    this.isBuffering = false,
    this.changePosition,
  })  : this.style = style ?? ProgressBarStyle(),
        super(key: key);

  final bool isBuffering;
  final ProgressBarStyle style;
  final EdgeInsetsGeometry padding;
  final VideoPlayerController controller;
  final void Function(double, double) changePosition;

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  Color backgroundColor, bufferedColor, activeColor;
  int maxBuffering, duration, position;
  VideoPlayerController controller;
  Duration seekToPosition;
  int animationMS = 500;
  bool isDragging = false;
  double height = 0;

  @override
  void initState() {
    backgroundColor = widget.style.barBackgroundColor;
    bufferedColor = widget.style.barBufferedColor;
    activeColor = widget.style.barActiveColor;
    controller = widget.controller;
    height = widget.style.barHeight;
    if (controller.value.initialized)
      duration = controller.value.duration.inMilliseconds;
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
  void didUpdateWidget(VideoProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller.hashCode != controller.hashCode) {
      setState(() {
        controller = widget.controller;
        if (controller.value.initialized)
          duration = controller.value.duration.inMilliseconds;
      });
      controller.addListener(progressListener);
      progressListener();
    }
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

  void changePosition(double scale, double width) {
    if (widget.changePosition != null) widget.changePosition(scale, width);
  }

  void startDragging() {
    setState(() {
      isDragging = true;
      animationMS = 0;
    });
  }

  void progressListener() {
    if (mounted && controller.value.initialized)
      setState(() {
        if (controller.value.isPlaying && animationMS != 500) animationMS = 500;
        if (isDragging) animationMS = 0;
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
          padding: widget.padding,
          alignment: Alignment.centerLeft,
          child: controller.value.initialized
              ? Stack(alignment: AlignmentDirectional.centerStart, children: [
                  _progressBar(width, backgroundColor),
                  _progressBar(
                      (maxBuffering / duration) * width, bufferedColor),
                  _progressBar((position / duration) * width, activeColor),
                  _dotisDragging(width),
                  _dotIdentifier(width),
                ])
              : _progressBar(width, backgroundColor),
        ),
      );
    });
  }

  Widget _dotIdentifier(double maxWidth) => _dot(maxWidth);
  Widget _dotisDragging(double maxWidth) {
    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = height * 2;
    return BooleanTween(
      animate:
          isDragging && widthPos > widthDot && widthPos < maxWidth - widthDot,
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (value) => _dot(maxWidth, value, 2),
    );
  }

  Widget _dot(double maxWidth, [double opacity = 1, int multiplicator = 1]) {
    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = height * 2;
    final double width =
        widthPos < height ? widthDot : widthPos + height * multiplicator;

    return AnimatedContainer(
      width: width,
      duration: Duration(milliseconds: animationMS),
      alignment: Alignment.centerRight,
      child: Container(
        height: height * 2 * multiplicator,
        width: height * 2 * multiplicator,
        decoration: BoxDecoration(
          color: widget.style.barDotColor.withOpacity(opacity),
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
    void seekToRelativePosition(Offset local, [bool showText = false]) async {
      final double localPos = local.dx / width;
      final Duration position = controller.value.duration * localPos;
      await controller.seekTo(position);
      if (showText && local.dx > 0 && local.dx < width)
        changePosition(localPos, width);
    }

    return GestureDetector(
      child: child,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        startDragging();
        pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        seekToRelativePosition(details.localPosition, true);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        changePosition(null, width);
        setState(() => isDragging = false);
        Misc.delayed(50, () => play());
      },
      onTapDown: (TapDownDetails details) {
        startDragging();
        changePosition(null, width);
        seekToRelativePosition(details.localPosition);
        pause();
      },
      onTapUp: (TapUpDetails details) {
        changePosition(null, width);
        setState(() => isDragging = false);
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
  final VolumeBarStyle style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.margin,
        child: ClipRRect(
          borderRadius: style.borderRadius,
          child: Container(
            height: style.height,
            width: style.width,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(color: style.backgroundColor),
                Container(
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
