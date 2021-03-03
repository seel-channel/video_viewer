library video_viewer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/ui/video_core/video_core.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

export 'package:video_viewer/domain/entities/styles/video_viewer.dart';
export 'package:video_viewer/domain/entities/settings_menu_item.dart';
export 'package:video_viewer/domain/entities/video_source.dart';
export 'package:video_viewer/domain/entities/subtitle.dart';
export 'package:video_viewer/domain/entities/language.dart';
export 'package:video_viewer/domain/bloc/controller.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    @required this.source,
    VideoViewerStyle style,
    VideoViewerController controller,
    this.looping = false,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
    this.onFullscreenFixLandscape = false,
    this.language = VideoViewerLanguage.en,
  })  : this.controller = controller ?? VideoViewerController(),
        this.style = style ?? VideoViewerStyle(),
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

  final VideoViewerController controller;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  VideoViewerController _controller;
  VideoViewerMetadata _metadata;
  bool _initialized = false;

  @override
  void initState() {
    _controller = widget.controller;
    _controller.source = widget.source;
    _controller.looping = widget.looping;
    _controller.source = widget.source;
    _metadata = VideoViewerMetadata(
      style: widget.style,
      language: widget.language,
      rewindAmount: widget.rewindAmount,
      forwardAmount: widget.forwardAmount,
      defaultAspectRatio: widget.defaultAspectRatio,
      onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
    );
    _initVideoViewer();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _initVideoViewer() async {
    final activedSource = widget.source.keys.toList().first;
    final source = widget.source.values.toList().first;

    await _controller.changeSource(
      source: source,
      name: activedSource,
      autoPlay: widget.autoPlay,
    );

    _controller.isShowingThumbnail = widget.style.thumbnail != null;
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              Provider.value(value: _metadata),
            ],
            builder: (_, __) => VideoViewerCore(),
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: widget.style.loading);
  }
}
