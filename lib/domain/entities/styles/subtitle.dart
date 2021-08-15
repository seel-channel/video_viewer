import 'package:flutter/material.dart';

class SubtitleStyle {
  final TextStyle style;
  final TextAlign textAlign;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;

  SubtitleStyle({
    TextStyle? style,
    this.alignment = Alignment.bottomCenter,
    this.textAlign = TextAlign.center,
    this.padding = const EdgeInsets.all(20.0),
  }) : this.style = style ??
            TextStyle(
              color: Colors.white,
              fontSize: 16,
              backgroundColor: Colors.black,
              height: 1.2,
            );
}
