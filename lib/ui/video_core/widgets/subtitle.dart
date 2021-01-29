import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class ActiveSubtitleText extends StatelessWidget {
  const ActiveSubtitleText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final subtitle = query.video(context, listen: true).activeSubtitle;

    return Text(
      subtitle.text ?? "",
      style: style.style,
      textAlign: style.align,
    );
  }
}
