import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/provider.dart';

class PlayAndPause extends StatelessWidget {
  const PlayAndPause({
    Key key,
    @required this.onTap,
    this.padding,
  }) : super(key: key);

  final EdgeInsetsGeometry padding;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final query = ProviderQuery();
    final style = query.getVideoStyle(context).playAndPauseStyle;
    final controller = query.getVideoController(context);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: padding,
        child: !controller.value.isPlaying ? style.play : style.pause,
      ),
    );
  }
}
