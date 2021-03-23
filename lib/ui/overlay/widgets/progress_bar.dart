import 'dart:ui' as ui;
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoProgressBar extends StatelessWidget {
  const VideoProgressBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      create: (_) => ValueNotifier<int>(1000),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final _query = VideoQuery();
          final controller = _query.video(context, listen: true);
          final videoStyle = _query.videoStyle(context);

          final style = videoStyle.progressBarStyle;
          final video = controller.video!;

          final Duration position = video.value.position;
          final Duration duration = video.value.duration;
          final double width = constraints.maxWidth;
          final double progressWidth =
              (position.inMilliseconds / duration.inMilliseconds) * width;

          return _ProgressBarGesture(
            width: width,
            child: Padding(
              padding: Margin.vertical(style.paddingBeetwen),
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  _ProgressBar(width: width, color: style.barBackgroundColor),
                  _ProgressBar(
                      width: (controller.maxBuffering.inMilliseconds /
                              duration.inMilliseconds) *
                          width,
                      color: style.barBufferedColor),
                  _ProgressBar(
                      width: progressWidth, color: style.barActiveColor),
                  _DotIsDragging(maxWidth: width),
                  _Dot(maxWidth: width),
                  CustomOpacityTransition(
                    visible: controller.isDraggingProgressBar,
                    child: CustomPaint(
                      painter: _TextPositionPainter(
                        barStyle: style,
                        position: video.value.position,
                        width: progressWidth,
                        style: videoStyle.textStyle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DotIsDragging extends StatelessWidget {
  const _DotIsDragging({Key? key, required this.maxWidth}) : super(key: key);

  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final _query = VideoQuery();
    final controller = _query.video(context, listen: true);
    final style = _query.videoStyle(context).progressBarStyle;

    final video = controller.video!;
    final position = video.value.position.inMilliseconds;
    final duration = video.value.duration.inMilliseconds;

    final double widthPos = (position / duration) * maxWidth;
    final double widthDot = style.barHeight * 2;

    return BooleanTween(
      animate: controller.isDraggingProgressBar &&
          (widthPos > widthDot) &&
          (widthPos < maxWidth - widthDot),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (_, double value, __) => _Dot(
        maxWidth: maxWidth,
        opacity: value,
        multiplicator: 2,
      ),
    );
  }
}

class _ProgressBarGesture extends StatefulWidget {
  const _ProgressBarGesture({
    Key? key,
    this.child,
    this.width,
  }) : super(key: key);

  final Widget? child;
  final double? width;
  @override
  __ProgressBarGestureState createState() => __ProgressBarGestureState();
}

class __ProgressBarGestureState extends State<_ProgressBarGesture> {
  final _query = VideoQuery();

  void _seekToRelativePosition(Offset local, [bool showText = false]) async {
    final video = _query.video(context).video!;
    final double localPos = local.dx / widget.width!;
    final Duration position = video.value.duration * localPos;
    await video.seekTo(position);
  }

  void play() {
    _query.video(context).video?.play();
    Provider.of<ValueNotifier<int>>(context, listen: false).value = 1000;
  }

  void pause() {
    _query.video(context).video?.pause();
    Provider.of<ValueNotifier<int>>(context, listen: false).value = 0;
  }

  void _startDragging() {
    _query.video(context).isDraggingProgressBar = true;
  }

  void _endDragging() {
    _query.video(context).isDraggingProgressBar = false;
    Misc.delayed(50, () => play());
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
      behavior: HitTestBehavior.opaque,
      onHorizontalDragStart: (DragStartDetails details) {
        _startDragging();
        pause();
      },
      onHorizontalDragUpdate: (DragUpdateDetails details) {
        _seekToRelativePosition(details.localPosition, true);
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        _endDragging();
      },
      onTapDown: (TapDownDetails details) {
        _startDragging();
        _seekToRelativePosition(details.localPosition);
        pause();
      },
      onTapUp: (TapUpDetails details) {
        _seekToRelativePosition(details.localPosition);
        _endDragging();
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    Key? key,
    required this.width,
    required this.color,
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
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: style.borderRadius,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    Key? key,
    this.maxWidth,
    this.opacity = 1,
    this.multiplicator = 1,
  }) : super(key: key);

  final double? maxWidth, opacity;
  final int multiplicator;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = query.videoStyle(context).progressBarStyle;
    final video = query.video(context, listen: true).video!;

    final height = style.barHeight;

    final double widthPos = (video.value.position.inMilliseconds /
            video.value.duration.inMilliseconds) *
        maxWidth!;
    final double widthDot = height * 2;
    final double width =
        widthPos < height ? widthDot : widthPos + height * multiplicator;

    return ValueListenableBuilder(
      valueListenable: animation,
      builder: (_, int value, __) {
        return AnimatedContainer(
          width: width,
          duration: Duration(milliseconds: value),
          alignment: Alignment.centerRight,
          child: Container(
            height: height * 2 * multiplicator,
            width: height * 2 * multiplicator,
            decoration: BoxDecoration(
              color: style.barDotColor.withOpacity(opacity!),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

class _TextPositionPainter extends CustomPainter {
  _TextPositionPainter({this.width, this.position, this.style, this.barStyle});

  final double? width;
  final Duration? position;
  final TextStyle? style;
  final ProgressBarStyle? barStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final text = VideoQuery().durationFormatter(position!);
    final textStyle = ui.TextStyle(
      color: style!.color,
      fontSize: style!.fontSize! + 1,
      fontFamily: style!.fontFamily,
      fontWeight: style!.fontWeight,
      fontStyle: style!.fontStyle,
      fontFamilyFallback: style!.fontFamilyFallback,
      fontFeatures: style!.fontFeatures,
      foreground: style!.foreground,
      background: style!.background,
      letterSpacing: style!.letterSpacing,
      wordSpacing: style!.wordSpacing,
      height: style!.height,
      locale: style!.locale,
      textBaseline: style!.textBaseline,
      decorationColor: style!.decorationColor,
      decoration: style!.decoration,
      decorationStyle: style!.decorationStyle,
      decorationThickness: style!.decorationThickness,
      shadows: style!.shadows,
    );

    final paragraphStyle = ui.ParagraphStyle(textDirection: TextDirection.ltr);
    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(text);

    final paragraph = paragraphBuilder.build();
    paragraph.layout(ui.ParagraphConstraints(width: 100));

    final height = barStyle!.barHeight;
    final padding = barStyle!.paddingBeetwen;
    final minWidth = paragraph.minIntrinsicWidth;
    final doubleHeight = height * 2;
    final offset = Offset(
      width! - (minWidth / 2),
      -(padding * 2) - doubleHeight,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          offset.dx - doubleHeight,
          offset.dy - height,
          minWidth + height * 4,
          paragraph.height + doubleHeight,
        ),
        barStyle!.borderRadius.topLeft,
      ),
      Paint()..color = barStyle!.backgroundColor,
    );
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRepaint(_TextPositionPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_TextPositionPainter oldDelegate) => false;
}
