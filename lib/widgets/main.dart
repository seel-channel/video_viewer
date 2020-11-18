import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/video.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    this.source,
    VideoViewerStyle style,
    this.looping = true,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  final bool autoPlay, looping;
  final VideoViewerStyle style;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final Map<String, VideoPlayerController> source;

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  GlobalKey<VideoReadyState> key = GlobalKey<VideoReadyState>();
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
    super.dispose();
    disposeController();
  }

  void disposeController() async {
    await _controller?.pause();
    await _controller.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget returnWidget = _controller.value.initialized
        ? Hero(
            tag: 'VideoReady',
            child: VideoReady(
              key: key,
              style: widget.style,
              source: widget.source,
              looping: widget.looping,
              controller: _controller,
              activedSource: _activedSource,
              rewindAmount: widget.rewindAmount,
              forwardAmount: widget.forwardAmount,
              defaultAspectRatio: widget.defaultAspectRatio,
            ),
          )
        : Center(child: CircularProgressIndicator(strokeWidth: 1.6));
    return returnWidget;
  }
}

// class _VideoViewerState extends State<VideoViewer> {
//   bool isPlaying = false,
//       isBuffering = false,
//       isFullScreen = false,
//       _isChangingSource = false,
//       _isSeekingVideo = false,
//       _showButtons = false,
//       _showThumbnail = true,
//       _fixedLandscape = false,
//       //_showVolumeStatus = false,
//       _showForwardStatus = false,
//       _progressBarTextShowPosition = false,
//       _isGoingToCloseBufferingWidget = false,
//       _showAMomentPlayAndPause = false,
//       _showSettings = false;
//   List<bool> _showAMomentButtons = [false, false];
//   int _lastPosition = 0,
//       // _maxVolume,
//       //_currentVolume,
//       //_volumeStatus,
//       _forwardAmount = 0;
//   //Offset _verticalDragStartOffset;
//   Offset _horizontalDragStartOffset;
//   //Future<void> _initializeVideoPlayerFuture;
//   VideoPlayerController _controller;
//   Timer _closeButtons, _timePosition;
//   String _activedSource;
//   Future<void> futureInitialized;

//   @override
//   void initState() {
//     super.initState();
//     _activedSource = widget.source.keys.toList()[0];
//     //_initVideoController(widget.source.values.toList()[0]);
//     _controller = VideoPlayerController.network(
//         'http://www.sample-videos.com/video123/mp4/720/big_buck_bunny_720p_20mb.mp4');
//     futureInitialized = _controller.initialize().then((_) {
//       // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
//       setState(() {});
//     });
//     //_initAudioStreamType();
//     //_updateVolumes();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//     _timePosition?.cancel();
//     killController();
//   }

//   void killController() async {
//     await _controller?.pause();
//     await _controller.dispose();
//     _controller = null;
//   }

//   //VIDEO CONTROLLER
//   void _initVideoController(
//     VideoPlayerController source, [
//     Duration seekTo,
//     double speed,
//   ]) {
//     source.initialize().then((value) {
//       if (seekTo != null && speed != null) {
//         setState(() {
//           _isChangingSource = false;
//           _controller = source;
//         });
//         _controller.setPlaybackSpeed(speed);
//         _controller.seekTo(seekTo);
//         _controller.play();
//       } else {
//         setState(() {
//           _controller = source;
//         });
//         Misc.onLayoutRendered(() {
//           if (widget.autoPlay) _controller.play();
//         });
//       }
//       setState(() {});
//     });
//     if (_showThumbnail) {
//       setState(() {
//         _controller = source;
//         //_initializeVideoPlayerFuture = future;
//         _controller.setLooping(widget.looping);
//         _controller.addListener(_videoListener);
//       });
//     }
//   }

//   void _changeVideoSource(
//     VideoPlayerController source,
//     String activedSource,
//   ) {
//     setState(() {
//       _showButtons = false;
//       _showSettings = false;
//       _isChangingSource = true;
//       _activedSource = activedSource;
//       _initVideoController(
//         source,
//         _controller.value.position,
//         _controller.value.playbackSpeed,
//       );
//     });
//   }

//   void _videoListener() {
//     if (mounted) {
//       setState(() => isPlaying = _controller.value.isPlaying);
//       if (_showButtons) {
//         if (isPlaying) {
//           _startCloseOverlayButtons();
//           if (_timePosition == null) _createBufferTimer();
//         } else if (_isGoingToCloseBufferingWidget) {
//           _cancelCloseOverlayButtons();
//         }
//       }
//     }
//   }

