import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:gesture_x_detector/gesture_x_detector.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/entities/volume_control.dart';
import 'package:video_viewer/ui/overlay/widgets/background.dart';
import 'package:video_viewer/ui/video_core/widgets/ad.dart';

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
import 'package:video_viewer/ui/widgets/play_and_pause.dart';
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

  //------------------------------//
  //REWIND AND FORWARD (VARIABLES)//
  //------------------------------//
  final ValueNotifier<int> _forwardAndRewindSecondsAmount =
      ValueNotifier<int>(1);
  Duration _initialForwardPosition = Duration.zero;
  Offset _dragInitialDelta = Offset.zero;
  Axis _dragDirection = Axis.vertical;
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
  double _maxVolume = 1.0;
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
      switch (metadata.volumeManager) {
        case VideoViewerVolumeManager.device:
          _maxVolume = await VolumeWatcher.getMaxVolume;
          break;
        case VideoViewerVolumeManager.video:
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
    _closeVolumeStatus?.cancel();
    _rewindDoubleTapTimer?.cancel();
    _forwardDoubleTapTimer?.cancel();
    _forwardAndRewindSecondsAmount.dispose();
    super.dispose();
  }

  //-------------//
  //OVERLAY (TAP)//
  //-------------//

  bool _canListenerMove([VideoViewerController? controller]) {
    controller ??= _query.video(context);
    return !(controller.isDraggingProgressBar ||
        controller.activeAd != null ||
        controller.isShowingChat);
  }

  //-------------------------------//
  //FORWARD AND REWIND (DOUBLE TAP)//
  //-------------------------------//
  void _rewind() => _showRewindAndForward(0, _defaultRewindAmount);
  void _forward() => _showRewindAndForward(1, _defaultForwardAmount);

  Future<void> _videoSeekToNextSeconds(int seconds) async {
    final controller = _query.video(context);
    final int position = controller.video!.value.position.inSeconds;
    await controller.seekTo(Duration(seconds: position + seconds));
    await controller.play();
  }

  void _showRewindAndForward(int index, int amount) async {
    _videoSeekToNextSeconds(amount);
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
    setState(() {});
  }

  //------------------------------------//
  //FORWARD AND REWIND (DRAG HORIZONTAL)//
  //------------------------------------//
  void _forwardDragStart(Offset globalPosition) async {
    final controller = _query.video(context);
    await controller.pause();
    if (!controller.isShowingSettingsMenu) {
      Misc.delayed(50, () {
        if (_canListenerMove(controller)) {
          _initialForwardPosition = controller.position;
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
      final int duration = controller.duration.inSeconds;
      final int position = controller.position.inSeconds;
      final int seconds = -(diff / (200 / duration)).round();
      final int relativePosition = position + seconds;
      if (relativePosition <= duration && relativePosition >= 0) {
        _forwardAndRewindSecondsAmount.value = seconds;
      }
    }
  }

  void _forwardDragEnd() async {
    await _videoSeekToNextSeconds(_forwardAndRewindSecondsAmount.value);
    setState(() => _showForwardStatus = false);
  }

  //----------------------------//
  //VIDEO VOLUME (VERTICAL DRAG)//
  //----------------------------//
  void _setVolume(double volume) async {
    volume = volume.clamp(0.0, _maxVolume);
    _currentVolume.value = volume;
    switch (_query.videoMetadata(context).volumeManager) {
      case VideoViewerVolumeManager.device:
        await VolumeWatcher.setVolume(volume);
        break;
      case VideoViewerVolumeManager.video:
        await _query.video(context).video!.setVolume(volume);
        break;
    }
  }

  void _volumeDragUpdate(Offset delta) {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu) {
      _setVolume(_currentVolume.value - (delta.dy / 100));
    }
  }

  void _volumeDragStart() {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu) {
      Misc.delayed(50, () {
        if (_canListenerMove(controller)) {
          setState(() {
            _closeVolumeStatus?.cancel();
            _showVolumeStatus = true;
          });
        }
      });
    }
  }

  void _volumeDragEnd() {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu && _showVolumeStatus) {
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
          : VideoCoreAspectRadio(child: _globalGesture(isFullScreenLandscape));
    });
  }

  //--------//
  //GESTURES//
  //--------//
  Widget _globalGesture(bool canScale) {
    final metadata = _query.videoMetadata(context);
    final bool horizontal = metadata.enableHorizontalSwapingGesture;
    final bool vertical = metadata.enableVerticalSwapingGesture;
    final bool scale = metadata.onFullscreenFixLandscape;

    return scale || horizontal || vertical
        ? XGestureDetector(
            //--------------//
            //SCALE GESTURES//
            //--------------//
            onScaleStart: scale
                ? (_) {
                    _initialScale = _scale.value;
                    final size = context.media.size;
                    final video = _query.video(context).video!;
                    final aspectWidth = size.height * video.value.aspectRatio;

                    _initialScale = _scale.value;
                    _maxScale = size.width / aspectWidth;
                  }
                : null,
            onScaleUpdate: scale
                ? (ScaleEvent details) {
                    final double newScale = _initialScale * details.scale;
                    if (newScale >= _minScale && newScale <= _maxScale)
                      _scale.value = newScale;
                  }
                : null,
            //---------------------------//
            //VOLUME AND FORWARD GESTURES//
            //---------------------------//
            onMoveUpdate: horizontal || vertical
                ? (MoveEvent details) {
                    if (_canListenerMove()) {
                      final Offset position = details.localPos;
                      final Offset delta = details.localDelta;
                      if (_dragInitialDelta == Offset.zero) {
                        if (delta.dx.abs() > delta.dy.abs() && horizontal) {
                          _dragDirection = Axis.horizontal;
                          _forwardDragStart(position);
                        } else if (vertical) {
                          _dragDirection = Axis.vertical;
                          _volumeDragStart();
                        }
                        _dragInitialDelta = delta;
                      }
                      switch (_dragDirection) {
                        case Axis.horizontal:
                          if (horizontal) _forwardDragUpdate(position);
                          break;
                        case Axis.vertical:
                          if (vertical) _volumeDragUpdate(delta);
                          break;
                      }
                    }
                  }
                : null,
            onMoveEnd: horizontal || vertical
                ? (_) {
                    _dragInitialDelta = Offset.zero;
                    switch (_dragDirection) {
                      case Axis.horizontal:
                        if (horizontal) _forwardDragEnd();
                        break;
                      case Axis.vertical:
                        if (vertical) _volumeDragEnd();
                        break;
                    }
                  }
                : null,
            child: _player(),
          )
        : _player();
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
        onTap: () => _query.video(context).showAndHideOverlay(),
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
      Builder(builder: (_) {
        final controller = _query.video(context, listen: true);
        final metadata = _query.videoMetadata(context);
        return Stack(children: [
          const VideoCoreBuffering(),
          if (metadata.enableShowReplayIconAtVideoEnd)
            CustomOpacityTransition(
              visible: controller.position >= controller.duration &&
                  !controller.isShowingOverlay,
              child: const Center(
                child: PlayAndPause(type: PlayAndPauseType.center),
              ),
            ),
        ]);
      }),
      const VideoCoreOverlay(),
      CustomOpacityTransition(
        visible: _showForwardStatus,
        child: ValueListenableBuilder(
          valueListenable: _forwardAndRewindSecondsAmount,
          builder: (_, int seconds, __) => VideoCoreForwardAndRewindBar(
            seconds: seconds,
            position: _initialForwardPosition,
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: Builder(builder: (_) {
          final controller = _query.video(context, listen: true);
          final style = _query.videoStyle(context);
          return CustomSwipeTransition(
            visible: controller.isShowingChat,
            axis: Axis.horizontal,
            axisAlignment: 1.0,
            child: GradientBackground(
              child: style.chatStyle.chat,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          );
        }),
      ),
      ValueListenableBuilder(
        valueListenable: _currentVolume,
        builder: (_, double value, __) => VideoCoreVolumeBar(
          visible: _showVolumeStatus,
          progress: value / _maxVolume,
        ),
      ),
      const VideoCoreThumbnail(),
      const VideoCoreAdViewer(),
    ]);
  }
}
