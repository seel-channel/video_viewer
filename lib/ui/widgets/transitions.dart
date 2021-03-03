import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

class CustomOpacityTransition extends StatelessWidget {
  const CustomOpacityTransition({
    Key key,
    this.visible,
    this.child,
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
    Key key,
    this.visible,
    this.child,
    this.direction,
  }) : super(key: key);

  final bool visible;
  final Widget child;
  final SwipeDirection direction;

  @override
  Widget build(BuildContext context) {
    final style = VideoQuery().videoMetadata(context).style;

    return SwipeTransition(
      curve: Curves.ease,
      duration: style.transitions,
      direction: direction,
      visible: visible,
      child: child,
    );
  }
}
