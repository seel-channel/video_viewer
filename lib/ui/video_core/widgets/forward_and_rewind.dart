import 'package:auto_size_text/auto_size_text.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreForwardAndRewind extends StatelessWidget {
  const VideoCoreForwardAndRewind({
    Key? key,
    required this.showRewind,
    required this.showForward,
  }) : super(key: key);

  final bool showRewind, showForward;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context);
    return VideoCoreForwardAndRewindLayout(
      rewind: CustomOpacityTransition(
        visible: showRewind,
        child: Center(
          child: style.forwardAndRewindStyle.rewind,
        ),
      ),
      forward: CustomOpacityTransition(
        visible: showForward,
        child: Center(
          child: style.forwardAndRewindStyle.forward,
        ),
      ),
    );
  }
}

class VideoCoreForwardAndRewindLayout extends StatelessWidget {
  const VideoCoreForwardAndRewindLayout({
    Key? key,
    required this.rewind,
    required this.forward,
  }) : super(key: key);

  final Widget rewind;
  final Widget forward;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: context.media.width / 2),
      Expanded(child: forward),
    ]);
  }
}

class VideoCoreForwardAndRewindAlert extends StatelessWidget {
  const VideoCoreForwardAndRewindAlert({
    Key? key,
    required this.seconds,
    required this.position,
  }) : super(key: key);

  final int seconds;
  final Duration position;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context).video!;
    final style = query.videoStyle(context);
    final forwardStyle = style.forwardAndRewindStyle;

    final duration = video.value.duration;
    final height = forwardStyle.bar.height;
    final width = forwardStyle.bar.width;

    return Center(
      child: Container(
        padding: forwardStyle.padding,
        decoration: BoxDecoration(
          color: forwardStyle.backgroundColor,
          borderRadius: forwardStyle.borderRadius,
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          AutoSizeText(
            query.durationFormatter(Duration(seconds: seconds)),
            style: style.textStyle,
          ),
          ClipRRect(
            borderRadius: forwardStyle.borderRadius,
            child: SizedBox(
              height: height,
              width: width,
              child: Stack(children: [
                Container(color: forwardStyle.bar.background),
                Container(
                  height: height,
                  width: ((position.inSeconds + seconds) / duration.inSeconds) *
                      width,
                  color: forwardStyle.bar.color,
                ),
                Container(
                  color: forwardStyle.bar.identifier,
                  width: 1,
                  margin: Margin.left(
                    (position.inSeconds / duration.inSeconds) * width,
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
