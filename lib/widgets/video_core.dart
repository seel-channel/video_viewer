import 'dart:async';
import 'package:flutter/services.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_viewer/widgets/settings_menu.dart';
import 'package:video_viewer/widgets/fullscreen.dart';
import 'package:video_viewer/widgets/progress.dart';
import 'package:video_viewer/utils/language.dart';
import 'package:video_viewer/utils/styles.dart';
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
    this.onChangeSource,
    this.exitFullScreen,
    this.onFullscreenFixLandscape,
    this.language = VideoViewerLanguage.en,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  final String activedSource;
  final bool looping;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoViewerStyle style;
  final VideoViewerLanguage language;
  final VideoPlayerController controller;
  final Map<String, VideoPlayerController> source;
  final bool onFullscreenFixLandscape;

  ///USE INSIDE THE SETTINGS MENU
  final void Function(VideoPlayerController, String) onChangeSource;

  ///USE INSIDE FULLSCREEN
  final void Function() exitFullScreen;

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
  int _lastPosition = 0, _forwardAmount = 0, _transitions = 0;

  //VOLUME
  bool _showVolumeStatus = false;
  double _maxVolume = 1, _onDragStartVolume = 1, _currentVolume = 1;
  Offset _verticalDragStartOffset;
  Timer _closeVolumeStatus;

  //TEXT POSITION ON DRAGGING
  final GlobalKey _playKey = GlobalKey();
  double _progressBarWidth = 0, _progressScale = 0, _iconPlayWidth = 0;
  bool _isDraggingProgress = false, _switchRemaingText = false;

  //LANDSCAPE
  double _progressBarMargin = 0;
  VideoViewerStyle _style, _landscapeStyle;

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
    _transitions = _style.transitions;
    _activedSource = widget.activedSource;
    _landscapeStyle = _getResponsiveText();
    _controller.addListener(_videoListener);
    _controller.setLooping(widget.looping);
    _showThumbnail = _style.thumbnail == null ? false : true;
    if (!_showThumbnail)
      Misc.onLayoutRendered(() {
        _changeIconPlayWidth();
      });
    //_initAudioStreamType();
    //_updateVolumes();
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
      if (_isPlaying && _isDraggingProgress) _isDraggingProgress = false;
      if (_showButtons) {
        if (_isPlaying) {
          if (value.position >= value.duration && !widget.looping) {
            _controller.seekTo(Duration.zero);
          } else {
            if (_timerPosition == null) _createBufferTimer();
            if (_closeOverlayButtons == null && !_isDraggingProgress)
              _startCloseOverlayButtons();
          }
        } else if (_isGoingToCloseBufferingWidget) _cancelCloseOverlayButtons();
      }
      setState(() {});
    }
  }

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
    if (widget.onChangeSource != null) //Only used in fullscreenpage
      widget.onChangeSource(_controller, _activedSource);
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

  void _changeIconPlayWidth() {
    Misc.delayed(
      800,
      () => setState(() => _iconPlayWidth = GetKey.width(_playKey)),
    );
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

  //----------//
  //FULLSCREEN//
  //----------//
  void toFullscreen() {
    if (kIsWeb) {
      html.document.documentElement.onFullscreenChange.listen((_) {
        setState(() => _isFullScreen = html.document.fullscreenElement != null);
      });
      html.document.documentElement.requestFullscreen();
    } else
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => FullScreenPage(
            style: _style,
            source: widget.source,
            looping: widget.looping,
            controller: _controller,
            rewindAmount: widget.rewindAmount,
            forwardAmount: widget.forwardAmount,
            activedSource: _activedSource,
            fixedLandscape: widget.onFullscreenFixLandscape,
            defaultAspectRatio: widget.defaultAspectRatio,
            changeSource: (controller, activedSource) {
              _changeVideoSource(controller, activedSource, false);
            },
          ),
        ),
      );
  }

  void _exitFullscreen() {
    if (kIsWeb) {
      html.document.exitFullscreen();
    } else if (widget.exitFullScreen != null) widget.exitFullScreen();
  }

  //-----------------//
  //VOLUME CONTROLLER//
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
    if (!_showSettings) {
      _closeVolumeStatus?.cancel();
      setState(() {
        _verticalDragStartOffset = details.globalPosition;
        _showVolumeStatus = true;
      });
      _updateVolumes();
    }
  }

  void _volumeDragUpdate(DragUpdateDetails details) {
    if (!_showSettings) {
      double diff = _verticalDragStartOffset.dy - details.globalPosition.dy;
      double volume = (diff / 100) + _onDragStartVolume;
      _setVolume(volume);
    }
  }

  void _volumeDragEnd() {
    if (!_showSettings)
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

  //-------------//
  //VOLUME NATIVE//
  //-------------//
  // void _initAudioStreamType() async {
  //   if (_isAndroid) await Volume.controlVolume(AudioManager.STREAM_MUSIC);
  // }

  // void _updateVolumes() async {
  //   if (_isAndroid) {
  //     _maxVolume = await Volume.getMaxVol;
  //     _onDragStartVolume = await Volume.getVol;
  //     _currentVolume = _onDragStartVolume;
  //     if (mounted) setState(() {});
  //   }
  // }

  // void _setVolume(int volume) async {
  //   if (_isAndroid) {
  //     await Volume.setVol(volume, showVolumeUI: ShowVolumeUI.HIDE);
  //     setState(() => _currentVolume = volume);
  //   }
  // }

  // void _volumeDragStart(DragStartDetails details) {
  //   if (!_showSettings && _isAndroid) {
  //     _closeVolumeStatus?.cancel();
  //     setState(() {
  //       _verticalDragStartOffset = details.globalPosition;
  //       _showVolumeStatus = true;
  //     });
  //     _updateVolumes();
  //   }
  // }

  // void _volumeDragUpdate(DragUpdateDetails details) {
  //   if (!_showSettings && _isAndroid) {
  //     double diff = _verticalDragStartOffset.dy - details.globalPosition.dy;
  //     int volume = (diff / 15).round() + _onDragStartVolume;
  //     if (volume <= _maxVolume && volume >= 0) _setVolume(volume);
  //   }
  // }

  // void _volumeDragEnd() {
  //   if (!_showSettings && _isAndroid)
  //     setState(() {
  //       _closeVolumeStatus = Misc.timer(600, () {
  //         setState(() => _showVolumeStatus = false);
  //       });
  //     });
  // }

  //-----//
  //BUILD//
  //-----//
  @override
  Widget build(BuildContext context) {
    final double width = GetContext.width(context);

    return OrientationBuilder(builder: (_, orientation) {
      Orientation landscape = Orientation.landscape;
      double padding = _style.progressBarStyle.paddingBeetwen;

      _progressBarMargin = orientation == landscape ? padding * 2 : padding;
      _style = kIsWeb
          ? width > 1400
              ? _getResponsiveText(
                  widget.style.inLandscapeEnlargeTheTextBy * (width / 1400))
              : _landscapeStyle
          : orientation == landscape
              ? _landscapeStyle
              : widget.style;

      return _isFullScreen && orientation == landscape
          ? _player(orientation)
          : _playerAspectRatio(_player(orientation));
    });
  }

  Widget _player(Orientation orientation) {
    return _globalGesture(
      Stack(children: [
        _fadeTransition(
          visible: !_showThumbnail,
          child: _isFullScreen && orientation == Orientation.landscape
              ? Center(child: _playerAspectRatio(VideoPlayer(_controller)))
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
                child: Container(color: Colors.transparent),
              ),
        _fadeTransition(
          visible: _showThumbnail,
          child: GestureDetector(
            onTap: () => setState(() {
              _controller.play();
              _changeIconPlayWidth();
            }),
            child: Container(
              color: Colors.transparent,
              child: _style.thumbnail,
            ),
          ),
        ),
        _rewindAndForward(),
        _fadeTransition(
          visible: !_showThumbnail,
          child: _overlayButtons(),
        ),
        Center(
          child: _playAndPause(
            Container(
              height: GetContext.height(context) * 0.2,
              width: GetContext.width(context) * 0.2,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        _fadeTransition(
          visible: _isBuffering,
          child: _style.buffering,
        ),
        _fadeTransition(
          visible: _showForwardStatus,
          child: _forwardAmountAlert(),
        ),
        _fadeTransition(
          visible: _showAMomentPlayAndPause ||
              _controller.value.position >= _controller.value.duration,
          child: _playAndPauseIconButtons(),
        ),
        _swipeTransition(
          visible: _showVolumeStatus,
          direction: _style.volumeBarStyle.alignment == Alignment.centerLeft
              ? SwipeDirection.fromLeft
              : SwipeDirection.fromRight,
          child: VideoVolumeBar(
            style: widget.style.volumeBarStyle,
            progress: (_currentVolume / _maxVolume),
          ),
        ),
        SettingsMenu(
          style: _style,
          source: widget.source,
          visible: _showSettings,
          language: widget.language,
          controller: _controller,
          activedSource: _activedSource,
          changeSource: _changeVideoSource,
          changeVisible: () => setState(() => _showSettings = !_showSettings),
        ),
        _rewindAndForwardIconsIndicator(),
      ]),
    );
  }

  VideoViewerStyle _getResponsiveText([double multiplier = 1]) {
    final style = widget.style;
    return mergeVideoViewerStyle(
      style: style,
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
      child: GestureDetector(
        //VOLUME
        onVerticalDragStart: (DragStartDetails details) =>
            _volumeDragStart(details),
        onVerticalDragUpdate: (DragUpdateDetails details) =>
            _volumeDragUpdate(details),
        onVerticalDragEnd: (DragEndDetails details) => _volumeDragEnd(),
        //FORWARD AND REWINDR
        onHorizontalDragStart: (DragStartDetails details) =>
            _forwardDragStart(details),
        onHorizontalDragUpdate: (DragUpdateDetails details) =>
            _forwardDragUpdate(details),
        onHorizontalDragEnd: (DragEndDetails details) => _forwardDragEnd(),
        child: child,
      ),
    );
  }

  Widget _playAndPause(Widget child) {
    return GestureDetector(child: child, onTap: _onTapPlayAndPause);
  }

  //------------------//
  //TRANSITION WIDGETS//
  //------------------//
  Widget _fadeTransition({bool visible, Widget child}) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: _transitions),
      visible: visible,
      child: child,
    );
  }

  Widget _swipeTransition(
      {bool visible, Widget child, SwipeDirection direction}) {
    return SwipeTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: _transitions),
      direction: direction,
      visible: visible,
      child: child,
    );
  }

  //------//
  //REWIND//
  //------//

  Widget _rewindAndForward() {
    return _rewindAndForwardLayout(
      rewind: GestureDetector(onDoubleTap: _rewind),
      forward: GestureDetector(onDoubleTap: () => _forward),
    );
  }

  Widget _rewindAndForwardLayout({Widget rewind, Widget forward}) {
    return Row(children: [
      Expanded(child: rewind),
      SizedBox(width: GetContext.width(context) / 2),
      Expanded(child: forward),
    ]);
  }

  Widget _rewindAndForwardIconsIndicator() {
    final style = _style.forwardAndRewindStyle;
    return _rewindAndForwardLayout(
      rewind: _fadeTransition(
        visible: _showAMomentRewindIcons[0],
        child: Center(child: style.rewind),
      ),
      forward: _fadeTransition(
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

  //---------------//
  //OVERLAY BUTTONS//
  //---------------//
  Widget _playAndPauseIconButtons() {
    final style = _style.playAndPauseStyle;
    return Center(
      child: _playAndPause(!_isPlaying ? style.playWidget : style.pauseWidget),
    );
  }

  Widget _overlayButtons() {
    return Stack(children: [
      _swipeTransition(
        direction: SwipeDirection.fromBottom,
        visible: _showButtons,
        child: _bottomProgressBar(),
      ),
      _fadeTransition(
        visible: _showButtons && !_isPlaying,
        child: _playAndPauseIconButtons(),
      ),
    ]);
  }

  //-------------------//
  //BOTTOM PROGRESS BAR//
  //-------------------//
  Widget _containerPadding({Widget child}) {
    return Container(
      color: Colors.transparent,
      padding: Margin.vertical(_progressBarMargin),
      child: child,
    );
  }

  Widget _settingsIconButton() {
    double padding = _style.progressBarStyle.paddingBeetwen;
    return Align(
      alignment: Alignment.topRight,
      child: GestureDetector(
        onTap: () => setState(() => _showSettings = !_showSettings),
        child: Container(
          color: Colors.transparent,
          child: _style.settingsStyle.settings,
          padding:
              Margin.horizontal(padding) + Margin.vertical(_progressBarMargin),
        ),
      ),
    );
  }

  Widget _textPositionProgress(String position) {
    double width = 60;
    double margin =
        (_progressScale * _progressBarWidth) + _iconPlayWidth - (width / 2);
    return OpacityTransition(
      visible: _isDraggingProgress,
      child: Container(
        width: width,
        child: Text(position, style: _style.textStyle),
        margin: Margin.left(margin < 0 ? 0 : margin),
        padding: Margin.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: _style.progressBarStyle.backgroundColor,
            borderRadius: _style.progressBarStyle.borderRadius),
      ),
    );
  }

  Widget _bottomProgressBar() {
    ProgressBarStyle style = _style.progressBarStyle;
    String position = "00:00", remaing = "-00:00";
    double padding = style.paddingBeetwen;

    if (_controller.value.initialized) {
      final value = _controller.value;
      final seconds = value.position.inSeconds;
      position = secondsFormatter(seconds);
      remaing = secondsFormatter(seconds - value.duration.inSeconds);
    }

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: SizedBox()),
        _textPositionProgress(position),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                _style.progressBarStyle.backgroundColor
              ],
            ),
          ),
          child: Row(children: [
            _playAndPause(Container(
                key: _playKey,
                padding: Margin.symmetric(
                  horizontal: padding,
                  vertical: _progressBarMargin,
                ),
                child: !_isPlaying
                    ? _style.playAndPauseStyle.play
                    : _style.playAndPauseStyle.pause)),
            Expanded(
              child: VideoProgressBar(
                _controller,
                style: style,
                padding: Margin.vertical(_progressBarMargin),
                isBuffering: _isBuffering,
                changePosition: (double scale, double width) {
                  if (mounted) {
                    if (scale != null) {
                      setState(() {
                        _isDraggingProgress = true;
                        _progressScale = scale;
                        _progressBarWidth = width;
                      });
                      _cancelCloseOverlayButtons();
                    } else {
                      setState(() => _isDraggingProgress = false);
                      _startCloseOverlayButtons();
                    }
                  }
                },
              ),
            ),
            SizedBox(width: padding),
            Container(
              color: Colors.transparent,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() => _switchRemaingText = !_switchRemaingText);
                  _cancelCloseOverlayButtons();
                },
                child: _containerPadding(
                  child: Text(
                    _switchRemaingText ? position : remaing,
                    style: _style.textStyle,
                  ),
                ),
              ),
            ),
            _settingsIconButton(),
            GestureDetector(
              onTap: () async {
                if (!_isFullScreen)
                  toFullscreen();
                else
                  _exitFullscreen();
              },
              child: _containerPadding(
                child: _isFullScreen ? style.fullScreenExit : style.fullScreen,
              ),
            ),
            SizedBox(width: padding),
          ]),
        ),
      ]),
    );
  }
}
