import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer/utils/language.dart';

import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/video_core.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    this.source,
    VideoViewerStyle style,
    this.looping = false,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
    this.onFullscreenFixLandscape = true,
    this.language = VideoViewerLanguage.en,
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
  ///    "720p": VideoSource.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4"),
  ///    "1080p": VideoSource.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
  ///}
  ///```
  final Map<String, VideoPlayerController> source;

  ///If it is `true`, when entering the fullscreen it will be fixed
  ///in landscape mode and it will not be possible to rotate it in portrait.
  ///If it is `false`, you can rotate the entire screen in any position.
  final bool onFullscreenFixLandscape;

  final VideoViewerLanguage language;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  VideoPlayerController _controller;
  String _activedSource;

  @override
  void initState() {
    _activedSource = widget.source.keys.toList()[0];
    _controller = widget.source.values.toList()[0]
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
    Widget returnWidget = _controller.value.initialized
        ? VideoViewerCore(
            style: widget.style,
            source: widget.source,
            looping: widget.looping,
            controller: _controller,
            activedSource: _activedSource,
            rewindAmount: widget.rewindAmount,
            forwardAmount: widget.forwardAmount,
            defaultAspectRatio: widget.defaultAspectRatio,
            onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: widget.style.loading);
    return returnWidget;
  }
}
