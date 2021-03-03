import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

class RewindAndForwardLayout extends StatelessWidget {
  const RewindAndForwardLayout({
    Key key,
    @required this.rewind,
    @required this.forward,
  }) : super(key: key);

  final Widget rewind;
  final Widget forward;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: context.media.width / 2),
      Expanded(child: forward),
    ]);
  }
}
