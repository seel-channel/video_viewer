import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_viewer/utils/language.dart';
import 'package:video_viewer/utils/sources.dart';
import 'package:video_viewer/utils/styles.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoMetadata extends ChangeNotifier {
  VideoMetadata({
    @required this.source,
    VideoViewerStyle style,
    this.activedSource,
    this.looping,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.onFullscreenFixLandscape,
    this.language = VideoViewerLanguage.en,
    this.settingsMenuItems,
  }) : this.style = style ?? VideoViewerStyle();

  final String activedSource;
  final bool looping;
  final int rewindAmount, forwardAmount;
  final bool onFullscreenFixLandscape;
  final double defaultAspectRatio;
  final VideoViewerStyle style;
  final VideoViewerLanguage language;
  final Map<String, VideoSource> source;
  final List<SettingsMenuItem> settingsMenuItems;

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  set isFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }
}

VideoViewerStyle getVideoStyle(BuildContext context) {
  return Provider.of<VideoMetadata>(context).style;
}

VideoPlayerController getVideoController(BuildContext context) {
  return Provider.of<VideoPlayerController>(context);
}

bool getVideoFullScreen(BuildContext context) {
  return Provider.of<VideoMetadata>(context).isFullScreen;
}

void setVideoFullScreen(BuildContext context, bool value) {
  Provider.of<VideoMetadata>(context, listen: false).isFullScreen = value;
}
