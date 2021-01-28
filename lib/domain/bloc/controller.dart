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
    this.isLooping,
  }) {
    this._activeSource = activeSource;
    this._controller = controller;
    this._controller.addListener(_videoListener);
  }

  final bool isLooping;
  VideoPlayerController _controller;
  String _activeSource;
  bool _isBuffering = false,
      _isShowingOverlay = false,
      _isFullScreen = false,
      _isGoingToCloseBufferingWidget = false;
  int _lastVideoPosition = 0;
  Timer _closeOverlayButtons, _timerPosition;

  bool _isShowingThumbnail = true;
  bool _isShowingSettingsMenu = false;

  VideoPlayerController get controller => _controller;
  String get activeSource => _activeSource;
  bool get isShowingOverlay => _isShowingOverlay;
  bool get isFullScreen => _isFullScreen;
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

  bool get isShowingSettingsMenu => _isShowingSettingsMenu;
  set isShowingSettingsMenu(bool value) {
    _isShowingSettingsMenu = value;
    notifyListeners();
  }

  bool get isShowingThumbnail => _isShowingThumbnail;
  set isShowingThumbnail(bool value) {
    _isShowingThumbnail = value;
    notifyListeners();
  }

  @override
  void dispose() async {
    _timerPosition?.cancel();
    _closeOverlayButtons?.cancel();
    await _controller?.pause();
    await _controller.dispose();
    _closeOverlayButtons = null;
    _timerPosition = null;
    _controller = null;
    super.dispose();
  }

  //----------//
  //FULLSCREEN//
  //----------//
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
        MultiProvider(
          providers: [
            ListenableProvider.value(value: VideoQuery().video(context)),
            Provider.value(value: VideoQuery().videoMetadata(context)),
          ],
          child: FullScreenPage(),
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
  }) async {
    final double speed = _controller.value.playbackSpeed;
    final Duration seekTo = _controller.value.position;

    await source.initialize();
    _controller = source;
    _activeSource = activeSource;
    _controller.addListener(_videoListener);
    await _controller.setPlaybackSpeed(speed);
    await _controller.setLooping(isLooping);
    await _controller.seekTo(seekTo);
    await _controller.play();
    notifyListeners();
  }

  void _videoListener() {
    final value = _controller.value;
    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }
    if (_isShowingOverlay) {
      if (isPlaying) {
        if (value.position >= value.duration && isLooping) {
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
          _isShowingOverlay = false;
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

  //-------//
  //OVERLAY//
  //-------//
  Future<void> onTapPlayAndPause() async {
    final value = _controller.value;
    if (isPlaying) {
      await _controller.pause();
      if (!_isShowingOverlay) _isShowingOverlay = false;
    } else {
      if (value.position >= value.duration)
        await _controller.seekTo(Duration.zero);
      _lastVideoPosition = _lastVideoPosition - 1;
      await _controller.play();
    }
    notifyListeners();
  }

  void showAndHideOverlay([bool show]) {
    _isShowingOverlay = show ?? !_isShowingOverlay;
    if (_isShowingOverlay) _isGoingToCloseBufferingWidget = false;
    notifyListeners();
  }
}
