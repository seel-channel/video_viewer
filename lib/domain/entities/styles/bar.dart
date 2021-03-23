import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

class BarStyle {
  final BorderRadius borderRadius;

  /// Is the background color of the progress bar
  final Color background;
  final double height;
  final double width;
  final Color color;
  final Color dot;
  final Color buffered;

  /// The **[height]** of the progress bar. ** NOTE: ** The radius of the point is proportional to the [height
  /// ]
  /// The **[color]** is the color of the current video progress in the progress bar
  ///
  /// The **[dot]** is the color that the progressBarDot will have
  ///
  /// The **[background]** is the color of the progress bar
  ///
  /// The **[buffered]** is the color of the amount of the damping video
  /// in the progress bar
  ///
  /// The **[borderRadius]** of the border that will have the progress bar and the PreviewFrame
  BarStyle.progress({
    this.height = 5,
    Color? dot,
    Color? color,
    Color? buffered,
    Color? background,
    BorderRadius? borderRadius,
  })  : this.width = double.infinity,
        this.dot = dot ?? Colors.white,
        this.color = color ?? Color(0xFF295acc),
        this.buffered = buffered ?? Colors.white.withOpacity(0.3),
        this.background = background ?? Colors.white.withOpacity(0.2),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5.0);

  /// The **[borderRadius]** that the VolumeBar will have
  ///
  /// The **[background]** that the VolumeBar will have
  ///
  /// The **[color]** of the active volume that the VolumeBar will have
  ///
  /// The **[width]** and **[height]** are the Size that the VolumeBar will have
  ///
  BarStyle.volume({
    this.width = 5,
    this.height = 120,
    Color? color,
    Color? background,
    BorderRadius? borderRadius,
  })  : this.dot = Colors.transparent,
        this.color = color ?? Colors.white,
        this.buffered = Colors.transparent,
        this.background = background ?? Colors.white.withOpacity(0.2),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5.0);

  BarStyle.forward({
    this.width = 5,
    this.height = 120,
    Color? color,
    Color? background,
    BorderRadius? borderRadius,
  })  : this.dot = Colors.transparent,
        this.color = color ?? Colors.white,
        this.buffered = Colors.transparent,
        this.background = background ?? Colors.white.withOpacity(0.2),
        this.borderRadius = borderRadius ?? EdgeRadius.all(5.0);
}
