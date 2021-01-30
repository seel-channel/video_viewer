import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class ActiveSubtitleText extends StatelessWidget {
  const ActiveSubtitleText({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final subtitle = query.video(context, listen: true).activeSubtitle;

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.padding,
        child: Text(
          subtitle != null ? subtitle.text : "",
          style: style.style,
          textAlign: style.textAlign,
        ),
      ),
    );
  }
}
