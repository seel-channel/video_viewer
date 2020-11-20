import 'dart:async';
import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/utils/styles.dart';
import 'package:video_viewer/widgets/misc.dart';
import 'package:video_viewer/widgets/progress.dart';

import '../helpers.dart';

class VideoReady extends StatefulWidget {
  VideoReady({
    Key key,
    this.controller,
    this.style,
    this.source,
    this.activedSource,
    this.looping,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.onChangeSource,
  }) : super(key: key);

  final String activedSource;
  final bool looping;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoViewerStyle style;
  final VideoPlayerController controller;
  final Map<String, VideoPlayerController> source;
  final void Function(VideoPlayerController, String) onChangeSource;

  @override
  VideoReadyState createState() => VideoReadyState();
}

class VideoReadyState extends State<VideoReady> {
  bool isPlaying = false,
      isBuffering = false,
      isFullScreen = false,
      _showButtons = false,
      _showSettings = false,
      _showThumbnail = true,
      _showForwardStatus = false,
      _showAMomentPlayAndPause = false,
      _progressBarTextShowPosition = false,
      _isGoingToCloseBufferingWidget = false;
  Timer _closeOverlayButtons, _timerPosition, _hidePlayAndPause;
  List<bool> _showAMomentRewindIcons = [false, false];
  int _lastPosition = 0, _forwardAmount = 0;
  VideoPlayerController _controller;
  double _progressBarBottomMargin = 0;
  Offset _horizontalDragStartOffset;
  String _activedSource;
  //Preview Frame
  // bool _isDraggingProgress = false;
  // double _draggingProgressPosition;
  // Duration _seekToPosition;

  set fullScreen(bool value) => setState(() => isFullScreen = value);

  @override
  void initState() {
    _controller = widget.controller;
    _activedSource = widget.activedSource;
    _controller.addListener(_videoListener);
    _controller.setLooping(true);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timerPosition?.cancel();
    _hidePlayAndPause?.cancel();
    _closeOverlayButtons?.cancel();
  }

  //----------------//
  //VIDEO CONTROLLER//
  //----------------//
  void _changeVideoSource(VideoPlayerController source, String activedSource,
      [bool initialize = true]) {
    double speed = _controller.value.playbackSpeed;
    Duration seekTo = _controller.value.position;
    setState(() {
      _showButtons = false;
      _showSettings = false;
      _activedSource = activedSource;
      if (initialize)
        source
            .initialize()
            .then((_) => _setSettingsController(source, speed, seekTo));
      else
        _setSettingsController(source, speed, seekTo);
    });
  }

  void _setSettingsController(
      VideoPlayerController source, double speed, Duration seekTo) {
    setState(() => _controller = source);
    _controller.addListener(_videoListener);
    _controller.setLooping(widget.looping);
    _controller.setPlaybackSpeed(speed);
    _controller.seekTo(seekTo);
    _controller.play();
    if (widget.onChangeSource != null)
      widget.onChangeSource(source, _activedSource);
  }

  void _videoListener() {
    if (mounted) {
      bool playing = _controller.value.isPlaying;
      if (playing != isPlaying) setState(() => isPlaying = playing);
      if (_showButtons) {
        if (isPlaying) {
          if (_timerPosition == null) _createBufferTimer();
          if (_closeOverlayButtons == null) _startCloseOverlayButtons();
        } else if (_isGoingToCloseBufferingWidget) _cancelCloseOverlayButtons();
      }
    }
  }

  //-----//
  //TIMER//
  //-----//
  void _startCloseOverlayButtons() {
    if (!_isGoingToCloseBufferingWidget) {
      setState(() {
        _isGoingToCloseBufferingWidget = true;
        _closeOverlayButtons = Timer(Duration(milliseconds: 3200), () {
          setState(() => _showButtons = false);
          _cancelCloseOverlayButtons();
        });
      });
    }
  }

  void _createBufferTimer() {
    setState(() {
      _timerPosition = Timer.periodic(Duration(milliseconds: 1000), (_) {
        int position = _controller.value.position.inMilliseconds;
        setState(() {
          if (isPlaying)
            isBuffering = _lastPosition != position ? false : true;
          else
            isBuffering = false;
          _lastPosition = position;
        });
      });
    });
  }

