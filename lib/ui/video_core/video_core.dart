import 'dart:async';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/forward_and_rewind.dart';
import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/bar.dart';
import 'package:video_viewer/ui/video_core/widgets/play_and_pause.dart';
import 'package:video_viewer/ui/video_core/widgets/aspect_ratio.dart';
import 'package:video_viewer/ui/video_core/widgets/orientation.dart';
import 'package:video_viewer/ui/video_core/widgets/volume_bar.dart';
import 'package:video_viewer/ui/video_core/widgets/thumbnail.dart';
import 'package:video_viewer/ui/video_core/widgets/buffering.dart';
import 'package:video_viewer/ui/video_core/widgets/subtitle.dart';
import 'package:video_viewer/ui/video_core/widgets/player.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';
import 'package:video_viewer/ui/overlay/overlay.dart';

class VideoViewerCore extends StatefulWidget {
  VideoViewerCore({Key? key}) : super(key: key);

  @override
  _VideoViewerCoreState createState() => _VideoViewerCoreState();
}

class _VideoViewerCoreState extends State<VideoViewerCore> {
  final VideoQuery _query = VideoQuery();
  bool _showAMomentPlayAndPause = false;
  Timer? _hidePlayAndPause;

  Offset _dragInitialDelta = Offset.zero;
  Axis _dragDirection = Axis.vertical;

  //REWIND AND FORWARD
  final ValueNotifier<int> _forwardAndRewindAmount = ValueNotifier<int>(1);
  Duration _initialForwardPosition = Duration.zero;
  int _rewindDoubleTapCount = 0;
  int _forwardDoubleTapCount = 0;
  int _defaultRewindAmount = -10;
  int _defaultForwardAmount = 10;
  Timer? _rewindDoubleTapTimer;
  Timer? _forwardDoubleTapTimer;
  bool _showForwardStatus = false;
  Offset _horizontalDragStartOffset = Offset.zero;
  List<bool> _showAMomentRewindIcons = [false, false];

  //VOLUME
  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(1.0);
  final FocusNode _focusRawKeyboard = FocusNode();
  final double _maxVolume = 1.0;
  Offset _verticalDragStartOffset = Offset.zero;
  double _onDragStartVolume = 1;
  bool _showVolumeStatus = false;
  Timer? _closeVolumeStatus;

