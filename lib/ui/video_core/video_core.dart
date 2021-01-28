import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/text_alert.dart';
import 'package:video_viewer/ui/video_core/widgets/aspect_ratio.dart';
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';
import 'package:video_viewer/ui/widgets/volume_bar.dart';
import 'package:video_viewer/ui/overlay/overlay.dart';

class VideoViewerCore extends StatefulWidget {
  VideoViewerCore({Key key}) : super(key: key);

  @override
  _VideoViewerCoreState createState() => _VideoViewerCoreState();
}

class _VideoViewerCoreState extends State<VideoViewerCore> {
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
  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(1.0);
  final double _maxVolume = 1.0;
  double _onDragStartVolume = 1;
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
    _onDragStartVolume = video.controller.value.volume;
    _currentVolume.value = _onDragStartVolume;
    if (mounted) setState(() {});
  }

  void _setVolume(double volume) async {
    if (volume <= _maxVolume && volume >= 0) {
      final video = _query.video(context);
      final fractional = _maxVolume * 0.05;
      if (volume >= _maxVolume - fractional) volume = _maxVolume;
      if (volume <= fractional) volume = 0.0;
      await video.controller.setVolume(volume);
      _currentVolume.value = volume;
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
    _setVolume(_currentVolume.value + (isArrowUp ? 0.1 : -0.1));
    _volumeDragEnd();
  }

  //-----//
  //SCALE//
  //-----//
  void _onScaleStart(ScaleStartDetails details) {
    final size = GetMedia(context).size;
    final controller = _query.video(context).controller;
    final aspectWidth = size.height * controller.value.aspectRatio;

    _initialScale = _scale;
    _maxScale = size.width / aspectWidth;
    setState(() {});
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    final double newScale = _initialScale * details.scale;
    if (newScale >= _minScale && newScale <= _maxScale)
      setState(() => _scale = newScale);
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(builder: (_, orientation) {
      final video = _query.video(context, listen: true);
      final metadata = _query.videoMetadata(context, listen: true);

      final isFullScreenLandscape =
          video.isFullScreen && orientation == Orientation.landscape;

      metadata.style = orientation == Orientation.landscape
          ? metadata.responsiveStyle
          : metadata.originalStyle;

      return isFullScreenLandscape
          ? _player(orientation, isFullScreenLandscape)
          : VideoAspectRadio(
              child: _player(orientation, isFullScreenLandscape),
            );
    });
  }

  Widget _player(Orientation orientation, bool isFullScreenLandscape) {
    final size = GetMedia(context).size;
    final style = _query.videoStyle(context);
    final video = _query.video(context, listen: true);
    final controller = video.controller;

    return _globalGesture(
      Stack(children: [
        CustomOpacityTransition(
          visible: !video.isShowingThumbnail,
          child: isFullScreenLandscape
              ? Transform.scale(
                  scale: _scale,
                  child: Center(
                    child: VideoAspectRadio(child: VideoPlayer(controller)),
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
                onScaleStart: isFullScreenLandscape ? _onScaleStart : null,
                onScaleUpdate: isFullScreenLandscape ? _onScaleUpdate : null,
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
        RewindAndForwardLayout(
          rewind: GestureDetector(onDoubleTap: _rewind),
          forward: GestureDetector(onDoubleTap: _forward),
        ),
        Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTapPlayAndPause,
            child: Container(
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
          child: RewindAndForwardTextAlert(amount: _forwardAndRewindAmount),
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
          child: ValueListenableBuilder(
            valueListenable: _currentVolume,
            builder: (_, double value, __) {
              return VideoVolumeBar(progress: value / _maxVolume);
            },
          ),
        ),
        RewindAndForwardLayout(
          rewind: CustomOpacityTransition(
            visible: _showAMomentRewindIcons[0],
            child: Center(child: style.forwardAndRewindStyle.rewind),
          ),
          forward: CustomOpacityTransition(
            visible: _showAMomentRewindIcons[1],
            child: Center(child: style.forwardAndRewindStyle.forward),
          ),
        ),
      ]),
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
        onPointerDown: (e) => _pointers++,
        onPointerUp: (e) => _pointers--,
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
}
