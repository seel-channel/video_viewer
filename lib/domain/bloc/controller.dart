import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/utils/sources.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/fullscreen.dart';

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

  bool showThumbnail = false;
  bool _showSettingsMenu = false;

  VideoPlayerController get controller => _controller;
  String get activeSource => _activeSource;
  bool get isFullScreen => _isFullScreen;
  bool get showOverlay => _showOverlay;
  bool get isPlaying => _controller.value.isPlaying;

  bool get isBuffering => _isBuffering;
  set isBuffering(bool value) {
    _isBuffering = value;
    notifyListeners();
  }

  int get lastVideoPosition => _lastVideoPosition;
  set lastVideoPosition(int value) {
    _lastVideoPosition = value;
    notifyListeners();
  }

  bool get showSettingsMenu => _showSettingsMenu;
  set showSettingsMenu(bool value) {
    _showSettingsMenu = value;
    notifyListeners();
  }

  @override
  void dispose() async {
    await _controller?.pause();
    await _controller.dispose();
    _controller = null;
    super.dispose();
  }

  Future<void> openFullScreen(BuildContext context) async {
    if (kIsWeb) {
      html.document.documentElement.requestFullscreen();
      html.document.documentElement.onFullscreenChange.listen((_) {
        _isFullScreen = html.document.fullscreenElement != null;
      });
    } else {
      _isFullScreen = true;
      notifyListeners();
      await PushRoute.page(
        context,
        ListenableProvider.value(
          value: VideoQuery().video(context),
          child: Provider.value(
            value: VideoQuery().videoMetadata(context),
            child: FullScreenPage(),
          ),
        ),
        transition: false,
      );
    }
  }

  Future<void> closeFullScreen(BuildContext context) async {
    if (kIsWeb)
      html.document.exitFullscreen();
    else if (_isFullScreen) {
      _isFullScreen = false;
      notifyListeners();
      await Misc.setSystemOrientation(SystemOrientation.portraitUp);
      await Misc.setSystemOverlay(SystemOverlay.values);
      Misc.delayed(3200, () {
        Misc.setSystemOrientation(SystemOrientation.values);
      });
      Navigator.pop(context);
    }
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
    if (isPlaying && showThumbnail) {
      showThumbnail = false;
      notifyListeners();
    }
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
