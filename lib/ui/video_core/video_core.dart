import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:video_viewer/domain/entities/volume_control.dart';

import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/forward_and_rewind.dart';
import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/layout.dart';
import 'package:video_viewer/ui/video_core/widgets/forward_and_rewind/bar.dart';
import 'package:video_viewer/ui/video_core/widgets/aspect_ratio.dart';
import 'package:video_viewer/ui/video_core/widgets/orientation.dart';
import 'package:video_viewer/ui/video_core/widgets/volume_bar.dart';
import 'package:video_viewer/ui/video_core/widgets/thumbnail.dart';
import 'package:video_viewer/ui/video_core/widgets/buffering.dart';
import 'package:video_viewer/ui/video_core/widgets/subtitle.dart';
import 'package:video_viewer/ui/video_core/widgets/player.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';
import 'package:video_viewer/ui/overlay/overlay.dart';
import 'package:volume_watcher/volume_watcher.dart';

class VideoViewerCore extends StatefulWidget {
  const VideoViewerCore({Key? key}) : super(key: key);

  @override
  _VideoViewerCoreState createState() => _VideoViewerCoreState();
}

class _VideoViewerCoreState extends State<VideoViewerCore> {
  final VideoQuery _query = VideoQuery();
  Timer? _hidePlayAndPause;

  Offset _dragInitialDelta = Offset.zero;
  Axis _dragDirection = Axis.vertical;

  //------------------------------//
  //REWIND AND FORWARD (VARIABLES)//
  //------------------------------//
  bool _isDraggingProgressBar = false;
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

  //------------------//
  //VOLUME (VARIABLES)//
  //------------------//
  final ValueNotifier<double> _currentVolume = ValueNotifier<double>(1.0);
  final FocusNode _focusRawKeyboard = FocusNode();
  double _maxVolume = 1.0;
  Offset _verticalDragStartOffset = Offset.zero;
  double _onDragStartVolume = 1;
  bool _showVolumeStatus = false;
  Timer? _closeVolumeStatus;

  //-----------------//
  //SCALE (VARIABLES)//
  //-----------------//
  final ValueNotifier<double> _scale = ValueNotifier<double>(1.0);
  final double _minScale = 1.0;
  double _initialScale = 1.0, _maxScale = 1.0;

  @override
  void initState() {
    Misc.onLayoutRendered(() async {
      final metadata = _query.videoMetadata(context);
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;
      switch (metadata.volumeControl) {
        case VolumeControlType.device:
          _maxVolume = await VolumeWatcher.getMaxVolume;
          break;
        case VolumeControlType.video:
          _maxVolume = 1.0;
          break;
      }
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

  void _draggingListener() {
    _isDraggingProgressBar = _query.video(context).isDraggingProgressBar;
  }

  //-------------//
  //OVERLAY (TAP)//
  //-------------//
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
    if (!controller.isShowingSettingsMenu) {
      Misc.delayed(100, () {
        if (!_isDraggingProgressBar) {
          _initialForwardPosition = controller.video!.value.position;
          _horizontalDragStartOffset = globalPosition;
          _showForwardStatus = true;
          setState(() {});
        }
      });
    }
  }

  void _forwardDragUpdate(Offset globalPosition) {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu) {
      final double diff = _horizontalDragStartOffset.dx - globalPosition.dx;
      final double multiplicator = (diff.abs() / 25);
      final int seconds = controller.video!.value.position.inSeconds;
      final int amount = -((diff / 10).round() * multiplicator).round();

      if (seconds + amount < controller.video!.value.duration.inSeconds &&
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
      switch (_query.videoMetadata(context).volumeControl) {
        case VolumeControlType.device:
          await VolumeWatcher.setVolume(volume);
          break;
        case VolumeControlType.video:
          await video.video!.setVolume(volume);
          break;
      }
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

  @override
  Widget build(BuildContext context) {
    return VideoCoreOrientation(builder: (isFullScreenLandscape) {
      return isFullScreenLandscape
          ? _globalGesture(isFullScreenLandscape)
          : VideoCoreAspectRadio(
              child: _globalGesture(isFullScreenLandscape),
            );
    });
  }

  Widget _player() {
    return Stack(children: [
      ValueListenableBuilder(
        valueListenable: _scale,
        builder: (_, double scale, __) => Transform.scale(
          scale: scale,
          child: const VideoCorePlayer(),
        ),
      ),
      const VideoCoreActiveSubtitleText(),
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
      AnimatedBuilder(
        animation: _query.video(context, listen: true),
        builder: (_, __) => const VideoCoreBuffering(),
      ),
      const VideoCoreOverlay(),
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
      const VideoCoreThumbnail(),
    ]);
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(bool canScale) {
    return XGestureDetector(
      //--------------//
      //SCALE GESTURES//
      //--------------//
      onScaleStart: (_) {
        _initialScale = _scale.value;
        final size = context.media.size;
        final video = _query.video(context).video!;
        final aspectWidth = size.height * video.value.aspectRatio;

        _initialScale = _scale.value;
        _maxScale = size.width / aspectWidth;
      },
      onScaleUpdate: (ScaleEvent details) {
        final double newScale = _initialScale * details.scale;
        if (newScale >= _minScale && newScale <= _maxScale)
          _scale.value = newScale;
      },
      //---------------------------//
      //VOLUME AND FORWARD GESTURES//
      //---------------------------//
      onMoveStart: (_) {
        _query.video(context).addListener(_draggingListener);
      },
      onMoveUpdate: (MoveEvent details) {
        if (!_isDraggingProgressBar) {
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
        }
      },
      onMoveEnd: (_) {
        _query.video(context).removeListener(_draggingListener);
        _isDraggingProgressBar = false;
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
      child: _player(),
    );
  }
}
