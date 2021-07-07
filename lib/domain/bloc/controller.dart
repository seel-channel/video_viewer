import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/ui/fullscreen.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/subtitle.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:wakelock/wakelock.dart';

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
  VideoViewerController() {
    this.isShowingSecondarySettingsMenus = List.filled(12, false);
  }

  /// Receive a list of all the resources to be played.
  ///
  ///SYNTAX EXAMPLE:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  ///```
  Map<String, VideoSource>? _source;

  late bool looping;
  String? _activeSource;
  String? _activeSubtitle;
  VideoViewerSubtitle? _subtitle;
  VideoPlayerController? _video;
  SubtitleData? _activeSubtitleData;

  int _lastVideoPosition = 0;
  bool _isBuffering = false,
      _isShowingOverlay = false,
      _isFullScreen = false,
      _isGoingToCloseOverlay = false,
      _isShowingThumbnail = true,
      _isShowingSettingsMenu = false,
      _isShowingMainSettingsMenu = false,
      _isDraggingProgressBar = false;

  Timer? _closeOverlayButtons;
  List<bool> isShowingSecondarySettingsMenus = [];
  Duration _maxBuffering = Duration.zero;

  VideoPlayerController? get video => _video;
  SubtitleData? get activeCaptionData => _activeSubtitleData;
  List<SubtitleData> get subtitles => _subtitle!.subtitles;
  VideoViewerSubtitle? get subtitle => _subtitle;
  String? get activeCaption => _activeSubtitle;
  String? get activeSource => _activeSource;
  Duration get maxBuffering => _maxBuffering;

  bool get isShowingMainSettingsMenu => _isShowingMainSettingsMenu;
  bool get isShowingOverlay => _isShowingOverlay;
  bool get isFullScreen => _isFullScreen;
  bool get isPlaying => _video!.value.isPlaying;

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

  Map<String, VideoSource>? get source => _source;
  set source(Map<String, VideoSource>? value) {
    _source = value;
    notifyListeners();
  }

  Future<void> initialize(
    Map<String, VideoSource> sources, {
    bool autoPlay = true,
  }) async {
    _source = sources;
    final String activedSource = sources.keys.toList().first;
    final VideoSource source = sources.values.toList().first;

    await changeSource(
      source: source,
      name: activedSource,
      autoPlay: autoPlay,
    );

    Wakelock.enable();
  }

  @override
  Future<void> dispose() async {
    _closeOverlayButtons?.cancel();
    if (_video != null) {
      await _video?.pause();
      _video!.dispose();
    }
    Wakelock.disable();
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
  ///   _video.setPlaybackSpeed(lastController.value.playbackSpeed);
  ///   _video.seekTo(lastController.value.position);
  /// ```
  Future<void> changeSource({
    required VideoSource source,
    required String name,
    bool inheritValues = true,
    bool autoPlay = true,
  }) async {
    if (source.subtitle != null) {
      final subtitle = source.subtitle![source.intialSubtitle];
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
    if (_video != null) {
      speed = _video!.value.playbackSpeed;
      position = _video!.value.position;
    }

    await source.video.initialize();
    _video = source.video;
    _video!.addListener(_videoListener);

    if (inheritValues) {
      await _video!.setPlaybackSpeed(speed);
      await _video!.seekTo(position);
    }

    await _video!.setLooping(looping);
    if (autoPlay) await _video!.play();
    notifyListeners();
  }

  ///DON'T TOUCH >:]
  Future<void> changeSubtitle({
    required VideoViewerSubtitle? subtitle,
    required String subtitleName,
  }) async {
    _activeSubtitle = subtitleName;
    _activeSubtitleData = null;
    _subtitle = subtitle;
    if (subtitle != null) await _subtitle!.initialize();
    notifyListeners();
  }

  //---------//
  //LISTENERS//
  //---------//
  void _videoListener() {
    final value = _video!.value;
    final position = value.position;
    final buffering = video!.value.isBuffering;

    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    if (_isBuffering != buffering && !_isDraggingProgressBar) {
      _isBuffering = buffering;
      notifyListeners();
    }

    _maxBuffering = Duration.zero;
    for (DurationRange range in _video!.value.buffered) {
      final Duration end = range.end;
      if (end > maxBuffering) {
        _maxBuffering = end;
        notifyListeners();
      }
    }

    if (_isShowingOverlay) {
      if (isPlaying) {
        if (position >= value.duration && looping) {
          _video!.seekTo(Duration.zero);
        } else {
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseOverlay) cancelCloseOverlay();
    }

    if (_subtitle != null) {
      if (_activeSubtitleData != null) {
        if (!(position > _activeSubtitleData!.start &&
            position < _activeSubtitleData!.end)) _findSubtitle();
      } else {
        _findSubtitle();
      }
    }
  }

  void _findSubtitle() {
    final position = _video!.value.position;
    bool foundOne = false;
    for (SubtitleData subtitle in subtitles) {
      if (position > subtitle.start &&
          position < subtitle.end &&
          _activeSubtitleData != subtitle) {
        _activeSubtitleData = subtitle;
        foundOne = true;
        notifyListeners();
        break;
      }
    }
    if (!foundOne && _activeSubtitleData != null) {
      _activeSubtitleData = null;
      notifyListeners();
    }
  }

  //-----//
  //TIMER//
  //-----//
  ///DON'T TOUCH >:]
  void cancelCloseOverlay() {
    _isGoingToCloseOverlay = false;
    _closeOverlayButtons?.cancel();
    _closeOverlayButtons = null;
    notifyListeners();
  }

  void _startCloseOverlay() {
    if (!_isGoingToCloseOverlay) {
      _isGoingToCloseOverlay = true;
      _closeOverlayButtons = Misc.timer(3200, () {
        if (isPlaying) {
          _isShowingOverlay = false;
          cancelCloseOverlay();
        }
      });
      notifyListeners();
    }
  }

  //-------//
  //OVERLAY//
  //-------//
  Future<void> onTapPlayAndPause() async {
    final value = _video!.value;
    if (isPlaying) {
      await _video!.pause();
      if (!_isShowingOverlay) _isShowingOverlay = false;
    } else {
      if (value.position >= value.duration) await _video!.seekTo(Duration.zero);
      _lastVideoPosition = _lastVideoPosition - 1;
      await _video!.play();
    }
    notifyListeners();
  }

  void showAndHideOverlay([bool? show]) {
    _isShowingOverlay = show ?? !_isShowingOverlay;
    if (_isShowingOverlay) _isGoingToCloseOverlay = false;
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
    _isFullScreen = true;
    final query = VideoQuery();
    final metadata = query.videoMetadata(context);
    await context.toTransparentPage(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: query.video(context)),
          Provider.value(value: metadata),
        ],
        child: const FullScreenPage(),
      ),
      duration: metadata.style.transitions,
    );
    notifyListeners();
  }

  ///When you want to close FullScreen Page, you need pass the FullScreen's context,
  ///because this function do **Navigator.pop(context);**
  Future<void> closeFullScreen(BuildContext context) async {
    if (_isFullScreen) {
      _isFullScreen = false;
      context.goBack();
      await Misc.setSystemOverlay(SystemOverlay.values);
      await Misc.setSystemOrientation(SystemOrientation.values);
      notifyListeners();
    }
  }
}
