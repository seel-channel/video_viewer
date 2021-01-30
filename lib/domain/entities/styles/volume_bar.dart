import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

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
