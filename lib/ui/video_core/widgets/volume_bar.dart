import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreVolumeBar extends StatelessWidget {
  const VideoCoreVolumeBar({
    Key key,
    @required this.visible,
    @required this.progress,
  }) : super(key: key);

  final bool visible;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;
    SwipeDirection direction;

    if (style.alignment == Alignment.topRight ||
        style.alignment == Alignment.centerRight ||
        style.alignment == Alignment.bottomRight)
      direction = SwipeDirection.fromRight;
    else
      direction = SwipeDirection.fromLeft;

    return CustomSwipeTransition(
      visible: visible,
      direction: direction,
      child: _VolumeBar(progress: progress),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({Key key, this.progress}) : super(key: key);

  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;

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
