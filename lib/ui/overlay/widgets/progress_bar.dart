import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:provider/provider.dart';
import 'package:cached_video_player/cached_video_player.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoProgressBar extends StatefulWidget {
  const VideoProgressBar({Key? key}) : super(key: key);

  @override
  _VideoProgressBarState createState() => _VideoProgressBarState();
}

class _VideoProgressBarState extends State<VideoProgressBar> {
  final ValueNotifier<Duration> _progressBarDraggingBuffer =
      ValueNotifier<Duration>(Duration.zero);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ListenableProvider(create: (_) => ValueNotifier<int>(1000)),
        ListenableProvider.value(value: _progressBarDraggingBuffer),
      ],
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

          final bar = style.bar;

          return ValueListenableBuilder(
            valueListenable: _progressBarDraggingBuffer,
            builder: (_, Duration value, ___) {
              final Duration draggingPosition =
                  controller.isDraggingProgressBar ? value : position;
              final double progressWidth =
                  (draggingPosition.inMilliseconds / duration.inMilliseconds) *
                      width;

              return _ProgressBarGesture(
                width: width,
                child: Padding(
                  padding: Margin.vertical(style.paddingBeetwen),
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      _ProgressBar(width: width, color: bar.background),
                      _ProgressBar(
                        color: bar.secondBackground,
                        width: (controller.maxBuffering.inMilliseconds /
                                duration.inMilliseconds) *
                            width,
                      ),
                      _ProgressBar(width: progressWidth, color: bar.color),
                      _DotIsDragging(width: width, dotPosition: progressWidth),
                      _Dot(width: width, dotPosition: progressWidth),
                      CustomOpacityTransition(
                        visible: controller.isDraggingProgressBar,
                        child: CustomPaint(
                          painter: _TextPositionPainter(
                            position: draggingPosition,
                            barStyle: style,
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
          );
        },
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
  final VideoQuery _query = VideoQuery();
  late VideoPlayerController _video;

  @override
  void initState() {
    _video = _query.video(context).video!;
    super.initState();
  }

  void _seekToRelativePosition(Offset local, [bool showText = false]) {
    final double localPos = local.dx / widget.width!;
    final Duration position = _video.value.duration * localPos;

    if (position >= Duration.zero && position <= _video.value.duration) {
      Provider.of<ValueNotifier<Duration>>(context, listen: false).value =
          position;
    }
  }

  Future<void> play() async {
    Provider.of<ValueNotifier<int>>(context, listen: false).value = 1000;
    await _query.video(context).video?.play();
  }

  Future<void> pause() async {
    Provider.of<ValueNotifier<int>>(context, listen: false).value = 0;
    await _query.video(context).video?.pause();
  }

  void _startDragging() {
    _query.video(context).isDraggingProgressBar = true;
  }

  Future<void> _endDragging() async {
    await _video.seekTo(
      Provider.of<ValueNotifier<Duration>>(context, listen: false).value,
    );
    _query.video(context).isDraggingProgressBar = false;
    if (_query.video(context).activeAd == null) await play();
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

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = VideoQuery().videoStyle(context).progressBarStyle;

    return AnimatedContainer(
      width: width,
      height: style.bar.height,
      duration: Duration(milliseconds: animation.value),
      alignment: Alignment.centerRight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: style.bar.borderRadius,
      ),
    );
  }
}

class _DotIsDragging extends StatelessWidget {
  const _DotIsDragging({
    Key? key,
    required this.width,
    required this.dotPosition,
  }) : super(key: key);

  final double dotPosition;
  final double width;

  @override
  Widget build(BuildContext context) {
    final VideoQuery _query = VideoQuery();
    final controller = _query.video(context, listen: true);
    final style = _query.videoStyle(context).progressBarStyle;

    final double dotWidth = style.bar.identifierWidth;

    return BooleanTween(
      animate: controller.isDraggingProgressBar &&
          (dotPosition > dotWidth) &&
          (dotPosition < width - dotWidth),
      tween: Tween<double>(begin: 0, end: 0.4),
      builder: (_, double value, __) => _Dot(
        width: width,
        dotPosition: dotPosition,
        opacity: value,
        multiplicator: 2,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    Key? key,
    required this.width,
    required this.dotPosition,
    this.opacity = 1,
    this.multiplicator = 1,
  }) : super(key: key);

  final double dotPosition;
  final int multiplicator;
  final double? width, opacity;

  @override
  Widget build(BuildContext context) {
    final VideoQuery query = VideoQuery();
    final animation = Provider.of<ValueNotifier<int>>(context);
    final style = query.videoStyle(context).progressBarStyle;

    final double dotSize = style.bar.identifierWidth;

    final double dotWidth = dotSize * 2;
    final double width = dotPosition < dotSize
        ? dotWidth
        : dotPosition + dotSize * multiplicator;

    return ValueListenableBuilder(
      valueListenable: animation,
      builder: (_, int value, __) {
        return AnimatedContainer(
          width: width,
          duration: Duration(milliseconds: value),
          alignment: Alignment.centerRight,
          child: Container(
            height: dotWidth * multiplicator,
            width: dotWidth * multiplicator,
            decoration: BoxDecoration(
              color: style.bar.identifier.withOpacity(opacity!),
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

  final ProgressBarStyle? barStyle;
  final Duration? position;
  final TextStyle? style;
  final double? width;

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

    final height = barStyle!.bar.height;
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
        barStyle!.bar.borderRadius.topLeft,
      ),
      Paint()..color = barStyle!.backgroundColor,
    );
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  bool shouldRebuildSemantics(_TextPositionPainter oldDelegate) => false;

  @override
  bool shouldRepaint(_TextPositionPainter oldDelegate) => false;
}
