import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/widgets/overlay/widgets/play_and_pause.dart';
import 'package:video_viewer/widgets/overlay/overlay.dart';
import 'package:video_viewer/widgets/progress.dart';
import 'package:video_viewer/widgets/helpers.dart';
import 'package:video_viewer/utils/misc.dart';

class VideoViewerCore extends StatefulWidget {
  VideoViewerCore({Key key}) : super(key: key);

  @override
  VideoViewerCoreState createState() => VideoViewerCoreState();
}

class VideoViewerCoreState extends State<VideoViewerCore> {
  final VideoQuery _query = VideoQuery();
  VideoPlayerController _controller;
  bool _isBuffering = false,
      _isFullScreen = false,
      _showButtons = false,
      _showSettings = false,
      _showAMomentPlayAndPause = false;
  Timer _closeOverlayButtons, _timerPosition, _hidePlayAndPause;

  //REWIND AND FORWARD
  int _defaultRewindAmount = 10;
  int _defaultForwardAmount = 10;
  int _forwardAndRewindAmount = 0;
  bool _showForwardStatus = false;
  Offset _horizontalDragStartOffset;
  List<bool> _showAMomentRewindIcons = [false, false];

  //VOLUME
  double _maxVolume = 1, _onDragStartVolume = 1, _currentVolume = 1;
  Offset _verticalDragStartOffset;
  bool _showVolumeStatus = false;
  Timer _closeVolumeStatus;

  //LANDSCAPE
  VideoViewerStyle _style, _landscapeStyle;
  double _progressBarMargin = 0;

  //VIDEO ZOOM
  double _scale = 1.0, _maxScale = 1.0, _minScale = 1.0, _initialScale = 1.0;
  int _pointers = 0;

  //WEB
  final FocusNode _focusRawKeyboard = FocusNode();

  @override
  void initState() {
    _style = _style;
    _landscapeStyle = _getResponsiveText();
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      _style = metadata.style;
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusRawKeyboard.dispose();
    _timerPosition?.cancel();
    _hidePlayAndPause?.cancel();
    _closeOverlayButtons?.cancel();
    super.dispose();
  }

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
  void _onTapPlayAndPause() async {
    final video = _query.video(context);
    await video.onTapPlayAndPause();
    if (!video.showOverlay) {
      _showAMomentPlayAndPause = true;
      _hidePlayAndPause?.cancel();
      _hidePlayAndPause = Misc.timer(600, () {
        setState(() => _showAMomentPlayAndPause = false);
      });
    }
    setState(() {});
  }

