import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreForwardAndRewind extends StatelessWidget {
  const VideoCoreForwardAndRewind({
    Key key,
    @required this.showRewind,
    @required this.showForward,
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
    Key key,
    @required this.rewind,
    @required this.forward,
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

class VideoCoreForwardAndRewindTextAlert extends StatelessWidget {
  const VideoCoreForwardAndRewindTextAlert({
    Key key,
    this.amount,
  }) : super(key: key);

  final int amount;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context);
    final forwardStyle = style.forwardAndRewindStyle;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: forwardStyle.padding,
        decoration: BoxDecoration(
          color: forwardStyle.backgroundColor,
          borderRadius: forwardStyle.borderRadius,
        ),
        child: Text(
          query.durationFormatter(Duration(seconds: amount)),
          style: style.textStyle,
        ),
      ),
    );
  }
}
