import 'dart:async';
import 'dart:developer';
import 'package:video_player/video_player.dart';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

import 'package:video_viewer/ui/fullscreen.dart';
import 'package:video_viewer/domain/entities/ads.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/subtitle.dart';
import 'package:video_viewer/domain/entities/video_source.dart';

const int _kMillisecondsToHideTheOverlay = 2800;

class VideoViewerController extends ChangeNotifier with WidgetsBindingObserver {
  /// Controls a platform video viewer, and provides updates when the state is
  /// changing.
  ///
  /// Instances must be initialized with initialize.
  ///...
  /// The video is displayed in a Flutter app by creating a [VideoPlayer] widget.
  ///
  /// To reclaim the resources used by the player call [dispose].
  ///
  /// After [dispose] all further calls are ignored.
  VideoViewerController() {
    isShowingSecondarySettingsMenus.addAll(List.filled(8, false));
  }

  final List<VideoViewerAd> adsSeen = [];
  final List<bool> isShowingSecondarySettingsMenus = [];
  late bool looping;

  bool _mounted = false;

  VideoViewerAd? _activeAd;
  Timer? _activeAdTimeRemaing;
  String? _activeSourceName;
  String? _activeSubtitle;
  SubtitleData? _activeSubtitleData;
  Duration? _adTimeWatched;
  List<VideoViewerAd>? _ads;
  Timer? _closeOverlayButtons;
  Duration? _duration;
  bool _isBuffering = false,
      _isShowingOverlay = false,
      _isFullScreen = false,
      _isGoingToCloseOverlay = false,
      _isGoingToOpenOrCloseFullscreen = false,
      _isShowingThumbnail = true,
      _isShowingSettingsMenu = false,
      _isShowingMainSettingsMenu = false,
      _isDraggingProgressBar = false,
      _isShowingChat = false,
      _videoWasPlaying = false,
      _isChangingSource = false;

  BuildContext? context;
  Duration _maxBuffering = Duration.zero;

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

  VideoViewerSubtitle? _subtitle;
  VideoPlayerController? _video;

  Duration get beginRange {
    final Duration duration = video!.value.duration;
    final Tween<Duration>? range = activeSource?.range;
    Duration begin = range?.begin ?? Duration.zero;
    if (begin >= duration) begin = Duration.zero;
    return begin;
  }

  Duration get endRange {
    final Duration duration = video!.value.duration;
    final Tween<Duration>? range = activeSource?.range;
    Duration end = range?.end ?? duration;
    if (end >= duration) end = duration;
    return end;
  }

  bool get mounted => _mounted;

  Duration get position => video!.value.position - beginRange;

  Duration get duration => _duration!;

  VideoSource? get activeSource => _source?[_activeSourceName];

  VideoViewerAd? get activeAd => _activeAd;

  Duration? get adTimeWatched => _adTimeWatched;

  VideoPlayerController? get video => _video;

  SubtitleData? get activeCaptionData => _activeSubtitleData;

  List<SubtitleData>? get subtitles => _subtitle?.subtitles;

  VideoViewerSubtitle? get subtitle => _subtitle;

  String? get activeCaption => _activeSubtitle;

  String? get activeSourceName => _activeSourceName;

  Duration get maxBuffering => _maxBuffering;

  bool get isShowingMainSettingsMenu => _isShowingMainSettingsMenu;

  bool get isShowingOverlay => _isShowingOverlay;

  bool get isFullScreen => _isFullScreen;

  bool get isPlaying => _video!.value.isPlaying;

  bool get isShowingChat => _isShowingChat;

  bool get isChangingSource => _isChangingSource;

  set isShowingChat(bool isShowingChat) {
    _isShowingChat = isShowingChat;
    notifyListeners();
  }

  bool get isBuffering => _isBuffering;

  set isBuffering(bool value) {
    _isBuffering = value;
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

  //-----------------//
  //SOURCE CONTROLLER//
  //-----------------//
  @override
  void notifyListeners() {
    if (mounted) super.notifyListeners();
  }

  Future<void> initialize(
    Map<String, VideoSource> sources, {
    bool autoPlay = true,
  }) async {
    WidgetsBinding.instance?.addObserver(this);
    final MapEntry<String, VideoSource> entry = sources.entries.first;
    _mounted = true;
    _source = sources;
    await changeSource(
      name: entry.key,
      source: entry.value,
      autoPlay: autoPlay,
    );
    log("VIDEO VIEWER INITIALIZED");
    Wakelock.enable();
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance?.removeObserver(this);
    _mounted = false;
    _closeOverlayButtons?.cancel();
    _deleteAdTimer();
    _video?.removeListener(_videoListener);
    _video?.pause();
    _video?.dispose();
    Wakelock.disable();
    log("VIDEO VIEWER DISPOSED");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      log("APP PAUSED");
      _videoWasPlaying = isPlaying;
      if (_videoWasPlaying) pause();
    } else if (state == AppLifecycleState.resumed) {
      log("APP RESUMED");
      if (_videoWasPlaying) play();
    }
  }