  void _showAndHideOverlay([bool show]) {
    _query.video(context).showAndHideOverlay(show);
    if (!_focusRawKeyboard.hasFocus)
      FocusScope.of(context).requestFocus(_focusRawKeyboard);
  }

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _rewind() => _showRewindAndForward(0, -_defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  void _controllerSeekTo(int amount) async {
    final controller = _query.video(context).controller;
    final seconds = controller.value.position.inSeconds;
    await controller.seekTo(Duration(seconds: seconds + amount));
    await controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _controllerSeekTo(amount);
    setState(() {
      _forwardAndRewindAmount = amount;
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
    if (!_showSettings && _pointers == 1)
      setState(() {
        _horizontalDragStartOffset = details.globalPosition;
        _showForwardStatus = true;
      });
  }

  void _forwardDragUpdate(DragUpdateDetails details) {
    if (!_showSettings && _pointers == 1) {
      double diff = _horizontalDragStartOffset.dx - details.globalPosition.dx;
      double multiplicator = (diff.abs() / 50);
      int seconds = _controller.value.position.inSeconds;
      int amount = -((diff / 10).round() * multiplicator).round();
      setState(() {
        if (seconds + amount < _controller.value.duration.inSeconds &&
            seconds + amount > 0) _forwardAndRewindAmount = amount;
      });
    }
  }

  void _forwardDragEnd() {
    if (!_showSettings && _showForwardStatus) {
      setState(() => _showForwardStatus = false);
      _controllerSeekTo(_forwardAndRewindAmount);
    }
  }

  //-----------------//
  //CONTROLLER VOLUME//
  //-----------------//
  void _updateVolumes() {
    _maxVolume = 1.0;
    _onDragStartVolume = _controller.value.volume;
    _currentVolume = _onDragStartVolume;
    if (mounted) setState(() {});
  }

  void _setVolume(double volume) async {
    if (volume <= _maxVolume && volume >= 0) {
      final double fractional = _maxVolume * 0.05;
      if (volume >= _maxVolume - fractional) volume = _maxVolume;
      if (volume <= fractional) volume = 0.0;
      await _controller.setVolume(volume);
      setState(() => _currentVolume = volume);
    }
  }

  void _volumeDragStart(DragStartDetails details) {
    if (!_showSettings && _pointers == 1) {
      _closeVolumeStatus?.cancel();
      setState(() {
        _verticalDragStartOffset = details.globalPosition;
        _showVolumeStatus = true;
      });
      _updateVolumes();
    }
  }

  void _volumeDragUpdate(DragUpdateDetails details) {
    if (!_showSettings && _pointers == 1) {
      double diff = _verticalDragStartOffset.dy - details.globalPosition.dy;
      double volume = (diff / 125) + _onDragStartVolume;
      _setVolume(volume);
    }
  }

  void _volumeDragEnd() {
    if (!_showSettings && _showVolumeStatus)
      setState(() {
        _closeVolumeStatus = Misc.timer(600, () {
          setState(() {
            _closeVolumeStatus?.cancel();
            _closeVolumeStatus = null;
            _showVolumeStatus = false;
          });
        });
      });
  }

  void _onKeypressVolume(bool isArrowUp) {
    _showVolumeStatus = true;
    _closeVolumeStatus?.cancel();
    _setVolume(_currentVolume + (isArrowUp ? 0.1 : -0.1));
    _volumeDragEnd();
  }

  //-----//
  //BUILD//
  //-----//
  @override
  Widget build(BuildContext context) {
    final double width = GetMedia(context).width;

    return OrientationBuilder(builder: (_, orientation) {
      Orientation landscape = Orientation.landscape;
      double padding = _style.progressBarStyle.paddingBeetwen;
      bool fullScreenLandscape = _isFullScreen && orientation == landscape;

      _progressBarMargin = orientation == landscape ? padding * 2 : padding;
      _style = kIsWeb
          ? width > 1400
              ? _getResponsiveText(
                  _style.inLandscapeEnlargeTheTextBy * (width / 1400))
              : _landscapeStyle
          : orientation == landscape
              ? _landscapeStyle
              : _style;

      return fullScreenLandscape
          ? _player(orientation, fullScreenLandscape)
          : _playerAspectRatio(_player(orientation, fullScreenLandscape));
    });
  }

  Widget _player(Orientation orientation, bool fullScreenLandscape) {
    final Size size = GetMedia(context).size;
    final video = _query.video(context, listen: true);

    return _globalGesture(
      Stack(children: [
        CustomOpacityTransition(
          visible: !video.showThumbnail,
          child: fullScreenLandscape
              ? Transform.scale(
                  scale: _scale,
                  child: Center(
                    child: _playerAspectRatio(VideoPlayer(_controller)),
                  ))
              : VideoPlayer(video.controller),
        ),
        kIsWeb
            ? MouseRegion(
                onHover: (_) {
                  if (!_showButtons) _showAndHideOverlay(true);
                },
                child: GestureDetector(
                  onTap: _showAndHideOverlay,
                  child: Container(color: Colors.transparent),
                ),
              )
            : GestureDetector(
                onTap: _showAndHideOverlay,
                onScaleStart: fullScreenLandscape
                    ? (_) => setState(() {
                          final double aspectWidth =
                              size.height * _controller.value.aspectRatio;
                          _initialScale = _scale;
                          _maxScale = size.width / aspectWidth;
                        })
                    : null,
                onScaleUpdate: fullScreenLandscape
                    ? (details) {
                        final double newScale = _initialScale * details.scale;
                        if (newScale >= _minScale && newScale <= _maxScale)
                          setState(() => _scale = newScale);
                      }
                    : null,
                child: Container(color: Colors.transparent),
              ),
        CustomOpacityTransition(
          visible: video.showThumbnail,
          child: GestureDetector(
            onTap: () => setState(() => _controller.play()),
            child: Container(
              color: Colors.transparent,
              child: _style.thumbnail,
            ),
          ),
        ),
        _rewindAndForward(),
        CustomOpacityTransition(
          visible: !video.showThumbnail,
          child: VideoOverlay(),
        ),
        Center(
          child: _playAndPause(
            Container(
              width: size.width * 0.2,
              height: size.height * 0.2,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        CustomOpacityTransition(
          visible: _isBuffering,
          child: _style.buffering,
        ),
        CustomOpacityTransition(
          visible: _showForwardStatus,
          child: _forwardAndRewindAmountAlert(),
        ),
        AnimatedBuilder(
          animation: video.controller,
          builder: (_, __) {
            final position = video.controller.value.position;
            final duration = video.controller.value.duration;
            return CustomOpacityTransition(
              visible: _showAMomentPlayAndPause || position >= duration,
              child: PlayAndPause(type: PlayAndPauseType.center),
            );
          },
        ),
        CustomSwipeTransition(
          visible: _showVolumeStatus,
          direction: _style.volumeBarStyle.alignment == Alignment.centerLeft
              ? SwipeDirection.fromLeft
              : SwipeDirection.fromRight,
          child: VideoVolumeBar(
            style: _style.volumeBarStyle,
            progress: (_currentVolume / _maxVolume),
          ),
        ),
        _rewindAndForwardIconsIndicator(),
      ]),
    );
  }

  VideoViewerStyle _getResponsiveText([double multiplier = 1]) {
    final VideoViewerStyle style = _style;
    return style.copywith(
      textStyle: style.textStyle.merge(
        TextStyle(
          fontSize: style.textStyle.fontSize +
              style.inLandscapeEnlargeTheTextBy * multiplier,
        ),
      ),
    );
  }

  Widget _playerAspectRatio(Widget child) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: child,
    );
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(Widget child) {
    return RawKeyboardListener(
      focusNode: _focusRawKeyboard,
      onKey: (e) {
        final key = e.logicalKey;
        if (e.runtimeType.toString() == 'RawKeyDownEvent') {
          if (key == LogicalKeyboardKey.space)
            _onTapPlayAndPause();
          else if (key == LogicalKeyboardKey.arrowLeft)
            _rewind();
          else if (key == LogicalKeyboardKey.arrowRight)
            _forward();
          else if (key == LogicalKeyboardKey.arrowUp)
            _onKeypressVolume(true);
          else if (key == LogicalKeyboardKey.arrowDown)
            _onKeypressVolume(false);
        }
      },
      child: Listener(
        onPointerDown: (event) => _pointers++,
        onPointerUp: (event) => _pointers--,
        child: GestureDetector(
          //VOLUME
          onVerticalDragStart: _volumeDragStart,
          onVerticalDragUpdate: _volumeDragUpdate,
          onVerticalDragEnd: (_) => _volumeDragEnd(),
          //FORWARD AND REWIND
          onHorizontalDragStart: _forwardDragStart,
          onHorizontalDragUpdate: _forwardDragUpdate,
          onHorizontalDragEnd: (_) => _forwardDragEnd(),
          child: child,
        ),
      ),
    );
  }

  Widget _playAndPause(Widget child) {
    return GestureDetector(
      onTap: _onTapPlayAndPause,
      child: child,
      behavior: HitTestBehavior.opaque,
    );
  }

  //------//
  //REWIND//
  //------//
  Widget _rewindAndForward() {
    return _rewindAndForwardLayout(
      rewind: GestureDetector(onDoubleTap: _rewind),
      forward: GestureDetector(onDoubleTap: _forward),
    );
  }

  Widget _rewindAndForwardLayout({Widget rewind, Widget forward}) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: GetMedia(context).width / 2),
      Expanded(child: forward),
    ]);
  }

  Widget _rewindAndForwardIconsIndicator() {
    final style = _style.forwardAndRewindStyle;
    return _rewindAndForwardLayout(
      rewind: CustomOpacityTransition(
        visible: _showAMomentRewindIcons[0],
        child: Center(child: style.rewind),
      ),
      forward: CustomOpacityTransition(
        visible: _showAMomentRewindIcons[1],
        child: Center(child: style.forward),
      ),
    );
  }

  Widget _forwardAndRewindAmountAlert() {
    String text = secondsFormatter(_forwardAndRewindAmount);
    final style = _style.forwardAndRewindStyle;
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: style.padding,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: style.borderRadius,
        ),
        child: Text(text, style: _style.textStyle),
      ),
    );
  }
}
