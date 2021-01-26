library video_viewer;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/widgets/video_core.dart';
import 'package:video_viewer/utils/sources.dart';

export 'package:video_viewer/domain/entities/styles/video_viewer.dart';
export 'package:video_viewer/domain/entities/settings_menu_item.dart';
export 'package:video_viewer/domain/entities/video_source.dart';
export 'package:video_viewer/domain/entities/language.dart';
export 'utils/subtitle.dart';
export 'utils/sources.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    @required this.source,
    VideoViewerStyle style,
    this.looping = false,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
    this.onFullscreenFixLandscape = true,
    this.language = VideoViewerLanguage.en,
    this.settingsMenuItems,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  /// Once the video is initialized, it will be played
  final bool autoPlay;

  ///Sets whether or not the video should loop after playing once.
  final bool looping;

  /// It is an argument where you can change the design of almost the entire VideoViewer
  final VideoViewerStyle style;

  /// It is the Aspect Ratio that the widget.style.loading will take when the video
  /// is not initialized yet
  final double defaultAspectRatio;

  /// It is the amount of seconds that the video will be delayed when double tapping.
  final int rewindAmount;

  /// It is the amount of seconds that the video will be advanced when double tapping.
  final int forwardAmount;

  /// Receive a list of all the resources to be played.
  ///
  ///SYNTAX EXAMPLE:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  ///```
  final Map<String, VideoSource> source;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool onFullscreenFixLandscape;

  ///It's the custom language can you set to the VideoViewer.
  ///
  ///**EXAMPLE:** SETTING THE SPANISH LANGUAGE TO THE VIDEOVIEWER
  ///```dart
  /// //WAY 1
  /// language: VideoViewerLanguage.es
  /// //WAY 2
  /// language: VideoViewerLanguage(quality: "Calidad", speed: "Velocidad", ...)
  /// //WAY 3
  /// language: VideoViewerLanguage.fromString("es")
  /// ```
  final VideoViewerLanguage language;

  ///ADD CUSTOM SECTIONS TO SETTINGS MENU
  final List<SettingsMenuItem> settingsMenuItems;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  VideoPlayerController _controller;
  String _activedSource;

  @override
  void initState() {
    _activedSource = widget.source.keys.toList()[0];
    _controller = widget.source.values.toList()[0].video
      ..initialize().then((_) {
        if (widget.autoPlay) _controller.play();
        _controller.setLooping(widget.looping);
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void disposeController() async {
    await _controller?.pause();
    await _controller.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.initialized
        ? VideoViewerCore(
            style: widget.style,
            source: widget.source,
            looping: widget.looping,
            language: widget.language,
            controller: _controller,
            activedSource: _activedSource,
            rewindAmount: widget.rewindAmount,
            forwardAmount: widget.forwardAmount,
            settingsMenuItems: widget.settingsMenuItems,
            defaultAspectRatio: widget.defaultAspectRatio,
            onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: widget.style.loading);
  }
}
