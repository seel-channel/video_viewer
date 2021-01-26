import 'package:flutter/material.dart';

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
    this._controller.addListener(() => notifyListeners());
  }

  final bool looping;
  String _activeSource;
  VideoPlayerController _controller;

  VideoPlayerController get controller => _controller;
  String get activeSource => _activeSource;

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;
  set isBuffering(bool value) {
    _isBuffering = value;
    notifyListeners();
  }

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;
  set isFullScreen(bool value) {
    _isFullScreen = value;
    notifyListeners();
  }

  Future<void> changeSource({
    @required VideoPlayerController source,
    @required String activeSource,
    @required void Function() listener,
    bool initialize = true,
  }) async {
    double speed = _controller.value.playbackSpeed;
    Duration seekTo = _controller.value.position;
    _activeSource = activeSource;

    if (initialize) {
      await source.initialize();
      _setSettingsController(source, speed, seekTo, listener);
    } else {
      _setSettingsController(source, speed, seekTo, listener);
    }
    notifyListeners();
  }

  void _setSettingsController(
    VideoPlayerController source,
    double speed,
    Duration seekTo,
    void Function() listener,
  ) {
    _controller = source;
    _controller.addListener(() {
      if (listener != null) listener();
      notifyListeners();
    });
    _controller.setPlaybackSpeed(speed);
    _controller.setLooping(looping);
    _controller.seekTo(seekTo);
    _controller.play();
    notifyListeners();
  }
}