//   //TIMER
//   void _createBufferTimer() {
//     setState(() {
//       _timePosition = Timer.periodic(Duration(milliseconds: 500), (timer) {
//         setState(() {
//           int position = _controller.value.position.inMilliseconds;
//           if (isPlaying) {
//             if (_lastPosition != position) {
//               isBuffering = false;
//             } else {
//               isBuffering = true;
//             }
//           } else if (!_isSeekingVideo) {
//             isBuffering = false;
//           }
//           _lastPosition = position;
//         });
//       });
//     });
//   }

//   void _startCloseOverlayButtons() {
//     setState(() {
//       if (!_isGoingToCloseBufferingWidget) {
//         _isGoingToCloseBufferingWidget = true;
//         _closeButtons = Timer(Duration(milliseconds: 3600), () {
//           setState(() => _showButtons = false);
//         });
//       }
//     });
//   }

//   void _cancelCloseOverlayButtons() {
//     setState(() {
//       _isGoingToCloseBufferingWidget = false;
//       _closeButtons?.cancel();
//       _closeButtons = null;
//     });
//   }

//   //ORIENTATION DEVICE
//   void _toFullScreen({bool onBuilder = false}) async {
//     if (!onBuilder) {
//       setState(() {
//         isFullScreen = true;
//         _fixedLandscape = true;
//       });
//       await Misc.setSystemOrientation(SystemOrientation.landscapeLeft);
//     } else {
//       isFullScreen = true;
//       _fixedLandscape = false;
//     }
//     changeOverlay(SystemOverlay.none);
//     if (widget.onFullScreen != null) widget.onFullScreen();
//   }

//   void _exitFullScreen({bool onBuilder = false}) async {
//     if (!onBuilder) {
//       setState(() {
//         isFullScreen = false;
//         _fixedLandscape = false;
//       });
//     } else {
//       isFullScreen = false;
//       _fixedLandscape = false;
//     }
//     changeOverlay(SystemOverlay.values);
//     Misc.delayed(2000, () async {
//       if (mounted && !isFullScreen)
//         await Misc.setSystemOrientation(SystemOrientation.values);
//     });
//     await Misc.setSystemOrientation(SystemOrientation.portraitUp);
//     if (widget.onExitFullScreen != null) widget.onExitFullScreen();
//   }

//   void changeOverlay(dynamic value) {
//     Misc.delayed(200, () async {
//       if (mounted) await Misc.setSystemOverlay(value);
//     });
//   }

//   void _changeOrientation() {
//     isFullScreen ? _exitFullScreen() : _toFullScreen();
//   }

//   //VOLUME
//   // void _initAudioStreamType() async {
//   //   await Volume.controlVolume(AudioManager.STREAM_MUSIC);
//   // }

//   // void _updateVolumes() async {
//   //   _currentVolume = await Volume.getVol;
//   //   _maxVolume = await Volume.getMaxVol;
//   //   _volumeStatus = _currentVolume;
//   //   if (mounted) setState(() {});
//   // }

//   // void _setVolume(int amount) async {
//   //   await Volume.setVol(amount, showVolumeUI: ShowVolumeUI.HIDE);
//   //   _volumeStatus = await Volume.getVol;
//   //   setState(() {});
//   // }

//   //GESTURES
//   Widget _globalGesture(Widget child) {
//     return GestureDetector(
//       child: child,
//       onTap: () {
//         if (!_showSettings)
//           setState(() {
//             _showButtons = !_showButtons;
//             if (_showButtons) _isGoingToCloseBufferingWidget = false;
//           });
//       },
//       //VOLUME
//       // onVerticalDragStart: (DragStartDetails details) {
//       //   if (!_showSettings) {
//       //     _updateVolumes();
//       //     setState(() {
//       //       _verticalDragStartOffset = details.globalPosition;
//       //       _showVolumeStatus = true;
//       //     });
//       //   }
//       // },
//       // onVerticalDragUpdate: (DragUpdateDetails details) {
//       //   if (!_showSettings) {
//       //     double diff = _verticalDragStartOffset.dy - details.globalPosition.dy;
//       //     int volume = (diff / 15).round() + _currentVolume;
//       //     if (volume <= _maxVolume && volume >= 0) _setVolume(volume);
//       //   }
//       // },
//       // onVerticalDragEnd: (DragEndDetails details) {
//       //   if (!_showSettings)
//       //     setState(() {
//       //       _showVolumeStatus = false;
//       //     });
//       // },
//       //FORWARD AND REWIND
//       onHorizontalDragStart: (DragStartDetails details) {
//         if (!_showSettings)
//           setState(() {
//             _horizontalDragStartOffset = details.globalPosition;
//             _showForwardStatus = true;
//           });
//       },
//       onHorizontalDragUpdate: (DragUpdateDetails details) {
//         if (!_showSettings) {
//           double diff =
//               _horizontalDragStartOffset.dx - details.globalPosition.dx;
//           double multiplicator = (diff.abs() / 50);
//           int amount = -((diff / 10).round() * multiplicator).round();
//           int seconds = _controller.value.position.inSeconds;
//           setState(() {
//             if (seconds + amount < _controller.value.duration.inSeconds &&
//                 seconds + amount > 0) _forwardAmount = amount;
//           });
//         }
//       },
//       onHorizontalDragEnd: (DragEndDetails details) async {
//         if (!_showSettings) {
//           setState(() => _showForwardStatus = false);
//           int seconds = _controller.value.position.inSeconds;
//           await _controller.seekTo(Duration(seconds: seconds + _forwardAmount));
//           await _controller.play();
//         }
//       },
//     );
//   }

