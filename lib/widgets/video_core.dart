import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

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
  bool _showAMomentPlayAndPause = false;
  Timer _hidePlayAndPause;

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

  //VIDEO ZOOM
  double _scale = 1.0, _maxScale = 1.0, _minScale = 1.0, _initialScale = 1.0;
  int _pointers = 0;

  //WEB
  final FocusNode _focusRawKeyboard = FocusNode();

  @override
  void initState() {
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _focusRawKeyboard.dispose();
    _hidePlayAndPause?.cancel();
    super.dispose();
  }

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
  void _onTapPlayAndPause() async {
    final video = _query.video(context);
    await video.onTapPlayAndPause();
    if (!video.isShowingOverlay) {
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
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1)
      setState(() {
        _horizontalDragStartOffset = details.globalPosition;
        _showForwardStatus = true;
      });
  }

  void _forwardDragUpdate(DragUpdateDetails details) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1) {
      double diff = _horizontalDragStartOffset.dx - details.globalPosition.dx;
      double multiplicator = (diff.abs() / 50);
      int seconds = video.controller.value.position.inSeconds;
      int amount = -((diff / 10).round() * multiplicator).round();
      setState(() {
        if (seconds + amount < video.controller.value.duration.inSeconds &&
            seconds + amount > 0) _forwardAndRewindAmount = amount;
      });
    }
  }

  void _forwardDragEnd() {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _showForwardStatus) {
      setState(() => _showForwardStatus = false);
      _controllerSeekTo(_forwardAndRewindAmount);
    }
  }

  //-----------------//
  //CONTROLLER VOLUME//
  //-----------------//
  void _updateVolumes() {
    final video = _query.video(context);
    _maxVolume = 1.0;
    _onDragStartVolume = video.controller.value.volume;
    _currentVolume = _onDragStartVolume;
    if (mounted) setState(() {});
  }

  void _setVolume(double volume) async {
    if (volume <= _maxVolume && volume >= 0) {
      final video = _query.video(context);
      final fractional = _maxVolume * 0.05;
      if (volume >= _maxVolume - fractional) volume = _maxVolume;
      if (volume <= fractional) volume = 0.0;
      await video.controller.setVolume(volume);
      setState(() => _currentVolume = volume);
    }
  }

  void _volumeDragStart(DragStartDetails details) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1) {
      _closeVolumeStatus?.cancel();
      setState(() {
        _verticalDragStartOffset = details.globalPosition;
        _showVolumeStatus = true;
      });
      _updateVolumes();
    }
  }

  void _volumeDragUpdate(DragUpdateDetails details) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1) {
      double diff = _verticalDragStartOffset.dy - details.globalPosition.dy;
      double volume = (diff / 125) + _onDragStartVolume;
      _setVolume(volume);
    }
  }

  void _volumeDragEnd() {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _showVolumeStatus)
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
    return OrientationBuilder(builder: (_, orientation) {
      final video = _query.video(context, listen: true);
      final metadata = _query.videoMetadata(context, listen: true);

      Orientation landscape = Orientation.landscape;
      bool fullScreenLandscape = video.isFullScreen && orientation == landscape;

      metadata.style = orientation == landscape
          ? metadata.responsiveStyle
          : metadata.originalStyle;

      return fullScreenLandscape
          ? _player(orientation, fullScreenLandscape)
          : _playerAspectRatio(_player(orientation, fullScreenLandscape));
    });
  }

  Widget _player(Orientation orientation, bool fullScreenLandscape) {
    final Size size = GetMedia(context).size;
    final video = _query.video(context, listen: true);
    final controller = video.controller;

    final style = _query.videoMetadata(context, listen: true).style;

    return _globalGesture(
      Stack(children: [
        CustomOpacityTransition(
          visible: !video.isShowingThumbnail,
          child: fullScreenLandscape
              ? Transform.scale(
                  scale: _scale,
                  child: Center(
                    child: _playerAspectRatio(VideoPlayer(controller)),
                  ),
                )
              : VideoPlayer(video.controller),
        ),
        kIsWeb
            ? MouseRegion(
                onHover: (_) {
                  if (!video.isShowingOverlay) _showAndHideOverlay(true);
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
                              size.height * controller.value.aspectRatio;
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
          visible: video.isShowingThumbnail,
          child: GestureDetector(
            onTap: () => setState(controller.play),
            child: Container(
              color: Colors.transparent,
              child: style.thumbnail,
            ),
          ),
        ),
        _rewindAndForward(),
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
          visible: !video.isShowingThumbnail,
          child: VideoOverlay(),
        ),
        CustomOpacityTransition(
          visible: video.isBuffering,
          child: style.buffering,
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
            return Center(
              child: CustomOpacityTransition(
                visible: _showAMomentPlayAndPause || position >= duration,
                child: PlayAndPause(type: PlayAndPauseType.center),
              ),
            );
          },
        ),
        CustomSwipeTransition(
          visible: _showVolumeStatus,
          direction: style.volumeBarStyle.alignment == Alignment.centerLeft
              ? SwipeDirection.fromLeft
              : SwipeDirection.fromRight,
          child: VideoVolumeBar(
            progress: (_currentVolume / _maxVolume),
          ),
        ),
        _rewindAndForwardIconsIndicator(),
      ]),
    );
  }

  Widget _playerAspectRatio(Widget child) {
    final controller = _query.video(context, listen: true).controller;
    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
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
    final style =
        _query.videoMetadata(context, listen: true).style.forwardAndRewindStyle;

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
    final text = secondsFormatter(_forwardAndRewindAmount);
    final metadata = _query.videoMetadata(context, listen: true);
    final style = metadata.style.forwardAndRewindStyle;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: style.padding,
        decoration: BoxDecoration(
          color: style.backgroundColor,
          borderRadius: style.borderRadius,
        ),
        child: Text(text, style: metadata.style.textStyle),
      ),
    );
  }
}
