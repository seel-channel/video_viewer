import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

class VideoViewerStyle {
  /// It is the main class of VideoViewer styles, in this class you can almost
  /// all styles and elements of the VideoViewer
  VideoViewerStyle({
    ProgressBarStyle progressBarStyle,
    PlayAndPauseWidgetStyle playAndPauseStyle,
    SettingsMenuStyle settingsStyle,
    ForwardAndRewindStyle forwardAndRewindStyle,
    VolumeBarStyle volumeBarStyle,
    this.header,
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
  final int transitions;

  /// It is the design of the text that will be used in all the texts of the VideoViwer
  ///
  ///DEFAULT:
  ///```dart
  ///  TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
  ///```
  final TextStyle textStyle;

  /// It is used in the responsiveness of the text, when the VideoViewer is
  /// in `Orientation.landscape` will increase the` textStyle fontSize` by x.
  final double inLandscapeEnlargeTheTextBy;

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

class ProgressBarStyle {
  /// It is the style that will have all the icons and elements of the progress bar
  ProgressBarStyle({
    Color barDotColor,
    Color barActiveColor,
    Color barBufferedColor,
    Color barBackgroundColor,
    Color backgroundColor,
    this.barHeight = 5,
    this.paddingBeetwen = 12,
    BorderRadiusGeometry borderRadius,
    Widget fullScreen,
    Widget fullScreenExit,
  })  : this.barDotColor = barDotColor ?? Colors.white,
        this.barActiveColor = barActiveColor ?? Color(0xFF295acc),
        this.barBufferedColor =
            barBufferedColor ?? Colors.white.withOpacity(0.3),
        this.barBackgroundColor =
            barBackgroundColor ?? Colors.white.withOpacity(0.2),
        this.backgroundColor =
            backgroundColor ?? Colors.black.withOpacity(0.36),
        this.borderRadius = borderRadius ?? BorderRadius.circular(5),
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

  /// It is the height of the progress bar. ** NOTE: ** The radius of the point
  /// is proportional to the barHeight
  final double barHeight;

  /// It is the padding that will have the icons and the progressBar
  final double paddingBeetwen;

  /// It is the icon that appears when you want to enter full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.fullscreen_outlined, color: Colors.white, size: 24);
  ///```
  final Widget fullScreen;

  /// It is the icon that appears when you want to exit the full screen.
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.fullscreen_exit_outlined, color: Colors.white, size: 24);
  ///```
  final Widget fullScreenExit;

  /// It is the color that the progressBarDot will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.white;
  ///```
  final Color barDotColor;

  /// It is the color of the current video progress in the progress bar
  ///
  ///DEFAULT:
  ///```dart
  ///  Color(0xFF295acc);
  ///```
  final Color barActiveColor;

  /// It is the color of the amount of the damping video
  /// in the progress bar
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.white.withOpacity(0.3);
  ///```
  final Color barBufferedColor;

  /// Is the background color of the progress bar
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.white.withOpacity(0.2);
  ///```
  final Color barBackgroundColor;

  /// It is the background color that the gradient and the PreviewFrame will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.black.withOpacity(0.28);
  ///```
  final Color backgroundColor;

  /// Is the radius of the border that will have the progress bar and the PreviewFrame
  ///
  ///DEFAULT:
  ///```dart
  ///  EdgeRadius.all(5);
  ///  "EdgeRadius is on Helpers pubdev library"
  ///```
  final BorderRadiusGeometry borderRadius;
}

class PlayAndPauseWidgetStyle {
  /// With this argument you will change the play and pause icons, also the style
  /// of the circle that appears behind. Note: The play and pause icons are
  /// the same ones that appear in the progress bar
  PlayAndPauseWidgetStyle({
    Widget play,
    Widget pause,
    Color background,
    this.circleBorder,
    this.circleRadius = 40,
  })  : this.background = background ?? Color(0xFF295acc).withOpacity(0.8),
        this.play = play ?? Icon(Icons.play_arrow, color: Colors.white),
        this.pause = pause ?? Icon(Icons.pause, color: Colors.white);

  /// It is the icon that will have the play of the progress bar and also
  /// the one that appears in the middle of the screen
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.play_arrow, color: Colors.white);
  ///```
  final Widget play;

  /// It is the icon that will have the pause of the progress bar and also
  /// the one that appears in the middle of the screen
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.pause, color: Colors.white);
  ///```
  final Widget pause;

  /// It is the background color that the play and pause icons will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Color(0xFF295acc).withOpacity(0.8);
  ///```
  final Color background;

  /// Is the size of the container
  final double circleRadius;

  /// It is the style of the border that the container will have
  final BoxBorder circleBorder;