//   Widget _rewindAndForward() {
//     void _showRewindAndForward(int index, int amount) async {
//       int seconds = _controller.value.position.inSeconds;
//       await _controller.seekTo(Duration(seconds: seconds + amount));
//       await _controller.play();
//       setState(() {
//         _forwardAmount = amount;
//         _showForwardStatus = true;
//         _showAMomentButtons[index] = true;
//       });
//       Misc.delayed(400, () {
//         setState(() {
//           _showForwardStatus = false;
//           _showAMomentButtons[index] = false;
//         });
//       });
//     }

//     return Padding(
//       padding: Margin.bottom(32),
//       child: Row(children: [
//         Expanded(
//           child: GestureDetector(
//             onDoubleTap: () => _showRewindAndForward(0, -widget.rewindAmount),
//           ),
//         ),
//         SizedBox(
//           height: double.infinity,
//           width: GetContext.width(context) / 2,
//           child: Container(color: Colors.transparent),
//         ),
//         Expanded(
//           child: GestureDetector(
//             onDoubleTap: () => _showRewindAndForward(1, widget.forwardAmount),
//           ),
//         ),
//       ]),
//     );
//   }

//   Widget _playAndPause(Widget child) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (isPlaying) {
//             _controller.pause();
//           } else {
//             _controller.play();
//             _lastPosition = _lastPosition - 1;
//             if (_showThumbnail) _showThumbnail = false;
//           }
//           if (!_showButtons) _showAMomentPlayAndPause = true;
//         });
//         if (!_showButtons)
//           Misc.delayed(800, () {
//             setState(() => _showAMomentPlayAndPause = false);
//           });
//       },
//       child: child,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return Container(
//     //   child: _controller.value.initialized
//     //       ?
//     return OrientationBuilder(
//       builder: (_, Orientation orientation) {
//         if (_controller.value.initialized) {
//           if (orientation == Orientation.landscape && !isFullScreen)
//             _toFullScreen(onBuilder: true);
//           else if (isFullScreen &&
//               !_fixedLandscape &&
//               orientation == Orientation.portrait)
//             _exitFullScreen(onBuilder: true);
//         }
//         return FutureBuilder(
//           future: futureInitialized,
//           builder: (_, snapshot) {
//             final value = snapshot.connectionState == ConnectionState.done
//                 ? Hero(
//                     tag: 'imageHero',
//                     child: VideoReady(
//                       controller: _controller,
//                       style: widget.style,
//                     ),
//                   )
//                 : SizedBox();
//             return value;
//           },
//         );
//       },

//       // : AspectRatio(
//       //     aspectRatio: Misc.ifNull(
//       //         _controller.value.aspectRatio, widget.defaultAspectRatio),
//       //     child: Stack(children: [
//       //       if (widget.style.thumbnail != null) widget.style.thumbnail,
//       //       widget.style.loading
//       //     ]),
//       //   ),
//     );
//   }

//   //
//   Widget _principalVideo() {
//     return AspectRatio(
//       aspectRatio: widget.defaultAspectRatio, //_controller.value.aspectRatio,
//       child: _globalGesture(
//         Stack(children: [
//           VideoPlayer(_controller),
//           if (_showThumbnail && widget.style.thumbnail != null)
//             Container(child: widget.style.thumbnail),
//           OpacityTransition(
//             visible: _showButtons,
//             child: _overlayButtons(),
//           ),
//           _rewindAndForward(),
//           _doubleTapToFullScreen(),
//           _settingsButton(Colors.transparent),
//           Center(
//             child: _playAndPause(
//               Container(
//                 height: GetContext.width(context) / 4,
//                 width: GetContext.width(context) / 4,
//                 color: Colors.transparent,
//               ),
//             ),
//           ),
//           OpacityTransition(
//             visible: isBuffering || _isChangingSource,
//             child: widget.style.buffering,
//           ),
//           // OpacityTransition(
//           //   visible: _showVolumeStatus,
//           //   child: VideoVolumeBar(
//           //     style: widget.style.volumeBarStyle,
//           //     progress: (_volumeStatus / _maxVolume),
//           //   ),
//           // ),
//           OpacityTransition(
//             visible: _showForwardStatus,
//             child: _forwardAmountAlert(),
//           ),
//           OpacityTransition(
//             visible: _showAMomentPlayAndPause,
//             child: _bigPlayAndPauseWidget(),
//           ),
//           SettingsMenu(
//             source: widget.source,
//             visible: _showSettings,
//             controller: _controller,
//             activedSource: _activedSource,
//             changeSource: _changeVideoSource,
//             changeState: () => setState(() => _showSettings = !_showSettings),
//           ),
//           Row(children: [
//             Expanded(
//               child: OpacityTransition(
//                 visible: _showAMomentButtons[0],
//                 child: Center(child: widget.style.rewind),
//               ),
//             ),
//             Expanded(child: SizedBox()),
//             Expanded(child: SizedBox()),
//             Expanded(
//               child: OpacityTransition(
//                 visible: _showAMomentButtons[1],
//                 child: Center(child: widget.style.forward),
//               ),
//             ),
//           ]),
//         ]),
//       ),
//     );
//   }

