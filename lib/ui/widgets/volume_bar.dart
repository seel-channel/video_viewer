import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class VideoVolumeBar extends StatelessWidget {
  const VideoVolumeBar({Key key, this.progress}) : super(key: key);

  final double progress;

  @override
  Widget build(BuildContext context) {
    final style =
        VideoQuery().videoMetadata(context, listen: true).style.volumeBarStyle;

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
