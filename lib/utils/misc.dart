import 'package:flutter/material.dart';
import 'package:video_viewer/utils/styles.dart';

String secondsFormatter(int seconds) {
  int secondsBool = seconds;
  int minutes = (seconds.abs() / 60).floor();
  seconds = (seconds.abs() - (minutes * 60));
  int hours = (minutes.abs() / 60).floor();
  String minutesStr = minutes < 10 ? "0$minutes" : "$minutes";
  String secondsStr = seconds < 10 ? "0$seconds" : "$seconds";
  String hoursStr = hours == 0
      ? ""
      : hours < 10
          ? "0$hours:"
          : "$hours:";
  return secondsBool < 0
      ? "-$hoursStr$minutesStr:$secondsStr"
      : "$hoursStr$minutesStr:$secondsStr";
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
