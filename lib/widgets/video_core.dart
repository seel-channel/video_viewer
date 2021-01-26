import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/helpers.dart';
import 'package:video_viewer/widgets/overlay/overlay.dart';
import 'package:video_viewer/widgets/overlay/widgets/play_and_pause.dart';

import 'package:video_viewer/widgets/progress.dart';
import 'package:video_viewer/utils/misc.dart';

class VideoViewerCore extends StatefulWidget {
  ///IS THE VIDEOVIEWER CORE
  VideoViewerCore({
    Key key,
    @required this.controller,
    @required this.source,
    VideoViewerStyle style,
    this.activedSource,
    this.looping,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.exitFullScreen,
    this.onFullscreenFixLandscape,
    this.language = VideoViewerLanguage.en,
    this.settingsMenuItems,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  final String activedSource;
  final bool looping;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoViewerStyle style;
  final VideoViewerLanguage language;
  final VideoPlayerController controller;
  final Map<String, VideoSource> source;
  final bool onFullscreenFixLandscape;

  ///USE INSIDE FULLSCREEN
  final void Function() exitFullScreen;

  final List<SettingsMenuItem> settingsMenuItems;

  @override
  VideoViewerCoreState createState() => VideoViewerCoreState();
}

class VideoViewerCoreState extends State<VideoViewerCore> {
  VideoPlayerController _controller;
  bool _isPlaying = false,
      _isBuffering = false,
      _isFullScreen = false,
      _showButtons = false,
      _showSettings = false,
      _showThumbnail = true,
      _showAMomentPlayAndPause = false,
      _isGoingToCloseBufferingWidget = false;
  Timer _closeOverlayButtons, _timerPosition, _hidePlayAndPause;
  String _activedSource;

  //REWIND AND FORWARD
  bool _showForwardStatus = false;
  Offset _horizontalDragStartOffset;
  List<bool> _showAMomentRewindIcons = [false, false];
  int _lastPosition = 0, _forwardAmount = 0;

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

  //ONLY USE ON FULLSCREENPAGE
  set fullScreen(bool value) {
    _isFullScreen = value;
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    _style = widget.style;
    _controller = widget.controller;
    _activedSource = widget.activedSource;
    _landscapeStyle = _getResponsiveText();
    _controller.addListener(_videoListener);
    _controller.setLooping(widget.looping);
    _showThumbnail = _style.thumbnail == null ? false : true;
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

  //----------------//
  //VIDEO CONTROLLER//
  //----------------//
  void _videoListener() {
    if (mounted) {
      final value = _controller.value;
      final playing = value.isPlaying;

      if (playing != _isPlaying) _isPlaying = playing;
      if (_isPlaying && _showThumbnail) _showThumbnail = false;
      if (_showButtons) {
        if (_isPlaying) {
          if (value.position >= value.duration && !widget.looping) {
            _controller.seekTo(Duration.zero);
          } else {
            if (_timerPosition == null) _createBufferTimer();
            if (_closeOverlayButtons == null) _startCloseOverlayButtons();
          }
        } else if (_isGoingToCloseBufferingWidget) _cancelCloseOverlayButtons();
      }
      setState(() {});
    }
  }

  //-----//
  //TIMER//
  //-----//
  void _startCloseOverlayButtons() {
    if (!_isGoingToCloseBufferingWidget && mounted) {
      setState(() {
        _isGoingToCloseBufferingWidget = true;
        _closeOverlayButtons = Misc.timer(3200, () {
          if (mounted && _isPlaying) {
            setState(() => _showButtons = false);
            _cancelCloseOverlayButtons();
          }
        });
      });
    }
  }

  void _createBufferTimer() {
    if (mounted)
      setState(() {
        _timerPosition = Misc.periodic(1000, () {
          int position = _controller.value.position.inMilliseconds;
          if (mounted)
            setState(() {
              if (_isPlaying)
                _isBuffering = _lastPosition != position ? false : true;
              else
                _isBuffering = false;
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

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
  void _onTapPlayAndPause() {
    final value = _controller.value;
    setState(() {
      if (_isPlaying)
        _controller.pause();
      else {
        if (value.position >= value.duration) _controller.seekTo(Duration.zero);
        _lastPosition = _lastPosition - 1;
        _controller.play();
      }
      if (!_showButtons) {
        _showAMomentPlayAndPause = true;
        _hidePlayAndPause?.cancel();
        _hidePlayAndPause = Misc.timer(600, () {
          setState(() => _showAMomentPlayAndPause = false);
        });
      } else if (_isPlaying) _showButtons = false;
    });
  }

  void _showAndHideOverlay([bool show]) {
    setState(() {
      _showButtons = show ?? !_showButtons;
      if (_showButtons) _isGoingToCloseBufferingWidget = false;
    });
    if (!_focusRawKeyboard.hasFocus)
      FocusScope.of(context).requestFocus(_focusRawKeyboard);
  }

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _rewind() => _showRewindAndForward(0, -widget.rewindAmount);
  void _forward() => _showRewindAndForward(1, widget.forwardAmount);

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
            seconds + amount > 0) _forwardAmount = amount;
      });
    }
  }

  void _forwardDragEnd() {
    if (!_showSettings && _showForwardStatus) {
      setState(() => _showForwardStatus = false);
      _controllerSeekTo(_forwardAmount);
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
                  widget.style.inLandscapeEnlargeTheTextBy * (width / 1400))
              : _landscapeStyle
          : orientation == landscape
              ? _landscapeStyle
              : widget.style;

      return fullScreenLandscape
          ? _player(orientation, fullScreenLandscape)
          : _playerAspectRatio(_player(orientation, fullScreenLandscape));
    });
  }

  Widget _player(Orientation orientation, bool fullScreenLandscape) {
    final Size size = GetMedia(context).size;

    return _globalGesture(
      Stack(children: [
        CustomOpacityTransition(
          visible: !_showThumbnail,
          child: fullScreenLandscape
              ? Transform.scale(
                  scale: _scale,
                  child: Center(
                    child: _playerAspectRatio(VideoPlayer(_controller)),
                  ))
              : VideoPlayer(_controller),
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
          visible: _showThumbnail,
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
          visible: !_showThumbnail,
          child: VideoOverlay(
            visible: _showButtons,
            videoListener: _videoListener,
            onTapPlayAndPause: _onTapPlayAndPause,
            cancelOverlayTimer: _cancelCloseOverlayButtons,
          ),
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
          child: _forwardAmountAlert(),
        ),
        CustomOpacityTransition(
          visible: _showAMomentPlayAndPause ||
              _controller.value.position >= _controller.value.duration,
          child: PlayAndPause(onTap: _onTapPlayAndPause),
        ),
        CustomSwipeTransition(
          visible: _showVolumeStatus,
          direction: _style.volumeBarStyle.alignment == Alignment.centerLeft
              ? SwipeDirection.fromLeft
              : SwipeDirection.fromRight,
          child: VideoVolumeBar(
            style: widget.style.volumeBarStyle,
            progress: (_currentVolume / _maxVolume),
          ),
        ),
        // CustomOpacityTransition(
        //   visible: _showSettings,
        //   child: SettingsMenu(
        //     onChangeVisible: () =>
        //         setState(() => _showSettings = !_showSettings),
        //     videoListener: _videoListener,
        //   ),
        // ),
        _rewindAndForwardIconsIndicator(),
      ]),
    );
  }

  VideoViewerStyle _getResponsiveText([double multiplier = 1]) {
    final VideoViewerStyle style = widget.style;
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
    return GestureDetector(child: child, onTap: _onTapPlayAndPause);
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

  Widget _forwardAmountAlert() {
    String text = secondsFormatter(_forwardAmount);
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