  ///The [source.video] must be initialized previously
  ///
  ///[inheritPosition] has the function to inherit last controller values.
  ///It's useful on changed quality video.
  ///
  ///For example:
  ///```dart
  ///   _video.seekTo(lastController.value.position);
  /// ```
  Future<void> changeSource({
    required VideoSource source,
    required String name,
    bool inheritPosition = true,
    bool autoPlay = true,
  }) async {
    final double speed = _video?.value.playbackSpeed ?? 1.0;
    final double volume = _video?.value.volume ?? 1.0;
    final Duration lastPositon = _video != null ? position : Duration.zero;

    //Change the subtitles
    if (source.subtitle != null) {
      final subtitle = source.subtitle![source.intialSubtitle];
      if (subtitle != null) {
        changeSubtitle(
          subtitle: subtitle,
          subtitleName: source.intialSubtitle,
        );
      }
    }

    //Delete all ads seen
    _ads = source.ads;
    if (_ads != null) {
      for (int i = 0; i < _ads!.length; i++) {
        for (final adSeen in adsSeen) {
          if (_ads![i] == adSeen) _ads?.removeAt(i);
        }
      }
    }

    //Initialize the video
    final oldVideo = _video;
    if (oldVideo != null) {
      _isChangingSource = true;
      notifyListeners();
    }
    await source.video.initialize();
    if (oldVideo != null) {
      oldVideo.removeListener(_videoListener);
      await oldVideo.pause();
      await oldVideo.dispose();
    }
    _video = source.video;
    source.video.addListener(_videoListener);
    _activeSourceName = name;
    _duration = endRange - beginRange;
    _isChangingSource = false;
    notifyListeners();

    //Update it inheritValues
    await _video?.setPlaybackSpeed(speed);
    await _video?.setLooping(looping);
    await _video?.setVolume(volume);

    if (inheritPosition) {
      await seekTo(lastPositon);
    } else if (source.range != null) {
      await seekTo(beginRange);
    }

    if (autoPlay) await play();
    notifyListeners();
  }

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

  //-------------//
  //VIDEO CONTROL//
  //-------------//

