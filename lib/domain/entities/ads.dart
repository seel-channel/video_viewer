import 'package:flutter/cupertino.dart';

class VideoViewerAd {
  VideoViewerAd({
    required this.durationToSkip,
    required this.child,
    this.durationToStart,
    this.fractionToStart,
    this.durationToEnd = const Duration(seconds: 8),
  })  : assert(
          (fractionToStart != null && durationToStart == null) ||
              (fractionToStart == null && durationToStart != null),
          "One of the 2 arguments must be assigned.",
        ),
        assert((fractionToStart ?? 0.0) >= 0 && (fractionToStart ?? 1.0) <= 1.0,
            "fractionToStart must be greater or equal than 0.0 and lower or equal than 1.0");

  /// It is the ad to show
  final Widget child;

  /// It is the duration to wait to skip the ad
  final Duration durationToSkip;

  /// It is the position of the video when it will show the ad
  final Duration? durationToStart;

  /// It is used when you want to show an ad in the porcetange of the video. For example, the half of the video (0.5), a quarter of the video (0.25)
  final double? fractionToStart;

  /// It is a threshold that serves to create a range where the video will be shown, that is, if your video starts on second 35 and the duration to end is 8 seconds, then in a range from second 35 to second 43 it will be able to show the ad.
  final Duration durationToEnd;

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
}
