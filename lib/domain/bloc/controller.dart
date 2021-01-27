import 'dart:async';
import 'package:flutter/material.dart';
import 'package:helpers/helpers.dart';

import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/utils/sources.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoControllerNotifier extends ChangeNotifier {
  VideoControllerNotifier({
    VideoPlayerController controller,
    String activeSource,
    this.looping,
  }) {
    this._activeSource = activeSource;
    this._controller = controller;
    this._controller.addListener(_videoListener);
  }

  final bool looping;
  VideoPlayerController _controller;
  String _activeSource;
  bool _isBuffering = false,
      _showOverlay = false,
      _isFullScreen = false,
      _isGoingToCloseBufferingWidget = false;
  int _lastVideoPosition = 0;
  Timer _closeOverlayButtons, _timerPosition;

  VideoPlayerController get controller => _controller;
  String get activeSource => _activeSource;
  bool get showOverlay => _showOverlay;
  bool get isPlaying => _controller.value.isPlaying;

  bool get isBuffering => _isBuffering;
  set isBuffering(bool value) {
    _isBuffering = value;
    notifyListeners();
  }

  bool get isFullScreen => _isFullScreen;
  set isFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }

  int get lastVideoPosition => _lastVideoPosition;
  set lastVideoPosition(int value) {
    _lastVideoPosition = value;
    notifyListeners();
  }

  //----------------//
  //VIDEO CONTROLLER//
  //----------------//
  Future<void> changeSource({
    @required VideoPlayerController source,
    @required String activeSource,
    bool initialize = true,
  }) async {
    double speed = _controller.value.playbackSpeed;
    Duration seekTo = _controller.value.position;
    _activeSource = activeSource;

    if (initialize) {
      await source.initialize();
      _setSettingsController(source, speed, seekTo);
    } else {
      _setSettingsController(source, speed, seekTo);
    }
    notifyListeners();
  }

  void _setSettingsController(
    VideoPlayerController source,
    double speed,
    Duration seekTo,
  ) {
    _controller = source;
    _controller.addListener(_videoListener);
    _controller.setPlaybackSpeed(speed);
    _controller.setLooping(looping);
    _controller.seekTo(seekTo);
    _controller.play();
    notifyListeners();
  }

  void _videoListener() {
    final value = _controller.value;
    if (_showOverlay) {
      if (isPlaying) {
        if (value.position >= value.duration && looping) {
          _controller.seekTo(Duration.zero);
          notifyListeners();
        } else {
          if (_timerPosition == null) _createBufferTimer();
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseBufferingWidget) cancelCloseOverlay();
    }
  }

  //-----//
  //TIMER//
  //-----//
  void _startCloseOverlay() {
    if (!_isGoingToCloseBufferingWidget) {
      _isGoingToCloseBufferingWidget = true;
      _closeOverlayButtons = Misc.timer(3200, () {
        if (isPlaying) {
          _showOverlay = false;
          cancelCloseOverlay();
        }
      });
      notifyListeners();
    }
  }

  void cancelCloseOverlay() {
    _isGoingToCloseBufferingWidget = false;
    _closeOverlayButtons?.cancel();
    _closeOverlayButtons = null;
    notifyListeners();
  }

  void _createBufferTimer() {
    _timerPosition = Misc.periodic(1000, () {
      int position = _controller.value.position.inMilliseconds;
      if (isPlaying)
        _isBuffering = _lastVideoPosition != position ? false : true;
      else
        _isBuffering = false;
      _lastVideoPosition = position;
      notifyListeners();
    });
    notifyListeners();
  }

  Future<void> onTapPlayAndPause() async {
    final value = _controller.value;
    if (isPlaying) {
      await _controller.pause();
      if (!_showOverlay) _showOverlay = false;
    } else {
      if (value.position >= value.duration)
        await _controller.seekTo(Duration.zero);
      _lastVideoPosition = _lastVideoPosition - 1;
      await _controller.play();
    }
    notifyListeners();
  }

  void showAndHideOverlay([bool show]) {
    _showOverlay = show ?? !_showOverlay;
    if (_showOverlay) _isGoingToCloseBufferingWidget = false;
    notifyListeners();
  }
}
