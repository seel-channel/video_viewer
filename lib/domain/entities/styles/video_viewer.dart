import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/styles/forward_and_rewind.dart';
import 'package:video_viewer/domain/entities/styles/play_and_pause.dart';
import 'package:video_viewer/domain/entities/styles/settings_menu.dart';
import 'package:video_viewer/domain/entities/styles/progress_bar.dart';
import 'package:video_viewer/domain/entities/styles/volume_bar.dart';
import 'package:video_viewer/domain/entities/styles/subtitle.dart';

export 'package:video_viewer/domain/entities/styles/forward_and_rewind.dart';
export 'package:video_viewer/domain/entities/styles/play_and_pause.dart';
export 'package:video_viewer/domain/entities/styles/settings_menu.dart';
export 'package:video_viewer/domain/entities/styles/progress_bar.dart';
export 'package:video_viewer/domain/entities/styles/volume_bar.dart';
export 'package:video_viewer/domain/entities/styles/subtitle.dart';

class VideoViewerStyle {
  /// It is the main class of VideoViewer styles, in this class you can almost
  /// all styles and elements of the VideoViewer
  VideoViewerStyle({
    ProgressBarStyle progressBarStyle,
    PlayAndPauseWidgetStyle playAndPauseStyle,
    SettingsMenuStyle settingsStyle,
    ForwardAndRewindStyle forwardAndRewindStyle,
    VolumeBarStyle volumeBarStyle,
    SubtitleStyle subtitleStyle,
    this.header,
    this.thumbnail,
    Widget loading,
    Widget buffering,
    TextStyle textStyle,
    this.transitions = const Duration(milliseconds: 400),
  })  : this.loading = loading ??
            Center(
              child: CircularProgressIndicator(strokeWidth: 1.6),
            ),
        this.buffering = buffering ??
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        this.subtitleStyle = subtitleStyle ?? SubtitleStyle(),
        this.settingsStyle = settingsStyle ?? SettingsMenuStyle(),
        this.progressBarStyle = progressBarStyle ?? ProgressBarStyle(),
        this.volumeBarStyle = volumeBarStyle ?? VolumeBarStyle(),
        this.forwardAndRewindStyle =
            forwardAndRewindStyle ?? ForwardAndRewindStyle(),
        this.playAndPauseStyle = playAndPauseStyle ?? PlayAndPauseWidgetStyle(),
        this.textStyle = textStyle ??
            TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

  /// These are the styles of the settings sales, here you will change the icons and
  /// the language of the texts
  final SettingsMenuStyle settingsStyle;

  /// Only Android Support, this style is for Volume controller but at
  /// only having android support will only show for that platform.
  final VolumeBarStyle volumeBarStyle;

  /// It is the style that will have all the icons and elements of the progress bar
  final ProgressBarStyle progressBarStyle;

  final SubtitleStyle subtitleStyle;

  /// With this argument change the icons that appear when double-tapping,
  /// also the style of the container that indicates when the video will be rewind or forward.
  final ForwardAndRewindStyle forwardAndRewindStyle;

  /// With this argument you will change the play and pause icons, also the style
  /// of the circle that appears behind. Note: The play and pause icons are
  /// the same ones that appear in the progress bar
  final PlayAndPauseWidgetStyle playAndPauseStyle;

  /// It is a thumbnail that appears when the video is loaded for the first time, once
  /// given play or pressing on it will disappear.
  final Widget thumbnail;

  /// It is the widget header shows on the top when you tap the video viewer and it shows the progress bar
  final Widget header;

  /// It is the NotNull-Widget that appears when the video is loading.
  ///
  ///DEFAULT:
  ///```dart
  ///  Center(child: CircularProgressIndicator(strokeWidth: 1.6));
  ///```
  final Widget loading;

  /// It is the NotNull-Widget that appears when the video keeps loading the content
  ///
  ///DEFAULT:
  ///```dart
  ///  Center(child: CircularProgressIndicator(
  ///     strokeWidth: 1.6,
  ///     valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
  ///  );
  ///```
  final Widget buffering;

  /// It is a quantity in milliseconds. It is the time it takes to take place
  /// all transitions of the VideoViewer ui,
  final Duration transitions;

  /// It is the design of the text that will be used in all the texts of the VideoViwer
  ///
  ///DEFAULT:
  ///```dart
  ///  TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
  ///```
  final TextStyle textStyle;

  VideoViewerStyle copywith({
    Widget thumbnail,
    Widget header,
    Widget loading,
    Widget buffering,
    TextStyle textStyle,
    VolumeBarStyle volumeBarStyle,
    ProgressBarStyle progressBarStyle,
    SettingsMenuStyle settingsStyle,
    PlayAndPauseWidgetStyle playAndPauseStyle,
    ForwardAndRewindStyle forwardAndRewindStyle,
  }) {
    return VideoViewerStyle(
      header: header ?? this.header,
      loading: loading ?? this.loading,
      thumbnail: thumbnail,
      buffering: buffering ?? this.buffering,
      textStyle: textStyle ?? this.textStyle,
      settingsStyle: settingsStyle ?? this.settingsStyle,
      volumeBarStyle: volumeBarStyle ?? this.volumeBarStyle,
      progressBarStyle: progressBarStyle ?? this.progressBarStyle,
      playAndPauseStyle: playAndPauseStyle ?? this.playAndPauseStyle,
      forwardAndRewindStyle:
          forwardAndRewindStyle ?? this.forwardAndRewindStyle,
    );
  }
}
