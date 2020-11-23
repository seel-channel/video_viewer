import 'dart:async';
import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/utils/styles.dart';
import 'package:video_viewer/widgets/misc.dart';
import 'package:video_viewer/widgets/progress.dart';

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
    this.exitFullScreen,
  }) : super(key: key);

  final String activedSource;
  final bool looping;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoViewerStyle style;
  final VideoPlayerController controller;
  final Map<String, VideoPlayerController> source;
  final void Function(VideoPlayerController, String) onChangeSource;
  final void Function() exitFullScreen;

  @override
  VideoReadyState createState() => VideoReadyState();
}

class VideoReadyState extends State<VideoReady> {
  VideoPlayerController _controller;
  bool _isPlaying = false,
      _isBuffering = false,
      _isFullScreen = false,
      _showButtons = false,
      _showSettings = false,
      _showThumbnail = true,
      _showForwardStatus = false,
      _showAMomentPlayAndPause = false,
      _progressBarTextShowPosition = false,
      _isGoingToCloseBufferingWidget = false;
  Timer _closeOverlayButtons, _timerPosition, _hidePlayAndPause;
  List<bool> _showAMomentRewindIcons = [false, false];
  String _activedSource;
  Offset _horizontalDragStartOffset;
  int _lastPosition = 0, _forwardAmount = 0, _transitions = 0;
  double _progressBarMargin = 0;

  //TEXT POSITION ON DRAGGING
  bool _isDraggingProgress = false;
  double _progressBarWidth = 0, _progressScale = 0, _iconPlayWidth = 0;
  GlobalKey _playKey = GlobalKey();

  //LANDSCAPE
  Orientation _orientation;
  VideoViewerStyle _style, _landscapeStyle;

  set fullScreen(bool value) => setState(() => _isFullScreen = value);

  @override
  void initState() {
    _style = widget.style;
    _landscapeStyle = mergeVideoViewerStyle(
        style: widget.style,
        textStyle: TextStyle(
          fontSize: widget.style.textStyle.fontSize +
              widget.style.inLandscapeEnlargeTheTextBy,
        ));
    _transitions = _style.transitions;
    _controller = widget.controller;
    _activedSource = widget.activedSource;
    _controller.addListener(_videoListener);
    _controller.setLooping(widget.looping);
    _showThumbnail = _style.thumbnail == null ? false : true;
    if (!_showThumbnail) Misc.onLayoutRendered(() => _changeIconPlayWidth());
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
    if (widget.onChangeSource != null) //Only used in fullscreenpage
      widget.onChangeSource(_controller, _activedSource);
  }

  void _videoListener() {
    if (mounted) {
      final value = _controller.value;
      final playing = value.isPlaying;
      if (playing != _isPlaying) setState(() => _isPlaying = playing);
      if (_isPlaying && _showThumbnail) setState(() => _showThumbnail = false);
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
    }
  }

  //-----//
  //TIMER//
  //-----//
  void _startCloseOverlayButtons() {
    if (!_isGoingToCloseBufferingWidget) {
      setState(() {
        _isGoingToCloseBufferingWidget = true;
        _closeOverlayButtons = Misc.timer(3200, () {
          setState(() => _showButtons = false);
          _cancelCloseOverlayButtons();
        });
      });
    }
  }

  void _createBufferTimer() {
    setState(() {
      _timerPosition = Misc.periodic(1000, () {
        int position = _controller.value.position.inMilliseconds;
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
    setState(() {
      if (_isPlaying)
        _controller.pause();
      else {
        _controller.play();
        _lastPosition = _lastPosition - 1;
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
      _transitions,
      () => setState(() => _iconPlayWidth = GetKey.width(_playKey)),
    );
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

  //-----//
  //BUILD//
  //-----//
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      Orientation landscape = Orientation.landscape;
      double padding = _style.progressBarStyle.paddingBeetwen;
      _progressBarMargin = orientation == landscape ? padding * 2 : padding;

      //RESPONSIVE TEXT
      _style = orientation == landscape ? _landscapeStyle : widget.style;

      if (_orientation != orientation) {
        _orientation = orientation;
        if (_isFullScreen) {
          Misc.setSystemOverlay([]);
          Misc.delayed(400, () => Misc.setSystemOverlay([]));
        }
      }

      Widget player = _isFullScreen && orientation == landscape
          ? _player()
          : _playerAspectRatio(_player());

      return player;
    });
  }

  Widget _playerAspectRatio(Widget child) {
    return AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: child,
    );
  }

  Widget _player() {
    return _globalGesture(
      Stack(children: [
        _fadeTransition(
          visible: !_showThumbnail,
          child: _isFullScreen && _orientation == Orientation.landscape
              ? Center(child: _playerAspectRatio(VideoPlayer(_controller)))
              : VideoPlayer(_controller),
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
              height: _style.playAndPauseStyle.circleSize * 2,
              width: _style.playAndPauseStyle.circleSize * 2,
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
          visible: _showAMomentPlayAndPause,
          child: _playAndPauseIconButtons(),
        ),
        SettingsMenu(
          style: _style,
          source: widget.source,
          visible: _showSettings,
          controller: _controller,
          activedSource: _activedSource,
          changeSource: _changeVideoSource,
          changeState: () => setState(() => _showSettings = !_showSettings),
        ),
        _rewindAndForwardIconsIndicator(),
      ]),
    );
  }

  //------------//
  //MISC WIDGETS//
  //------------//
  Widget _containerPadding({Widget child}) {
    return Container(
      color: Colors.transparent,
      padding: Margin.vertical(_progressBarMargin),
      child: child,
    );
  }

  Widget _fadeTransition({bool visible, Widget child}) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: _transitions),
      visible: visible,
      child: child,
    );
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
            if (_isDraggingProgress) _isDraggingProgress = false;
            if (_showButtons) _isGoingToCloseBufferingWidget = false;
          });
        }
      },
    );
  }

  //------//
  //REWIND//
  //------//
  Widget _rewindAndForward() {
    return _rewindAndForwardLayout(
      rewind: GestureDetector(
          onDoubleTap: () => _showRewindAndForward(0, -widget.rewindAmount)),
      forward: GestureDetector(
          onDoubleTap: () => _showRewindAndForward(1, widget.forwardAmount)),
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
      SwipeTransition(
        duration: Duration(milliseconds: _transitions),
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
            color: Colors.black.withOpacity(0.2),
            borderRadius: EdgeRadius.all(5)),
      ),
    );
  }

  Widget _bottomProgressBar() {
    VideoProgressBarStyle style = _style.progressBarStyle;
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
              colors: [Colors.transparent, Colors.black.withOpacity(0.2)],
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
                verticalPadding: _progressBarMargin,
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
                onTap: () => setState(() => _progressBarTextShowPosition =
                    !_progressBarTextShowPosition),
                child: _containerPadding(
                  child: Text(
                    _progressBarTextShowPosition ? position : remaing,
                    style: _style.textStyle,
                  ),
                ),
              ),
            ),
            _settingsIconButton(),
            GestureDetector(
              onTap: () async {
                if (!_isFullScreen)
                  PushRoute.transparentPage(
                    context,
                    FullScreenPage(
                      style: _style,
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
                  );
                else if (widget.exitFullScreen != null) widget.exitFullScreen();
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