  Widget _base(Widget child, Color background) {
    return Container(
      width: circleRadius,
      height: circleRadius,
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

class SettingsMenuStyle {
  /// These are the styles of the settings sales, here you will change the icons and
  /// the language of the texts
  SettingsMenuStyle({
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

  /// It is the icon that will have the speed change option
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.speed, color: Colors.white, size: 20;
  ///```
  final Widget speed;

  /// It is the chevron or icon that appears to return to the Settings Menu
  /// when you are changing Quality or Speed
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.chevron_left, color: Colors.white);
  ///```
  final Widget chevron;

  /// It is the icon that appears when the current configuration is selected
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.done, color: Colors.white, size: 20);
  ///```
  final Widget selected;

  /// It is the configuration icon that appears in the ProgressBar and also in
  /// the Settings Menu
  ///
  ///DEFAULT:
  ///```dart
  ///  Icon(Icons.settings_outlined, color: Colors.white, size: 20);
  ///```
  final Widget settings;

  /// It is the padding between all the elements of the SettingsMenu
  final double paddingBetween;
}

class ForwardAndRewindStyle {
  /// With this argument change the icons that appear when double-tapping,
  /// also the style of the container that indicates when the video will be rewind or forward.
  ForwardAndRewindStyle({
    Widget rewind,
    Widget forward,
    Color backgroundColor,
    EdgeInsetsGeometry padding,
    BorderRadiusGeometry borderRadius,
  })  : this.padding = padding ?? Margin.all(5),
        this.backgroundColor =
            backgroundColor ?? Colors.black.withOpacity(0.28),
        this.borderRadius = borderRadius ?? EdgeRadius.vertical(bottom: 5),
        this.rewind = rewind ?? Icon(Icons.fast_rewind, color: Colors.white),
        this.forward = forward ?? Icon(Icons.fast_forward, color: Colors.white);

  /// The icon that appears momentarily when you double tap
  ///
  ///DEFAULT:
  ///```dart
  ///   Icon(Icons.fast_rewind, color: Colors.white);
  ///```
  final Widget rewind;

  /// The icon that appears momentarily when you double tap
  ///
  ///DEFAULT:
  ///```dart
  ///   Icon(Icons.fast_forward, color: Colors.white);
  ///```
  final Widget forward;

  /// The background color of the indicator of when time will advance
  /// or will slow down the video
  ///
  ///DEFAULT:
  ///```dart
  ///   Colors.black.withOpacity(0.28);
  ///```
  final Color backgroundColor;

  /// It is the padding that the forward and rewind indicator will have
  ///
  ///DEFAULT:
  ///```dart
  ///   Margin.all(5);
  ///   "NOTE: Margin is on Helpers pubdev library"
  ///```
  final EdgeInsetsGeometry padding;

  /// It is the borderRadius that will have the forward and rewind indicator
  ///
  ///DEFAULT:
  ///```dart
  ///   EdgeRadius.vertical(bottom: 5);
  ///   "NOTE: EdgeRadius is on Helpers pubdev library"
  ///```
  final BorderRadiusGeometry borderRadius;
}

class VolumeBarStyle {
  /// Only Android Support, this style is for Volume controller but at
  /// only having android support will only show for that platform.
  VolumeBarStyle({
    this.width = 5,
    this.height = 120,
    Color color,
    Color backgroundColor,
    EdgeInsetsGeometry margin,
    BorderRadiusGeometry borderRadius,
    this.alignment = Alignment.centerLeft,
  })  : this.color = color ?? Colors.white,
        this.margin = margin ?? Margin.horizontal(20),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5),
        this.backgroundColor = backgroundColor ?? Colors.white.withOpacity(0.2);

  /// Size that the VolumeBar will have
  final double width, height;

  /// The color of the active volume that the VolumeBar will have
  ///
  ///DEFAULT:
  ///```dart
  ///   Colors.white;
  ///```
  final Color color;

  /// The background color that the VolumeBar will have
  ///
  ///DEFAULT:
  ///```dart
  ///  Colors.white.withOpacity(0.2);
  ///```
  final Color backgroundColor;

  /// It is in the position that the Volume Bar will be found.
  ///
  ///**NOTE:**
  /// Works well only with `Alignment.centerLeft` y `Alignment.centerRight`
  final Alignment alignment;

  /// It is the margin that the Volume Bar has of the limits of the VideoViewer
  ///
  ///DEFAULT:
  ///```dart
  ///  Margin.horizontal(20);
  ///  "NOTE: Margin is on Helpers pubdev library"
  ///```
  final EdgeInsetsGeometry margin;

  /// It is the borderRadius that the VolumeBar will have
  ///
  ///DEFAULT:
  ///```dart
  ///  EdgeRadius.all(5);
  ///  "NOTE: EdgeRadius is on Helpers pubdev library"
  ///```
  final BorderRadiusGeometry borderRadius;
}
