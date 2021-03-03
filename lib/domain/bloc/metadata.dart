import 'package:flutter/material.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/domain/entities/styles/video_viewer.dart';

class VideoViewerMetadata {
  VideoViewerMetadata({
    @required this.style,
    @required this.rewindAmount,
    @required this.forwardAmount,
    @required this.defaultAspectRatio,
    @required this.onFullscreenFixLandscape,
    @required this.language,
  });

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool onFullscreenFixLandscape;

  ///It's the custom language can you set to the VideoViewer.
  ///
  ///**EXAMPLE:** SETTING THE SPANISH LANGUAGE TO THE VIDEOVIEWER
  ///```dart
  /// //WAY 1
  /// language: VideoViewerLanguage.es
  /// //WAY 2
  /// language: VideoViewerLanguage(quality: "Calidad", speed: "Velocidad", ...)
  /// //WAY 3
  /// language: VideoViewerLanguage.fromString("es")
  /// ```
  final VideoViewerLanguage language;

  /// It is an argument where you can change the design of almost the entire VideoViewer
  final VideoViewerStyle style;
}
