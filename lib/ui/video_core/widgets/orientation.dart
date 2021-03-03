import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class VideoCoreOrientation extends StatelessWidget {
  const VideoCoreOrientation({Key key, this.builder}) : super(key: key);

  final Widget Function(bool) builder;

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, Orientation orientation) {
      final video = VideoQuery().video(context, listen: false);
      return builder(
        video.isFullScreen && orientation == Orientation.landscape,
      );
    });
  }
}
