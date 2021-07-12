import 'package:flutter/cupertino.dart';

class VideoViewerAd {
  VideoViewerAd({
    required this.child,
    required this.durationToSkip,
    this.durationToStart,
    this.fractionToStart,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoViewerAd &&
        other.child == child &&
        other.durationToSkip == durationToSkip &&
        other.durationToStart == durationToStart &&
        other.fractionToStart == fractionToStart;
  }

  @override
  int get hashCode {
    return child.hashCode ^
        durationToSkip.hashCode ^
        durationToStart.hashCode ^
        fractionToStart.hashCode;
  }

  @override
  String toString() {
    return 'VideoViewerAd(child: $child, durationToSkip: $durationToSkip, durationToStart: $durationToStart, fractionToStart: $fractionToStart)';
  }

  VideoViewerAd copyWith({
    Widget? child,
    Duration? durationToSkip,
    Duration? durationToStart,
    double? fractionToStart,
  }) {
    return VideoViewerAd(
      child: child ?? this.child,
      durationToSkip: durationToSkip ?? this.durationToSkip,
      durationToStart: durationToStart ?? this.durationToStart,
      fractionToStart: fractionToStart ?? this.fractionToStart,
    );
  }
}
