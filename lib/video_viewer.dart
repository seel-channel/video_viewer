library video_viewer;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/domain/entities/volume_control.dart';
import 'package:video_viewer/ui/video_core/video_core.dart';

export 'package:video_player/video_player.dart';
export 'package:video_viewer/domain/bloc/controller.dart';
export 'package:video_viewer/domain/entities/ads.dart';
export 'package:video_viewer/domain/entities/language.dart';
export 'package:video_viewer/domain/entities/settings_menu_item.dart';
export 'package:video_viewer/domain/entities/styles/video_viewer.dart';
export 'package:video_viewer/domain/entities/subtitle.dart';
export 'package:video_viewer/domain/entities/video_source.dart';
export 'package:video_viewer/domain/entities/volume_control.dart';

class VideoViewer extends StatefulWidget {
  const VideoViewer({
    Key? key,
    required this.source,
    this.style,
    this.controller,
    this.looping = false,
    this.autoPlay = false,
    this.defaultAspectRatio = 16 / 9,
    this.rewindAmount = -10,
    this.forwardAmount = 10,
    this.onFullscreenFixLandscape = true,
    this.language = VideoViewerLanguage.en,
    this.volumeManager = VideoViewerVolumeManager.video,
    this.enableFullscreenScale = true,
    this.enableVerticalSwapingGesture = true,
    this.enableHorizontalSwapingGesture = true,
    this.enableShowReplayIconAtVideoEnd = true,
    this.enableChat = false,
  }) : super(key: key);

  /// Once the video is initialized, it will be played
  final bool autoPlay;

  ///Sets whether or not the video should loop after playing once.
  final bool looping;

  /// It is an argument where you can change the design of almost the entire VideoViewer
  final VideoViewerStyle? style;

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

  /// Controls a platform video viewer, and provides updates when the state is
  /// changing.
  ///
  /// Instances must be initialized with initialize.
  ///...
  /// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
  ///
  /// To reclaim the resources used by the player call [dispose].
  ///
  /// After [dispose] all further calls are ignored.
  final VideoViewerController? controller;

  ///On VerticalSwapingGesture the video is able to control the **video volume** or **device volume**.
  final VideoViewerVolumeManager volumeManager;

  ///When the video is fullscreen and landscape mode, It's able to scale itself until the screen boundaries
  final bool enableFullscreenScale;

  ///On VerticalSwapingGesture the video is able to control the **video volume** or **device volume**.
  final bool enableVerticalSwapingGesture;

  ///On HorizontalSwapingGesture the video is able to control the forward and rewind of itself
  final bool enableHorizontalSwapingGesture;

  //If true, it will add the chat icon to bottom bar. The icon on tap it will show the chat widget.
  final bool enableChat;

  //When the video end, it show a replay icon. If its false, it will never show.
  final bool enableShowReplayIconAtVideoEnd;

  @override
  VideoViewerState createState() => VideoViewerState();
}

class VideoViewerState extends State<VideoViewer> {
  late VideoViewerController _controller;
  late VideoViewerStyle _style;
  bool _initialized = false;

  @override
  void initState() {
    _controller = widget.controller ?? VideoViewerController();
    _style = widget.style ?? VideoViewerStyle();
    _initVideoViewer();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _initVideoViewer() async {
    _controller.looping = widget.looping;
    _controller.isShowingThumbnail = _style.thumbnail != null;
    await _controller.initialize(widget.source, autoPlay: widget.autoPlay);
    
    if (!mounted) return;
    
    setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final Widget? thumbnail = _style.thumbnail;
    return _initialized
        ? MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _controller),
              Provider(
                create: (_) => VideoViewerMetadata(
                  style: _style,
                  language: widget.language,
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  volumeManager: widget.volumeManager,
                  defaultAspectRatio: widget.defaultAspectRatio,
                  onFullscreenFixLandscape: widget.onFullscreenFixLandscape,
                  enableFullscreenScale: widget.enableFullscreenScale,
                  enableVerticalSwapingGesture:
                      widget.enableVerticalSwapingGesture,
                  enableHorizontalSwapingGesture:
                      widget.enableHorizontalSwapingGesture,
                  enableChat: widget.enableChat,
                  enableShowReplayIconAtVideoEnd:
                      widget.enableShowReplayIconAtVideoEnd,
                ),
              ),
            ],
            builder: (_, child) {
              _controller.context = _;
              return const VideoViewerCore();
            },
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: Stack(children: [
              if (thumbnail != null) Positioned.fill(child: thumbnail),
              Center(child: _style.loading),
            ]),
          );
  }
}