//   //WIDGETS
//   Widget _doubleTapToFullScreen() {
//     return Padding(
//       padding: Margin.bottom(32),
//       child: Center(
//         child: GestureDetector(
//           onDoubleTap: _changeOrientation,
//           child: SizedBox(
//             height: double.infinity,
//             width: GetContext.width(context) / 2,
//             child: Container(color: Colors.transparent),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _bigPlayAndPauseWidget() {
//     return Center(
//       child: _playAndPause(
//         !isPlaying
//             ? widget.style.playAndPauseStyle.playWidget
//             : widget.style.playAndPauseStyle.pauseWidget,
//       ),
//     );
//   }

//   Widget _forwardAmountAlert() {
//     final style = widget.style.forwardAndRewindStyle;
//     String text = secondsFormatter(_forwardAmount);

//     return Align(
//       alignment: style.alignment,
//       child: Container(
//         padding: style.padding,
//         decoration: BoxDecoration(
//           color: style.backgroundColor,
//           borderRadius: style.borderRadius,
//         ),
//         child: Text(
//           text,
//           style: style.textStyle,
//         ),
//       ),
//     );
//   }

//   Widget _overlayButtons() {
//     return Stack(children: [
//       Container(color: Colors.black.withOpacity(0.2)),
//       _settingsButton(Colors.white),
//       _progressBarAndButtons(),
//       widget.style.onPlayingHideBigPauseWidget
//           ? OpacityTransition(
//               visible: !isPlaying,
//               child: _bigPlayAndPauseWidget(),
//             )
//           : _bigPlayAndPauseWidget(),
//     ]);
//   }

//   Widget _settingsButton(Color color) {
//     return Align(
//       alignment: Alignment.topRight,
//       child: GestureDetector(
//         onTap: () => setState(() => _showSettings = !_showSettings),
//         child: Container(
//           padding: Margin.all(10),
//           color: Colors.transparent,
//           child: Icon(
//             Icons.settings,
//             color: color,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _progressBarAndButtons() {
//     final value = _controller.value;
//     final style = widget.style.progressBarStyle;
//     double height = 24;
//     String position;
//     if (_controller.value.initialized) {
//       position = secondsFormatter(_progressBarTextShowPosition
//           ? value.position.inSeconds
//           : value.position.inSeconds - value.duration.inSeconds);
//     } else {
//       position = "00:00";
//     }

//     return Align(
//       alignment: Alignment.bottomLeft,
//       child: Container(
//         height: height,
//         margin: Margin.all(5),
//         child: Row(
//           children: [
//             _playAndPause(isPlaying ? widget.style.pause : widget.style.play),
//             SizedBox(width: widget.style.paddingBeetwen),
//             Expanded(
//               child: VideoProgressBar(
//                 _controller,
//                 style: style,
//                 isBuffering: isBuffering,
//                 changeSeeking: (value) =>
//                     setState(() => _isSeekingVideo = value),
//               ),
//             ),
//             SizedBox(width: widget.style.paddingBeetwen),
//             Container(
//               height: height,
//               color: Colors.transparent,
//               alignment: Alignment.center,
//               child: GestureDetector(
//                 onTap: () => setState(() => _progressBarTextShowPosition =
//                     !_progressBarTextShowPosition),
//                 child: Text(position, style: style.textStyle),
//               ),
//             ),
//             SizedBox(width: widget.style.paddingBeetwen),
//             GestureDetector(
//               onTap: () {
//                 PushRoute.page(
//                     context, FullScreenPage(child: _principalVideo()),
//                     withTransition: false);
//                 //setState(() => isFullScreen = true);
//               }, //_changeOrientation,
//               child: isFullScreen
//                   ? widget.style.fullScreenExit
//                   : widget.style.fullScreen,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
