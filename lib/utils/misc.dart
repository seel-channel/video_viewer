import 'package:flutter/material.dart';
import 'package:video_viewer/utils/styles.dart';

String secondsFormatter(int seconds) {
  final Duration duration = Duration(seconds: seconds);
  final int hours = duration.inHours;
  final String formatter = [if (hours != 0) hours, duration.inMinutes, seconds]
      .map((seg) => seg.abs().remainder(60).toString().padLeft(2, '0'))
      .join(':');
  return seconds < 0 ? "-$formatter" : formatter;
}

VideoViewerStyle mergeVideoViewerStyle({
  VideoViewerStyle style,
  TextStyle textStyle,
  ProgressBarStyle progressBarStyle,
  PlayAndPauseWidgetStyle playAndPauseStyle,
  SettingsMenuStyle settingsStyle,
  ForwardAndRewindStyle forwardAndRewindStyle,
  VolumeBarStyle volumeBarStyle,
}) {
  return VideoViewerStyle(
    thumbnail: null,
    header: style.header,
    loading: style.loading,
    buffering: style.buffering,
    textStyle: textStyle ?? style.textStyle,
    settingsStyle: settingsStyle ?? style.settingsStyle,
    volumeBarStyle: volumeBarStyle ?? style.volumeBarStyle,
    progressBarStyle: progressBarStyle ?? style.progressBarStyle,
    playAndPauseStyle: playAndPauseStyle ?? style.playAndPauseStyle,
    forwardAndRewindStyle: forwardAndRewindStyle ?? style.forwardAndRewindStyle,
  );
}