  void _cancelCloseOverlayButtons() {
    setState(() {
      _isGoingToCloseBufferingWidget = false;
      _closeOverlayButtons?.cancel();
      _closeOverlayButtons = null;
    });
  }

  void _onTapPlayAndPause() {
    setState(() {
      if (isPlaying)
        _controller.pause();
      else {
        _controller.play();
        _lastPosition = _lastPosition - 1;
        if (_showThumbnail) _showThumbnail = false;
      }
      if (!_showButtons) {
        _showAMomentPlayAndPause = true;
        _hidePlayAndPause?.cancel();
        _hidePlayAndPause = Timer(Duration(milliseconds: 600), () {
          setState(() => _showAMomentPlayAndPause = false);
        });
      } else if (isPlaying) _showButtons = false;
    });
  }

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _controllerSeekTo(int amount) async {
    int seconds = _controller.value.position.inSeconds;
    await _controller.seekTo(Duration(seconds: seconds + amount));
    await _controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _controllerSeekTo(amount);
    setState(() {
      _forwardAmount = amount;
      _showForwardStatus = true;
      _showAMomentRewindIcons[index] = true;
    });
    Misc.delayed(600, () {
      setState(() {
        _showForwardStatus = false;
        _showAMomentRewindIcons[index] = false;
      });
    });
  }

  void _forwardDragStart(DragStartDetails details) {
    if (!_showSettings)
      setState(() {
        _horizontalDragStartOffset = details.globalPosition;
        _showForwardStatus = true;
      });
  }

  void _forwardDragEnd() {
    if (!_showSettings) {
      setState(() => _showForwardStatus = false);
      _controllerSeekTo(_forwardAmount);
    }
  }

  void _forwardDragUpdate(DragUpdateDetails details) {
    if (!_showSettings) {
      double diff = _horizontalDragStartOffset.dx - details.globalPosition.dx;
      double multiplicator = (diff.abs() / 50);
      int seconds = _controller.value.position.inSeconds;
      int amount = -((diff / 10).round() * multiplicator).round();
      setState(() {
        if (seconds + amount < _controller.value.duration.inSeconds &&
            seconds + amount > 0) _forwardAmount = amount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      double padding = widget.style.progressBarStyle.paddingBeetwen;
      _progressBarBottomMargin =
          orientation == Orientation.landscape ? padding : padding / 2;

      if (orientation == Orientation.landscape) {
        Misc.delayed(100, () => Misc.setSystemOverlay([]));
      } else if (!isFullScreen) {
        Misc.delayed(100, () => Misc.setSystemOverlay(SystemOverlay.values));
      }

      return AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: _globalGesture(
          Stack(children: [
            VideoPlayer(_controller),
            if (_showThumbnail && widget.style.thumbnail != null)
              Container(child: widget.style.thumbnail),
            _rewindAndForward(),
            _overlayButtons(),
            _settingsIconButton(true),
            Center(
              child: _playAndPause(
                Container(
                  height: widget.style.playAndPauseStyle.circleSize * 2,
                  width: widget.style.playAndPauseStyle.circleSize * 2,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            OpacityTransition(
              curve: Curves.ease,
              duration: Duration(milliseconds: 400),
              visible: isBuffering,
              child: widget.style.buffering,
            ),
            OpacityTransition(
              curve: Curves.ease,
              duration: Duration(milliseconds: 400),
              visible: _showForwardStatus,
              child: _forwardAmountAlert(),
            ),
            OpacityTransition(
              curve: Curves.ease,
              duration: Duration(milliseconds: 400),
              visible: _showAMomentPlayAndPause,
              child: _playAndPauseIconButtons(),
            ),
            SettingsMenu(
              source: widget.source,
              visible: _showSettings,
              controller: _controller,
              activedSource: _activedSource,
              changeSource: _changeVideoSource,
              changeState: () => setState(() => _showSettings = !_showSettings),
            ),
            _rewindAndForwardIconsIndicator(),
          ]),
        ),
      );
    });
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _playAndPause(Widget child) =>
      GestureDetector(child: child, onTap: _onTapPlayAndPause);

  Widget _globalGesture(Widget child) {
    return GestureDetector(
      child: child,
      onHorizontalDragStart: (DragStartDetails details) =>
          _forwardDragStart(details),
      onHorizontalDragUpdate: (DragUpdateDetails details) =>
          _forwardDragUpdate(details),
      onHorizontalDragEnd: (DragEndDetails details) => _forwardDragEnd(),
      onTap: () {
        if (!_showSettings) {
          setState(() {
            _showButtons = !_showButtons;
            if (_showButtons) _isGoingToCloseBufferingWidget = false;
          });
        }
      },
    );
  }

  Widget _rewindAndForward() {
    return _rewindAndForwardLayout(
      rewind: GestureDetector(
          onDoubleTap: () => _showRewindAndForward(0, -widget.rewindAmount)),
      forward: GestureDetector(
          onDoubleTap: () => _showRewindAndForward(1, widget.forwardAmount)),
    );
  }

  //-------//
  //WIDGETS//
  //-------//
  Widget _rewindAndForwardLayout({Widget rewind, Widget forward}) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: GetContext.width(context) / 2),
      Expanded(child: forward),
    ]);
  }

