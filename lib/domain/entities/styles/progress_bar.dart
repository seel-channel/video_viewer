import 'package:flutter/material.dart';

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
    BorderRadius borderRadius,
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
  final BorderRadius borderRadius;
}
