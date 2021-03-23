import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:video_viewer/domain/entities/styles/bar.dart';

class ForwardAndRewindStyle {
  /// With this argument change the icons that appear when double-tapping,
  /// also the style of the container that indicates when the video will be rewind or forward.
  ForwardAndRewindStyle({
    BarStyle? bar,
    Widget? rewind,
    Widget? forward,
    Color? backgroundColor,
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  })  : this.bar = bar ?? BarStyle.forward(),
        this.padding = padding ?? Margin.all(20),
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

  final BarStyle bar;
}
