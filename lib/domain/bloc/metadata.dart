import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoMetadata extends ChangeNotifier {
  VideoMetadata({
    @required this.source,
    VideoViewerStyle style,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.onFullscreenFixLandscape,
    this.language = VideoViewerLanguage.en,
    this.settingsMenuItems,
  }) : this._style = style ?? VideoViewerStyle();

  final int rewindAmount, forwardAmount;
  final bool onFullscreenFixLandscape;
  final double defaultAspectRatio;
  final VideoViewerLanguage language;
  final Map<String, VideoSource> source;
  final List<SettingsMenuItem> settingsMenuItems;

  VideoViewerStyle _style;
  VideoViewerStyle get style => _style;
  set style(VideoViewerStyle style) {
    _style = style;
    notifyListeners();
  }
}
