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
  /// Controls a platform video viewer, and provides updates when the state is
  /// changing.
  ///
  /// Instances must be initialized with initialize.
  ///
  /// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
  ///
  /// To reclaim the resources used by the player call [dispose].
  ///
  /// After [dispose] all further calls are ignored.
  VideoViewerController()
      : this.isShowingSecondarySettingsMenus = List.filled(12, false);

  /// Receive a list of all the resources to be played.
  ///
  ///SYNTAX EXAMPLE:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  ///```
  Map<String, VideoSource> _source;

  bool looping;
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
      _isShowingMainSettingsMenu = false,
      _isDraggingProgressBar = false;

  Timer _closeOverlayButtons, _timerPosition;
  List<bool> isShowingSecondarySettingsMenus = [];
  Duration _maxBuffering = Duration.zero;

  VideoPlayerController get controller => _controller;
  SubtitleData get activeCaptionData => _activeSubtitleData;
  List<SubtitleData> get subtitles => _subtitle.subtitles;
  VideoViewerSubtitle get subtitle => _subtitle;
  String get activeCaption => _activeSubtitle;
  String get activeSource => _activeSource;
  Duration get maxBuffering => _maxBuffering;

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

  bool get isDraggingProgressBar => _isDraggingProgressBar;
  set isDraggingProgressBar(bool value) {
    _isDraggingProgressBar = value;
    notifyListeners();
  }

  Map<String, VideoSource> get source => _source;
  set source(Map<String, VideoSource> value) {
    _source = value;
    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    _timerPosition?.cancel();
    _closeOverlayButtons?.cancel();
    await _controller?.pause();
    await _controller.dispose();
    super.dispose();
  }

  //-----------------//
  //SOURCE CONTROLLER//
  //-----------------//
  ///The [source.video] must be initialized previously
  ///
  ///[inheritValues] has the function to inherit last controller values.
  ///It's useful on changed quality video.
  ///
  ///For example:
  ///```dart
  ///   _controller.setPlaybackSpeed(lastController.value.playbackSpeed);
  ///   _controller.seekTo(lastController.value.position);
  /// ```
  Future<void> changeSource({
    @required VideoSource source,
    @required String name,
    bool inheritValues = true,
    bool autoPlay = true,
  }) async {
    if (source.subtitle != null) {
      final subtitle = source.subtitle[source.intialSubtitle ?? ""];
      if (subtitle != null) {
        changeSubtitle(
          subtitle: subtitle,
          subtitleName: source.intialSubtitle,
        );
      }
    }

    _activeSource = name;
    double speed = 1.0;
    Duration position = Duration.zero;
    if (_controller != null) {
      speed = _controller.value.playbackSpeed;
      position = _controller.value.position;
    }

    await source.video.initialize();
    _controller = source.video;
    _controller.addListener(_videoListener);

    if (inheritValues) {
      await _controller.setPlaybackSpeed(speed);
      await _controller.seekTo(position);
    }

    await _controller.setLooping(looping);
    if (autoPlay) await _controller.play();
    notifyListeners();
  }

  ///DON'T TOUCH >:]
  Future<void> changeSubtitle({
    @required VideoViewerSubtitle subtitle,
    @required String subtitleName,
  }) async {
    _activeSubtitle = subtitleName;
    _activeSubtitleData = null;
    _subtitle = subtitle;
    if (subtitle != null) await _subtitle.initialize();
    notifyListeners();
  }

  //---------//
  //LISTENERS//
  //---------//
  void _videoListener() {
    final value = _controller.value;
    final position = value.position;

    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    _maxBuffering = Duration.zero;
    for (DurationRange range in controller.value.buffered) {
      final Duration end = range.end;
      if (end > maxBuffering) {
        _maxBuffering = end;
        notifyListeners();
      }
    }

    if (_isShowingOverlay) {
      if (isPlaying) {
        if (position >= value.duration && looping) {
          _controller.seekTo(Duration.zero);
        } else {
          if (_timerPosition == null) _createBufferTimer();
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseBufferingWidget) cancelCloseOverlay();
    }

    if (_subtitle != null) {
      if (_activeSubtitleData != null) {
        if (!(position > _activeSubtitleData.start &&
            position < _activeSubtitleData.end)) _findSubtitle();
      } else {
        _findSubtitle();
      }
    }
  }

  void _findSubtitle() {
    final position = _controller.value.position;
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

  //-----//
  //TIMER//
  //-----//
  ///DON'T TOUCH >:]
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

  //-------------//
  //SETTINGS MENU//
  //-------------//
  void closeAllSecondarySettingsMenus() {
    _isShowingMainSettingsMenu = true;
    isShowingSecondarySettingsMenus.fillRange(
      0,
      isShowingSecondarySettingsMenus.length,
      false,
    );
    notifyListeners();
  }

  void openSecondarySettingsMenu(int index) {
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
  ///When you want to open FullScreen Page, you need pass the FullScreen's context,
  ///because this function do **Navigator.push(context, MaterialPageRoute(...))**
  Future<void> openFullScreen(BuildContext context) async {
    if (kIsWeb) {
      html.document.documentElement.requestFullscreen();
      html.document.documentElement.onFullscreenChange.listen((_) {
        _isFullScreen = html.document.fullscreenElement != null;
      });
    } else {
      _isFullScreen = true;
      final query = VideoQuery();
      final metadata = query.videoMetadata(context);
      await context.toTransparentPage(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: query.video(context)),
            Provider.value(value: metadata),
          ],
          child: FullScreenPage(),
        ),
        duration: metadata.style.transitions,
      );
      notifyListeners();
    }
  }

  ///When you want to close FullScreen Page, you need pass the FullScreen's context,
  ///because this function do **Navigator.pop(context);**
  Future<void> closeFullScreen(BuildContext context) async {
    if (kIsWeb)
      html.document.exitFullscreen();
    else if (_isFullScreen) {
      _isFullScreen = false;
      context.goBack();
      await Misc.setSystemOverlay(SystemOverlay.values);
      await Misc.setSystemOrientation(SystemOrientation.values);
      notifyListeners();
    }
  }
}
