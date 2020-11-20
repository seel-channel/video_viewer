import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

class VideoViewerStyle {
  VideoViewerStyle({
    VideoVolumeBarStyle volumeBarStyle,
    VideoProgressBarStyle progressBarStyle,
    ForwardAndRewindStyle forwardAndRewindStyle,
    PlayAndPauseWidgetStyle playAndPauseStyle,
    this.thumbnail,
    Widget loading,
    Widget buffering,
    Widget rewind,
    Widget forward,
    Widget settings,
    Widget fullScreen,
    Widget fullScreenExit,
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
        this.rewind = rewind ?? Icon(Icons.fast_rewind, color: Colors.white),
        this.forward = forward ?? Icon(Icons.fast_forward, color: Colors.white),
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
            ),
        this.settings = settings ??
            Icon(
              Icons.settings,
              color: Colors.white,
              size: 20,
            ),
        this.progressBarStyle = progressBarStyle ?? VideoProgressBarStyle(),
        this.volumeBarStyle = volumeBarStyle ?? VideoVolumeBarStyle(),
        this.forwardAndRewindStyle =
            forwardAndRewindStyle ?? ForwardAndRewindStyle(),
        this.playAndPauseStyle = playAndPauseStyle ?? PlayAndPauseWidgetStyle();

  final VideoVolumeBarStyle volumeBarStyle;
  final VideoProgressBarStyle progressBarStyle;
  final ForwardAndRewindStyle forwardAndRewindStyle;
  final PlayAndPauseWidgetStyle playAndPauseStyle;
  final Widget thumbnail;
  final Widget loading;
  final Widget rewind;
  final Widget forward;
  final Widget settings;
  final Widget buffering;
  final Widget fullScreen;
  final Widget fullScreenExit;
}

class VideoProgressBarStyle {
  VideoProgressBarStyle({
    this.height = 5,
    this.dotColor = Colors.white,
    Color activeColor,
    Color bufferedColor,
    Color backgroundColor,
    TextStyle textStyle,
    this.margin = EdgeInsets.zero,
    BorderRadiusGeometry borderRadius,
    this.paddingBeetwen = 14,
  })  : this.activeColor = activeColor ?? Color(0xFF00b3ff),
        this.bufferedColor = bufferedColor ?? Colors.white.withOpacity(0.3),
        this.backgroundColor = backgroundColor ?? Colors.white.withOpacity(0.2),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5),
        this.textStyle =
            textStyle ?? TextStyle(color: Colors.white, fontSize: 14);

  final double height;
  final double paddingBeetwen;
  final Color dotColor;
  final Color activeColor;
  final Color bufferedColor;
  final Color backgroundColor;
  final TextStyle textStyle;
  final EdgeInsetsGeometry margin;
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

class ForwardAndRewindStyle {
  ForwardAndRewindStyle({
    TextStyle textStyle,
    Color backgroundColor,
    EdgeInsetsGeometry padding,
    BorderRadiusGeometry borderRadius,
  })  : this.padding = padding ?? Margin.all(5),
        this.backgroundColor =
            backgroundColor ?? Colors.black.withOpacity(0.25),
        this.textStyle =
            textStyle ?? TextStyle(color: Colors.white, fontSize: 14),
        this.borderRadius = borderRadius ?? EdgeRadius.vertical(bottom: 5);

  final TextStyle textStyle;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
}

class PlayAndPauseWidgetStyle {
  PlayAndPauseWidgetStyle({
    Widget play,
    Widget pause,
    Color background,
    this.circleBorder,
    this.circleSize = 40,
  })  : this.background = background ?? Color(0xFF00b3ff).withOpacity(0.8),
        this._play = play ?? Icon(Icons.play_arrow, color: Colors.white),
        this._pause = pause ?? Icon(Icons.pause, color: Colors.white);

  final Widget _play;
  final Widget _pause;
  final Color background;
  final double circleSize;
  final BoxBorder circleBorder;

  Widget base(Widget child, Color background) {
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

  Widget get playWidget => base(_play, background);
  Widget get pauseWidget => base(_pause, background);
}
