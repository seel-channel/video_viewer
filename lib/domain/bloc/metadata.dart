import 'package:flutter/material.dart';
import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/language.dart';

class VideoMetadata {
  VideoMetadata({
    @required this.source,
    @required VideoViewerStyle style,
    @required this.rewindAmount,
    @required this.forwardAmount,
    @required this.defaultAspectRatio,
    @required this.onFullscreenFixLandscape,
    @required this.language,
    @required this.settingsMenuItems,
  }) : this.style = style ?? VideoViewerStyle();

  final int rewindAmount, forwardAmount;
  final bool onFullscreenFixLandscape;
  final double defaultAspectRatio;
  final VideoViewerLanguage language;
  final Map<String, VideoSource> source;
  final List<SettingsMenuItem> settingsMenuItems;
  VideoViewerStyle style;
}
