import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class CustomOpacityTransition extends StatelessWidget {
  const CustomOpacityTransition({
    Key? key,
    required this.visible,
    required this.child,
  }) : super(key: key);

  final bool visible;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context).style;

    return OpacityTransition(
      curve: Curves.ease,
      duration: style.transitions,
      visible: visible,
      child: child,
    );
  }
}

class CustomSwipeTransition extends StatelessWidget {
  const CustomSwipeTransition({
    Key? key,
    required this.visible,
    required this.child,
    this.axisAlignment = -1.0,
    this.axis = Axis.vertical,
  }) : super(key: key);

  final bool visible;
  final Widget child;
  final double axisAlignment;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context).style;

    return SwipeTransition(
      curve: Curves.ease,
      axis: axis,
      duration: style.transitions,
      axisAlignment: axisAlignment,
      visible: visible,
      child: child,
    );
  }
}
