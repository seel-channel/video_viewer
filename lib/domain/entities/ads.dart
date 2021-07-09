import 'package:flutter/cupertino.dart';

class VideoViewerAd {
  VideoViewerAd({
    this.durationToStart,
    this.fractionToStart,
    required this.durationToSkip,
    required this.child,
  })  : assert(
          (fractionToStart != null && durationToStart == null) ||
              (fractionToStart == null && durationToStart != null),
          "One of the 2 arguments must be assigned.",
        ),
        assert((fractionToStart ?? 0.0) >= 0 && (fractionToStart ?? 1.0) <= 1.0,
            "fractionToStart must be greater or equal than 0.0 and lower or equal than 1.0");

  final Widget child;
  final Duration durationToSkip;
  final Duration? durationToStart;
  final double? fractionToStart;
}
