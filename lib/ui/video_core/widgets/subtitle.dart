import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class VideoCoreActiveSubtitleText extends StatelessWidget {
  const VideoCoreActiveSubtitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final style = query.videoStyle(context).subtitleStyle;
    final subtitle = query.video(context, listen: true).activeCaptionData;

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.padding,
        child: AutoSizeText(
          subtitle != null ? subtitle.text : "",
          style: style.style,
          textAlign: style.textAlign,
        ),
      ),
    );
  }
}
