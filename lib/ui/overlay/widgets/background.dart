import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground({
    Key? key,
    this.child,
    this.begin = Alignment.topCenter,
    this.end = Alignment.bottomCenter,
  }) : super(key: key);

  final Widget? child;
  final Alignment begin;
  final Alignment end;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context, listen: true).style;
    List<Color> colors = [
      Colors.transparent,
      style.progressBarStyle.backgroundColor,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(end: end, begin: begin, colors: colors),
      ),
      child: child,
    );
  }
}