  //SCALE
  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);
  final double _minScale = 1.0;
  double _initialScale = 1.0, _maxScale = 1.0;

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
    _scale.dispose();
    _currentVolume.dispose();
    _focusRawKeyboard.dispose();
    _hidePlayAndPause?.cancel();
    _closeVolumeStatus?.cancel();
    _forwardAndRewindAmount.dispose();
    super.dispose();
  }

  //-------------//
  //OVERLAY (TAP)//
  //-------------//
  void _onTapPlayAndPause() async {
    final video = _query.video(context);
    await video.onTapPlayAndPause();
    if (!video.isShowingOverlay) {
      setState(() {
        _showAMomentPlayAndPause = true;
        _hidePlayAndPause?.cancel();
        _hidePlayAndPause = Misc.timer(600, () {
          _hidePlayAndPause?.cancel();
          setState(() => _showAMomentPlayAndPause = false);
        });
      });
    }
  }

  void _showAndHideOverlay([bool? show]) {
    _query.video(context).showAndHideOverlay(show);
    if (!_focusRawKeyboard.hasFocus)
      FocusScope.of(context).requestFocus(_focusRawKeyboard);
  }

  //-------------------------------//
  //FORWARD AND REWIND (DOUBLE TAP)//
  //-------------------------------//
  void _rewind() => _showRewindAndForward(0, _defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  void _videoSeekTo(int amount) async {
    final video = _query.video(context).video!;
    final position = video.value.position;
    await video.seekTo(Duration(seconds: position.inSeconds + amount));
    await video.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _videoSeekTo(amount);
    setState(() {
      if (index == 0) {
        if (!_showAMomentRewindIcons[index]) _rewindDoubleTapCount = 0;
        _rewindDoubleTapTimer?.cancel();
        _rewindDoubleTapCount += 1;
        _rewindDoubleTapTimer = Misc.timer(600, () {
          _showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      } else {
        if (!_showAMomentRewindIcons[index]) _forwardDoubleTapCount = 0;
        _forwardDoubleTapTimer?.cancel();
        _forwardDoubleTapCount += 1;
        _forwardDoubleTapTimer = Misc.timer(600, () {
          _showAMomentRewindIcons[index] = false;
          setState(() {});
        });
      }
      _showAMomentRewindIcons[index] = true;
    });
  }

  //------------------------------------//
  //FORWARD AND REWIND (DRAG HORIZONTAL)//
  //------------------------------------//
  void _forwardDragStart(Offset globalPosition) {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu)
      setState(() {
        _initialForwardPosition = controller.video!.value.position;
        _horizontalDragStartOffset = globalPosition;
        _showForwardStatus = true;
      });
  }

  void _forwardDragUpdate(Offset globalPosition) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu) {
      double diff = _horizontalDragStartOffset.dx - globalPosition.dx;
      double multiplicator = (diff.abs() / 50);
      int seconds = video.video!.value.position.inSeconds;
      int amount = -((diff / 10).round() * multiplicator).round();

      if (seconds + amount < video.video!.value.duration.inSeconds &&
          seconds + amount > 0) _forwardAndRewindAmount.value = amount;
    }
  }

  void _forwardDragEnd() {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _showForwardStatus) {
      setState(() => _showForwardStatus = false);
      _videoSeekTo(_forwardAndRewindAmount.value);
    }
  }

  //----------------------------//
  //VIDEO VOLUME (VERTICAL DRAG)//
  //----------------------------//
  void _setVolume(double volume) async {
    if (volume <= _maxVolume && volume >= 0) {
      final video = _query.video(context);
      final fractional = _maxVolume * 0.05;
      if (volume >= _maxVolume - fractional) volume = _maxVolume;
      if (volume <= fractional) volume = 0.0;
      await video.video!.setVolume(volume);
      _currentVolume.value = volume;
    }
  }

  void _volumeDragStart(Offset globalPosition) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu) {
      setState(() {
        _closeVolumeStatus?.cancel();
        _showVolumeStatus = true;
        _onDragStartVolume = video.video!.value.volume;
        _currentVolume.value = _onDragStartVolume;
        _verticalDragStartOffset = globalPosition;
      });
    }
  }

  void _volumeDragUpdate(Offset globalPosition) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu) {
      double diff = _verticalDragStartOffset.dy - globalPosition.dy;
      double volume = (diff / 125) + _onDragStartVolume;
      _setVolume(volume);
    }
  }

  void _volumeDragEnd() {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _showVolumeStatus) {
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
  }

  void _onKeypressVolume(bool isArrowUp) {
    _showVolumeStatus = true;
    _closeVolumeStatus?.cancel();
    _setVolume(_currentVolume.value + (isArrowUp ? 0.1 : -0.1));
    _volumeDragEnd();
  }

  @override
  Widget build(BuildContext context) {
    Widget player = Stack(children: [
      ValueListenableBuilder(
        valueListenable: _scale,
        builder: (_, double scale, __) => Transform.scale(
          scale: scale,
          child: VideoCorePlayer(),
        ),
      ),
      GestureDetector(
        onTap: _showAndHideOverlay,
        behavior: HitTestBehavior.opaque,
        child: Container(height: double.infinity, width: double.infinity),
      ),
      VideoCoreForwardAndRewind(
        showRewind: _showAMomentRewindIcons[0],
        showForward: _showAMomentRewindIcons[1],
        rewindSeconds: _defaultRewindAmount * _rewindDoubleTapCount,
        forwardSeconds: _defaultForwardAmount * _forwardDoubleTapCount,
      ),
      VideoCoreForwardAndRewindLayout(
        rewind: GestureDetector(onDoubleTap: _rewind),
        forward: GestureDetector(onDoubleTap: _forward),
      ),
      LayoutBuilder(
        builder: (_, box) => Center(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _onTapPlayAndPause,
            child: Container(
              width: box.maxWidth * 0.2,
              height: box.maxHeight * 0.2,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
      AnimatedBuilder(
        animation: _query.video(context, listen: true),
        builder: (_, __) => VideoCoreBuffering(),
      ),
      VideoCoreActiveSubtitleText(),
      VideoCorePlayAndPause(showAMoment: _showAMomentPlayAndPause),
      VideoCoreOverlay(),
      CustomOpacityTransition(
        visible: _showForwardStatus,
        child: ValueListenableBuilder(
          valueListenable: _forwardAndRewindAmount,
          builder: (_, int seconds, __) => VideoCoreForwardAndRewindBar(
            seconds: seconds,
            position: _initialForwardPosition,
          ),
        ),
      ),
      ValueListenableBuilder(
        valueListenable: _currentVolume,
        builder: (_, double value, __) => VideoCoreVolumeBar(
          visible: _showVolumeStatus,
          progress: value / _maxVolume,
        ),
      ),
      VideoCoreThumbnail(),
    ]);

    return VideoCoreOrientation(builder: (isFullScreenLandscape) {
      return isFullScreenLandscape
          ? _globalGesture(player, isFullScreenLandscape)
          : VideoCoreAspectRadio(
              child: _globalGesture(player, isFullScreenLandscape));
    });
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(Widget child, bool canScale) {
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
      child: XGestureDetector(
        //SCALE
        onScaleStart: (_) {
          _initialScale = _scale.value;
          final size = context.media.size;
          final video = _query.video(context).video!;
          final aspectWidth = size.height * video.value.aspectRatio;

          _initialScale = _scale.value;
          _maxScale = size.width / aspectWidth;
        },
        onScaleUpdate: (details) {
          final double newScale = _initialScale * details.scale;
          if (newScale >= _minScale && newScale <= _maxScale)
            _scale.value = newScale;
        },
        //FORWARD AND REWIND
        onMoveUpdate: (details) {
          final Offset position = details.localPos;
          if (_dragInitialDelta == Offset.zero) {
            final Offset delta = details.localDelta;
            if (delta.dx.abs() > delta.dy.abs()) {
              _dragDirection = Axis.horizontal;
              _forwardDragStart(position);
            } else {
              _dragDirection = Axis.vertical;
              _volumeDragStart(position);
            }
            _dragInitialDelta = delta;
          }

          switch (_dragDirection) {
            case Axis.horizontal:
              _forwardDragUpdate(position);
              break;
            case Axis.vertical:
              _volumeDragUpdate(position);
              break;
          }
        },
        onMoveEnd: (details) {
          _dragInitialDelta = Offset.zero;
          switch (_dragDirection) {
            case Axis.horizontal:
              _forwardDragEnd();
              break;
            case Axis.vertical:
              _volumeDragEnd();
              break;
          }
        },
        bypassTapEventOnDoubleTap: true,
        child: child,
      ),
    );
  }
}