  Widget _rewindAndForwardIconsIndicator() {
    return _rewindAndForwardLayout(
      rewind: OpacityTransition(
        visible: _showAMomentRewindIcons[0],
        child: Center(child: widget.style.rewind),
      ),
      forward: OpacityTransition(
        visible: _showAMomentRewindIcons[1],
        child: Center(child: widget.style.forward),
      ),
    );
  }

  Widget _playAndPauseIconButtons() {
    final style = widget.style.playAndPauseStyle;
    return Center(
      child: _playAndPause(!isPlaying ? style.playWidget : style.pauseWidget),
    );
  }

  Widget _forwardAmountAlert() {
    String text = secondsFormatter(_forwardAmount);
    final style = widget.style.forwardAndRewindStyle;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: style.padding,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: style.borderRadius,
        ),
        child: Text(text, style: style.textStyle),
      ),
    );
  }

  //---------------//
  //OVERLAY BUTTONS//
  //---------------//
  Widget _overlayButtons() {
    return Stack(children: [
      OpacityTransition(
        curve: Curves.ease,
        duration: Duration(milliseconds: 400),
        visible: _showButtons,
        child: Container(color: Colors.black.withOpacity(0.4)),
      ),
      SwipeTransition(
        visible: _showButtons,
        direction: SwipeDirection.fromTop,
        child: _settingsIconButton(),
      ),
      SwipeTransition(
        visible: _showButtons,
        child: _bottomProgressBar(),
      ),
      OpacityTransition(
        curve: Curves.ease,
        duration: Duration(milliseconds: 400),
        visible: _showButtons && !isPlaying,
        child: _playAndPauseIconButtons(),
      ),
    ]);
  }

  Widget _settingsIconButton([bool transparent = false]) {
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => setState(() => _showSettings = !_showSettings),
        child: Container(
          // decoration: !transparent
          //     ? BoxDecoration(
          //         gradient: RadialGradient(
          //           radius: 0.4,
          //           colors: [
          //             Colors.black.withOpacity(0.32),
          //             Colors.transparent
          //           ],
          //         ),
          //       )
          //     : null,
          child: Opacity(
              opacity: transparent ? 0 : 1, child: widget.style.settings),
          padding: Margin.all(widget.style.progressBarStyle.paddingBeetwen),
        ),
      ),
    );
  }

  Widget _bottomProgressBar() {
    VideoProgressBarStyle style = widget.style.progressBarStyle;
    String position = "00:00", remaing = "-00:00", duration = "00:00";
    double padding = style.paddingBeetwen;

    if (_controller.value.initialized) {
      final value = _controller.value;
      final seconds = value.position.inSeconds;
      position = secondsFormatter(seconds);
      duration = secondsFormatter(value.duration.inSeconds);
      remaing = secondsFormatter(seconds - value.duration.inSeconds);
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        //Expanded(child: _rewindAndForward()),
        // OpacityTransition(
        //   visible: _isDraggingProgress,
        //   child: _PreviewFrame(
        //     source: widget.source,
        //     seekTo: _seekToPosition,
        //     position: _controller.value.position,
        //     activedSource: _activedSource,
        //   ),
        // ),
        Expanded(child: SizedBox()),
        Container(
          padding: Margin.horizontal(padding) +
              Margin.only(
                  bottom: _progressBarBottomMargin,
                  top: _progressBarBottomMargin * 2),
          // decoration: BoxDecoration(
          //   gradient: LinearGradient(
          //     begin: Alignment.topCenter,
          //     end: Alignment.bottomCenter,
          //     tileMode: TileMode.mirror,
          //     colors: [Colors.transparent, Colors.black.withOpacity(0.32)],
          //   ),
          // ),
          child: Row(children: [
            Container(
              alignment: Alignment.center,
              color: Colors.transparent,
              child: Text(position, style: style.textStyle),
            ),
            SizedBox(width: padding),
            Expanded(
              child: VideoProgressBar(
                _controller,
                style: style,
                isBuffering: isBuffering,
                // changePosition: (double position) {
                //   if (mounted) {
                //     if (position != null)
                //       setState(() {
                //         _isDraggingProgress = true;
                //         _draggingProgressPosition = position;
                //       });
                //     else
                //       setState(() => _isDraggingProgress = false);
                //   }
                // },
              ),
            ),
            SizedBox(width: padding),
            Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => setState(() => _progressBarTextShowPosition =
                    !_progressBarTextShowPosition),
                child: Text(
                  _progressBarTextShowPosition ? duration : remaing,
                  style: style.textStyle,
                ),
              ),
            ),
            SizedBox(width: padding),
            GestureDetector(
              onTap: () {
                if (!isFullScreen) {
                  PushRoute.page(
                    context,
                    FullScreenPage(
                      style: widget.style,
                      source: widget.source,
                      looping: widget.looping,
                      controller: _controller,
                      rewindAmount: widget.rewindAmount,
                      forwardAmount: widget.forwardAmount,
                      activedSource: _activedSource,
                      defaultAspectRatio: widget.defaultAspectRatio,
                      changeSource: (controller, activedSource) {
                        _changeVideoSource(controller, activedSource, false);
                      },
                    ),
                    withTransition: false,
                  );
                } else {
                  Misc.setSystemOverlay(SystemOverlay.values);
                  Navigator.pop(context);
                }
              },
              child: isFullScreen
                  ? widget.style.fullScreenExit
                  : widget.style.fullScreen,
            ),
          ]),
        ),
      ]),
    );
  }
}

