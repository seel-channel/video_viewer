import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

class VideoViewerStyle {
  VideoViewerStyle({
    VideoProgressBarStyle progressBarStyle,
    PlayAndPauseWidgetStyle playAndPauseStyle,
    SettingsStyle settingsStyle,
    ForwardAndRewindStyle forwardAndRewindStyle,
    VideoVolumeBarStyle volumeBarStyle,
    this.thumbnail,
    Widget loading,
    Widget buffering,
    TextStyle textStyle,
    this.transitions = 400,
    this.inLandscapeEnlargeTheTextBy = 2,
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
        this.settingsStyle = settingsStyle ?? SettingsStyle(),
        this.progressBarStyle = progressBarStyle ?? VideoProgressBarStyle(),
        this.volumeBarStyle = volumeBarStyle ?? VideoVolumeBarStyle(),
        this.forwardAndRewindStyle =
            forwardAndRewindStyle ?? ForwardAndRewindStyle(),
        this.playAndPauseStyle = playAndPauseStyle ?? PlayAndPauseWidgetStyle(),
        this.textStyle = textStyle ??
            TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold);

  final SettingsStyle settingsStyle;
  final VideoVolumeBarStyle volumeBarStyle;
  final VideoProgressBarStyle progressBarStyle;
  final ForwardAndRewindStyle forwardAndRewindStyle;
  final PlayAndPauseWidgetStyle playAndPauseStyle;
  final Widget thumbnail;
  final Widget loading;
  final Widget buffering;
  final int transitions;

  final TextStyle textStyle;
  final double inLandscapeEnlargeTheTextBy;
}

class VideoProgressBarStyle {
  VideoProgressBarStyle({
    Widget fullScreen,
    Widget fullScreenExit,
    this.height = 5,
    this.dotColor = Colors.white,
    Color activeColor,
    Color bufferedColor,
    Color backgroundColor,
    this.margin = EdgeInsets.zero,
    BorderRadiusGeometry borderRadius,
    this.paddingBeetwen = 12,
  })  : this.activeColor = activeColor ?? Color(0xFF295acc),
        this.bufferedColor = bufferedColor ?? Colors.white.withOpacity(0.3),
        this.backgroundColor = backgroundColor ?? Colors.white.withOpacity(0.2),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5),
        this.fullScreen = fullScreen ??
            Icon(
              Icons.fullscreen_outlined,
              color: Colors.white,
              size: 24,
            ),
        this.fullScreenExit = fullScreenExit ??
            Icon(
              Icons.fullscreen_exit_outlined,
              color: Colors.white,
              size: 24,
            );

  final double height;
  final double paddingBeetwen;
  final Color dotColor;
  final Color activeColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final Widget fullScreen;
  final Widget fullScreenExit;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
}

class PlayAndPauseWidgetStyle {
  PlayAndPauseWidgetStyle({
    Widget play,
    Widget pause,
    Color background,
    this.circleBorder,
    this.circleSize = 40,
  })  : this.background = background ?? Color(0xFF295acc).withOpacity(0.8),
        this.play = play ?? Icon(Icons.play_arrow, color: Colors.white),
        this.pause = pause ?? Icon(Icons.pause, color: Colors.white);

  final Widget play;
  final Widget pause;
  final Color background;
  final double circleSize;
  final BoxBorder circleBorder;

  Widget _base(Widget child, Color background) {
    return Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: background,
        border: circleBorder,
      ),
      child: child,
    );
  }

  Widget get playWidget => _base(play, background);
  Widget get pauseWidget => _base(pause, background);
}

class SettingsStyle {
  SettingsStyle({
    Widget settings,
    Widget speed,
    Widget selected,
    Widget chevron,
    this.paddingBetween = 24,
  })  : this.settings = settings ??
            Icon(
              Icons.settings_outlined,
              color: Colors.white,
              size: 20,
            ),
        this.speed = speed ?? Icon(Icons.speed, color: Colors.white, size: 20),
        this.selected =
            selected ?? Icon(Icons.done, color: Colors.white, size: 20),
        this.chevron = chevron ?? Icon(Icons.chevron_left, color: Colors.white);

  final Widget speed;
  final Widget chevron;
  final Widget selected;
  final Widget settings;
  final double paddingBetween;
}

class ForwardAndRewindStyle {
  ForwardAndRewindStyle({
    Widget rewind,
    Widget forward,
    Color backgroundColor,
    EdgeInsetsGeometry padding,
    BorderRadiusGeometry borderRadius,
  })  : this.padding = padding ?? Margin.all(5),
        this.backgroundColor =
            backgroundColor ?? Colors.black.withOpacity(0.25),
        this.borderRadius = borderRadius ?? EdgeRadius.vertical(bottom: 5),
        this.rewind = rewind ?? Icon(Icons.fast_rewind, color: Colors.white),
        this.forward = forward ?? Icon(Icons.fast_forward, color: Colors.white);

  final Widget rewind;
  final Widget forward;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
}

class VideoVolumeBarStyle {
  VideoVolumeBarStyle({
    this.width = 5,
    this.height = 120,
    this.color = Colors.white,
    Color backgroundColor,
    EdgeInsetsGeometry padding,
    BorderRadiusGeometry borderRadius,
    this.alignment = Alignment.centerLeft,
  })  : this.padding = padding ?? Margin.left(20),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5),
        this.backgroundColor = backgroundColor ?? Colors.white.withOpacity(0.2);

  final double width, height;
  final Color color;
  final Color backgroundColor;
  final Alignment alignment;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
}
