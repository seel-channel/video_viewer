import 'dart:async';
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

  //REWIND AND FORWARD
  final ValueNotifier<int> _forwardAndRewindAmount = ValueNotifier<int>(1);
  Duration _initialPosition = Duration.zero;
  int _defaultRewindAmount = 10;
  int _defaultForwardAmount = 10;
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
  int _pointers = 0;

  @override
  void initState() {
    super.initState();
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      _defaultRewindAmount = metadata.rewindAmount;
      _defaultForwardAmount = metadata.forwardAmount;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _forwardAndRewindAmount.dispose();
    _currentVolume.dispose();
    _focusRawKeyboard.dispose();
    _hidePlayAndPause?.cancel();
    _closeVolumeStatus?.cancel();
    super.dispose();
  }

  //--------------//
  //MISC FUNCTIONS//
  //--------------//
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

  //------------------//
  //FORWARD AND REWIND//
  //------------------//
  void _rewind() => _showRewindAndForward(0, -_defaultRewindAmount);
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
      _forwardAndRewindAmount.value = amount;
      _showAMomentRewindIcons[index] = true;
    });
    Misc.delayed(600, () {
      setState(() {
        _showAMomentRewindIcons[index] = false;
      });
    });
  }

  void _forwardDragStart(DragStartDetails details) {
    final controller = _query.video(context);
    if (!controller.isShowingSettingsMenu && _pointers == 1)
      setState(() {
        _initialPosition = controller.video!.value.position;
        _horizontalDragStartOffset = details.globalPosition;
        _showForwardStatus = true;
      });
  }

  void _forwardDragUpdate(DragUpdateDetails details) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1) {
      double diff = _horizontalDragStartOffset.dx - details.globalPosition.dx;
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

  //-----------------//
  //video VOLUME//
  //-----------------//
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

  void _volumeDragStart(DragStartDetails details) {
    final video = _query.video(context);
    if (!video.isShowingSettingsMenu && _pointers == 1) {
      setState(() {
        _closeVolumeStatus?.cancel();
        _showVolumeStatus = true;
        _onDragStartVolume = video.video!.value.volume;
        _currentVolume.value = _onDragStartVolume;
        _verticalDragStartOffset = details.globalPosition;
      });
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
    Widget player = _globalGesture(
      Stack(children: [
        VideoCorePlayer(),
        GestureDetector(
          onTap: _showAndHideOverlay,
          behavior: HitTestBehavior.opaque,
          child: Container(height: double.infinity, width: double.infinity),
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
        VideoCoreBuffering(),
        VideoCoreActiveSubtitleText(),
        VideoCorePlayAndPause(showAMoment: _showAMomentPlayAndPause),
        VideoCoreOverlay(),
        CustomOpacityTransition(
          visible: _showForwardStatus,
          child: ValueListenableBuilder(
            valueListenable: _forwardAndRewindAmount,
            builder: (_, int seconds, __) => VideoCoreForwardAndRewindBar(
              seconds: seconds,
              position: _initialPosition,
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
        VideoCoreForwardAndRewind(
          showRewind: _showAMomentRewindIcons[0],
          showForward: _showAMomentRewindIcons[1],
          rewindSeconds: -_defaultRewindAmount,
          forwardSeconds: _defaultForwardAmount,
        ),
        VideoCoreThumbnail(),
      ]),
    );

    return VideoCoreOrientation(builder: (isFullScreenLandscape) {
      return isFullScreenLandscape
          ? player
          : VideoCoreAspectRadio(child: player);
    });
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