// class _PreviewFrame extends StatefulWidget {
//   _PreviewFrame({
//     Key key,
//     this.seekTo,
//     this.position,
//     this.source,
//     this.activedSource,
//   }) : super(key: key);

//   final Duration seekTo;
//   final double position;
//   final String activedSource;
//   final Map<String, VideoPlayerController> source;

//   @override
//   _PreviewFrameState createState() => _PreviewFrameState();
// }

// class _PreviewFrameState extends State<_PreviewFrame> {
//   VideoPlayerController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = widget.source[widget.activedSource]
//       ..initialize().then((_) async {
//         await controller.seekTo(widget.seekTo);
//         await controller.play();
//         controller.setVolume(0);
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     //disposeController();
//     super.dispose();
//   }

//   @override
//   void didUpdateWidget(_PreviewFrame oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     controller.seekTo(widget.seekTo);
//     controller.play();
//   }

//   void disposeController() async {
//     await controller?.pause();
//     await controller.dispose();
//     controller = null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 100,
//       color: Colors.white,
//       margin: Margin.left(widget.position - 50),
//       child: controller.value.initialized
//           ? AspectRatio(
//               aspectRatio: controller.value.aspectRatio,
//               child: VideoPlayer(controller))
//           : SizedBox(),
//     );
//   }
// }
