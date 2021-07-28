import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class VideoCoreVolumeBar extends StatelessWidget {
  const VideoCoreVolumeBar({
    Key? key,
    required this.visible,
    required this.progress,
  }) : super(key: key);

  final bool visible;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;
    final double axisAlignment;

    if (style.alignment == Alignment.topRight ||
        style.alignment == Alignment.centerRight ||
        style.alignment == Alignment.bottomRight)
      axisAlignment = -1.0;
    else
      axisAlignment = 1.0;

    return CustomSwipeTransition(
      visible: visible,
      axisAlignment: axisAlignment,
      axis: Axis.horizontal,
      child: _VolumeBar(progress: progress),
    );
  }
}

class _VolumeBar extends StatelessWidget {
  const _VolumeBar({Key? key, this.progress}) : super(key: key);

  final double? progress;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoStyle(context).volumeBarStyle;

    return Align(
      alignment: style.alignment,
      child: Padding(
        padding: style.margin,
        child: ClipRRect(
          borderRadius: style.bar.borderRadius,
          child: Container(
            height: style.bar.height,
            width: style.bar.width,
            child: Stack(
              alignment: AlignmentDirectional.bottomCenter,
              children: [
                Container(color: style.bar.background),
                Container(
                  height: progress! * style.bar.height,
                  color: style.bar.color,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
