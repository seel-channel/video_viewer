import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/styles/chat.dart';
import 'package:video_viewer/domain/entities/styles/forward_and_rewind.dart';
import 'package:video_viewer/domain/entities/styles/play_and_pause.dart';
import 'package:video_viewer/domain/entities/styles/progress_bar.dart';
import 'package:video_viewer/domain/entities/styles/settings_menu.dart';
import 'package:video_viewer/domain/entities/styles/subtitle.dart';
import 'package:video_viewer/domain/entities/styles/volume_bar.dart';

export 'package:video_viewer/domain/entities/styles/bar.dart';
export 'package:video_viewer/domain/entities/styles/chat.dart';
export 'package:video_viewer/domain/entities/styles/forward_and_rewind.dart';
export 'package:video_viewer/domain/entities/styles/play_and_pause.dart';
export 'package:video_viewer/domain/entities/styles/progress_bar.dart';
export 'package:video_viewer/domain/entities/styles/settings_menu.dart';
export 'package:video_viewer/domain/entities/styles/subtitle.dart';
export 'package:video_viewer/domain/entities/styles/volume_bar.dart';

class VideoViewerStyle {
  /// It is the main class of VideoViewer styles, in this class you can almost
  /// all styles and elements of the VideoViewer
  VideoViewerStyle({
    ProgressBarStyle? progressBarStyle,
    PlayAndPauseWidgetStyle? playAndPauseStyle,
    SettingsMenuStyle? settingsStyle,
    ForwardAndRewindStyle? forwardAndRewindStyle,
    VolumeBarStyle? volumeBarStyle,
    SubtitleStyle? subtitleStyle,
    VideoViewerChatStyle? chatStyle,
    Widget? loading,
    Widget? buffering,
    TextStyle? textStyle,
    this.thumbnail,
    this.header,
    this.transitions = const Duration(milliseconds: 400),
    this.skipAdBuilder,
    this.skipAdAlignment = Alignment.bottomRight,
  })  : loading = loading ??
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        buffering = buffering ??
            Center(
              child: CircularProgressIndicator(
                strokeWidth: 1.6,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
        chatStyle = chatStyle ?? const VideoViewerChatStyle(),
        subtitleStyle = subtitleStyle ?? SubtitleStyle(),
        settingsStyle = settingsStyle ?? SettingsMenuStyle(),
        progressBarStyle = progressBarStyle ?? ProgressBarStyle(),
        volumeBarStyle = volumeBarStyle ?? VolumeBarStyle(),
        forwardAndRewindStyle =
            forwardAndRewindStyle ?? ForwardAndRewindStyle(),
        playAndPauseStyle = playAndPauseStyle ?? PlayAndPauseWidgetStyle(),
        textStyle = textStyle ??
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
  final Widget? thumbnail;

  /// It is the widget header shows on the top when you tap the video viewer and it shows the progress bar
  final Widget? header;

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

  final Widget Function(Duration)? skipAdBuilder;

  final Alignment skipAdAlignment;

  final VideoViewerChatStyle chatStyle;

  VideoViewerStyle copyWith({
    SettingsMenuStyle? settingsStyle,
    VolumeBarStyle? volumeBarStyle,
    ProgressBarStyle? progressBarStyle,
    SubtitleStyle? subtitleStyle,
    ForwardAndRewindStyle? forwardAndRewindStyle,
    PlayAndPauseWidgetStyle? playAndPauseStyle,
    Widget? thumbnail,
    Widget? header,
    Widget? loading,
    Widget? buffering,
    Duration? transitions,
    TextStyle? textStyle,
    Widget Function(Duration)? skipAdBuilder,
    Alignment? skipAdAlignment,
    VideoViewerChatStyle? chatStyle,
  }) {
    return VideoViewerStyle(
      settingsStyle: settingsStyle ?? this.settingsStyle,
      volumeBarStyle: volumeBarStyle ?? this.volumeBarStyle,
      progressBarStyle: progressBarStyle ?? this.progressBarStyle,
      subtitleStyle: subtitleStyle ?? this.subtitleStyle,
      forwardAndRewindStyle:
          forwardAndRewindStyle ?? this.forwardAndRewindStyle,
      playAndPauseStyle: playAndPauseStyle ?? this.playAndPauseStyle,
      thumbnail: thumbnail ?? this.thumbnail,
      header: header ?? this.header,
      loading: loading ?? this.loading,
      buffering: buffering ?? this.buffering,
      transitions: transitions ?? this.transitions,
      textStyle: textStyle ?? this.textStyle,
      skipAdBuilder: skipAdBuilder ?? this.skipAdBuilder,
      skipAdAlignment: skipAdAlignment ?? this.skipAdAlignment,
      chatStyle: chatStyle ?? this.chatStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoViewerStyle &&
        other.settingsStyle == settingsStyle &&
        other.volumeBarStyle == volumeBarStyle &&
        other.progressBarStyle == progressBarStyle &&
        other.subtitleStyle == subtitleStyle &&
        other.forwardAndRewindStyle == forwardAndRewindStyle &&
        other.playAndPauseStyle == playAndPauseStyle &&
        other.thumbnail == thumbnail &&
        other.header == header &&
        other.loading == loading &&
        other.buffering == buffering &&
        other.transitions == transitions &&
        other.textStyle == textStyle &&
        other.skipAdBuilder == skipAdBuilder &&
        other.skipAdAlignment == skipAdAlignment &&
        other.chatStyle == chatStyle;
  }

  @override
  int get hashCode {
    return settingsStyle.hashCode ^
        volumeBarStyle.hashCode ^
        progressBarStyle.hashCode ^
        subtitleStyle.hashCode ^
        forwardAndRewindStyle.hashCode ^
        playAndPauseStyle.hashCode ^
        thumbnail.hashCode ^
        header.hashCode ^
        loading.hashCode ^
        buffering.hashCode ^
        transitions.hashCode ^
        textStyle.hashCode ^
        skipAdBuilder.hashCode ^
        skipAdAlignment.hashCode ^
        chatStyle.hashCode;
  }
}
