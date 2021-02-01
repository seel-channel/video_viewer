import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/subtitle.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/ui/fullscreen.dart';

class VideoViewerController extends ChangeNotifier {
  VideoViewerController({
    VideoPlayerController controller,
    String activeSource,
    this.isLooping,
  }) {
    this._controller = controller;
    this._activeSource = activeSource;
    this._controller.addListener(_videoListener);
    this.isShowingSecondarySettingsMenus = List.filled(12, false);
  }

  final bool isLooping;
  String _activeSource;
  String _activeSubtitle;
  VideoViewerSubtitle _subtitle;
  VideoPlayerController _controller;
  SubtitleData _activeSubtitleData;

  int _lastVideoPosition = 0;
  bool _isBuffering = false,
      _isShowingOverlay = false,
      _isFullScreen = false,
      _isGoingToCloseBufferingWidget = false,
      _isShowingThumbnail = true,
      _isShowingSettingsMenu = false,
      _isShowingMainSettingsMenu = false;
  Timer _closeOverlayButtons, _timerPosition;
  List<bool> isShowingSecondarySettingsMenus = [];

  VideoPlayerController get controller => _controller;
  SubtitleData get activeCaptionData => _activeSubtitleData;
  List<SubtitleData> get subtitles => _subtitle.subtitles;
  String get activeCaption => _activeSubtitle;
  String get activeSource => _activeSource;

  bool get isShowingMainSettingsMenu => _isShowingMainSettingsMenu;
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
    super.dispose();
  }

  //----------------//
  //VIDEO CONTROLLER//
  //----------------//
  Future<void> changeSource({
    @required VideoSource source,
    @required String sourceName,
  }) async {
    final double speed = _controller.value.playbackSpeed;
    final Duration position = _controller.value.position;
    final VideoViewerSubtitle subtitle = source.subtitle.values.toList().first;

    await source.video.initialize();
    await subtitle?.initialize();

    _subtitle = subtitle;
    _controller = source.video;
    _activeSource = sourceName;

    _controller.addListener(_videoListener);
    if (source.inheritValues) {
      await _controller.setPlaybackSpeed(speed);
      await _controller.seekTo(position);
    }
    await _controller.setLooping(isLooping);
    await _controller.play();
    notifyListeners();
  }

  Future<void> changeSubtitle({
    @required VideoViewerSubtitle subtitle,
    @required String subtitleName,
  }) async {
    await subtitle?.initialize();
    _subtitle = subtitle;
    _activeSubtitle = subtitleName;
    _activeSubtitleData = null;
    notifyListeners();
  }

  void _videoListener() {
    final value = _controller.value;
    final position = value.position;

    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    if (_isShowingOverlay) {
      if (isPlaying) {
        if (position >= value.duration && isLooping) {
          _controller.seekTo(Duration.zero);
        } else {
          if (_timerPosition == null) _createBufferTimer();
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseBufferingWidget) cancelCloseOverlay();
    }

    if (_subtitle != null) {
      for (SubtitleData subtitle in subtitles) {
        if (position > subtitle.start &&
            position < subtitle.end &&
            _activeSubtitleData != subtitle) {
          _activeSubtitleData = subtitle;
          notifyListeners();
          break;
        }
      }
    }
  }

  //-----//
  //TIMER//
  //-----//
  void cancelCloseOverlay() {
    _isGoingToCloseBufferingWidget = false;
    _closeOverlayButtons?.cancel();
    _closeOverlayButtons = null;
    notifyListeners();
  }

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

  void closeAllSecondarySettingsMenus() {
    _isShowingMainSettingsMenu = true;
    isShowingSecondarySettingsMenus.fillRange(
      0,
      isShowingSecondarySettingsMenus.length,
      false,
    );
    notifyListeners();
  }

  void openSecondarySettingMenu(int index) {
    _isShowingSettingsMenu = true;
    _isShowingMainSettingsMenu = false;
    isShowingSecondarySettingsMenus[index] = true;
    notifyListeners();
  }

  void openSettingsMenu() {
    _isShowingSettingsMenu = true;
    _isShowingMainSettingsMenu = true;
    notifyListeners();
  }

  void closeSettingsMenu() {
    _isShowingSettingsMenu = false;
    _isShowingMainSettingsMenu = false;
    notifyListeners();
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
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(
                value: VideoQuery().video(context, listen: false),
              ),
              ChangeNotifierProvider.value(
                value: VideoQuery().videoMetadata(context, listen: false),
              ),
            ],
            child: FullScreenPage(),
          ),
        ),
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
}
