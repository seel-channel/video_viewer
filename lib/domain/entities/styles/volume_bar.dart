import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';
import 'package:video_viewer/domain/entities/styles/bar.dart';

class VolumeBarStyle {
  /// Only Android Support, this style is for Volume controller but at
  /// only having android support will only show for that platform.
  VolumeBarStyle({
    BarStyle? bar,
    EdgeInsetsGeometry? margin,
    this.alignment = Alignment.centerLeft,
  })  : this.bar = bar ?? BarStyle.volume(),
        this.margin = margin ?? Margin.horizontal(20);

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

  ///DEFAULT:
  ///```dart
  ///BarStyle.volume()
  ///```
  final BarStyle bar;
}