  Future<void> playOrPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await _seekToBegin();
      await play();
    }
  }

  Future<void> play() async {
    if (!_isChangingSource) {
      if (looping) _seekToBegin();
      if (_activeAd == null) await _video?.play();
    }
  }

  Future<void> pause() async {
    if (!_isChangingSource) {
      await _video?.pause();
    }
  }

  Future<void> _seekToBegin() async {
    if (position >= duration) await seekTo(beginRange);
  }

  Future<void> seekTo(Duration position) async {
    if (!_isChangingSource) {
      final Duration end = endRange;
      final Duration begin = beginRange;
      if (position < begin) {
        position = begin;
      } else if (position > end) {
        position = end;
      }
      await _video?.seekTo(position);
    }
  }

  void _videoListener() {
    final VideoPlayerValue value = _video!.value;
    final Tween<Duration>? range = activeSource?.range;
    final Duration position = value.position;
    final Duration duration = value.duration;
    final bool buffering = value.isBuffering;

    //Cut the video from Source range
    if (range != null) {
      final Duration end = endRange;
      final Duration begin = beginRange;
      if (position < begin || position >= end) {
        if (looping) {
          _video?.seekTo(begin);
        } else if (isPlaying && position >= end) {
          _video?.pause();
        }
      }
    }

    //Hide the Thumbnail when the player is playing for first time
    if (isPlaying && isShowingThumbnail) {
      _isShowingThumbnail = false;
      notifyListeners();
    }

    //Show the Buffering Widget
    if (_isBuffering != buffering && !_isDraggingProgressBar) {
      _isBuffering = buffering;
      notifyListeners();
    }

    //Update the buffering progress bar
    _maxBuffering = Duration.zero;
    for (DurationRange range in _video!.value.buffered) {
      final Duration end = range.end;
      if (end > maxBuffering) {
        _maxBuffering = end;
        notifyListeners();
      }
    }

    //Hide the overlay after _kMillisecondsToHideTheOverlay milliseconds
    //when the video is playing
    if (_isShowingOverlay) {
      if (isPlaying) {
        if (position >= duration && looping) {
          seekTo(Duration.zero);
        } else {
          if (_closeOverlayButtons == null) _startCloseOverlay();
        }
      } else if (_isGoingToCloseOverlay) cancelCloseOverlay();
    }

    //Show the current Subtitle
    if (_subtitle != null) {
      if (_activeSubtitleData != null) {
        if (!(position > _activeSubtitleData!.start &&
            position < _activeSubtitleData!.end)) _findSubtitle();
      } else {
        _findSubtitle();
      }
    }

    //Show the current Ad
    if (_ads != null) {
      if (_activeAd != null) {
        final Duration start = _getAdStartTime(_activeAd!);
        if (!(position > start &&
            position < start + _activeAd!.durationToEnd)) {
          _findAd();
        }
      } else {
        _findAd();
      }
    }
  }

  //---//
  //ADS//
  //---//
  Future<void> skipAd() async {
    _activeAd = null;
    _deleteAdTimer();
    await play();
    notifyListeners();
  }

  void _findAd() async {
    final Duration position = this.position;
    bool foundOne = false;

    for (VideoViewerAd ad in _ads!) {
      final Duration start = _getAdStartTime(ad);
      if (position > start &&
          position < start + ad.durationToEnd &&
          _activeAd != ad) {
        _activeAd = ad;
        await _video?.pause();
        _ads?.remove(ad);
        _createAdTimer();
        adsSeen.add(ad);
        foundOne = true;
        notifyListeners();
        break;
      }
    }

    if (!foundOne && _activeAd != null) {
      _activeAd = null;
      _deleteAdTimer();
      notifyListeners();
    }
  }

  Duration _getAdStartTime(VideoViewerAd ad) {
    final double? fractionToStart = ad.fractionToStart;
    final Duration? durationToStart = ad.durationToStart;
    return durationToStart ?? duration * fractionToStart!;
  }

  void _createAdTimer() {
    final Duration refreshDuration = Duration(milliseconds: 500);
    _activeAdTimeRemaing = Timer.periodic(refreshDuration, (timer) {
      if (_adTimeWatched == null) {
        _adTimeWatched = refreshDuration;
      } else {
        _adTimeWatched = _adTimeWatched! + refreshDuration;
      }

      if (_activeAd != null) {
        if (_adTimeWatched! >= _activeAd!.durationToSkip) {
          timer.cancel();
        }
      }
      notifyListeners();
    });
  }

  void _deleteAdTimer() {
    _activeAdTimeRemaing?.cancel();
    _activeAdTimeRemaing = null;
  }

  //---------//
  //SUBTITLES//
  //---------//
  void _findSubtitle() {
    final Duration position = _video!.value.position;
    bool foundOne = false;
    for (SubtitleData subtitle in subtitles!) {
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
  void cancelCloseOverlay() {
    _isGoingToCloseOverlay = false;
    _closeOverlayButtons?.cancel();
    _closeOverlayButtons = null;
    notifyListeners();
  }

  void _startCloseOverlay() {
    if (!_isGoingToCloseOverlay) {
      _isGoingToCloseOverlay = true;
      _closeOverlayButtons = Misc.timer(_kMillisecondsToHideTheOverlay, () {
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
  void showAndHideOverlay([bool? show]) {
    if (!isShowingChat) {
      _isShowingOverlay = show ?? !_isShowingOverlay;
      if (_isShowingOverlay) cancelCloseOverlay();
      notifyListeners();
    } else {
      isShowingChat = false;
    }
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
  Future<void> openOrCloseFullscreen() async {
    if (!_isGoingToOpenOrCloseFullscreen) {
      _isGoingToOpenOrCloseFullscreen = true;
      if (!_isFullScreen) {
        await openFullScreen();
      } else {
        await closeFullScreen();
      }
      _isGoingToOpenOrCloseFullscreen = false;
    }
    notifyListeners();
  }

  ///When you want to open FullScreen Page, you need pass the FullScreen's context,
  ///because this function do **Navigator.push(context, TransparentRoute(...))**
  Future<void> openFullScreen() async {
    if (context != null && !_isFullScreen) {
      _isFullScreen = true;
      final VideoQuery query = VideoQuery();
      final metadata = query.videoMetadata(context!);
      final Duration transition = metadata.style.transitions;
      context?.navigator.push(PageRouteBuilder(
        opaque: false,
        fullscreenDialog: true,
        transitionDuration: transition,
        reverseTransitionDuration: transition,
        pageBuilder: (_, __, ___) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: query.video(context!)),
            Provider.value(value: metadata),
          ],
          child: FullScreenPage(
            fixedLandscape: metadata.onFullscreenFixLandscape,
          ),
        ),
      ));
    }
  }

  ///When you want to close FullScreen Page, you need pass the FullScreen's context,
  ///because this function do **Navigator.pop(context);**
  Future<void> closeFullScreen() async {
    if (_isFullScreen) {
      _isFullScreen = false;
      await Misc.setSystemOverlay(SystemOverlay.values);
      await Misc.setSystemOrientation(SystemOrientation.values);
      context?.navigator.pop();
    }
  }
}
