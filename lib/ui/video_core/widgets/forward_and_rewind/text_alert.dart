import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class RewindAndForwardTextAlert extends StatelessWidget {
  const RewindAndForwardTextAlert({
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
          query.secondsFormatter(amount),
          style: style.textStyle,
        ),
      ),
    );
  }
}
