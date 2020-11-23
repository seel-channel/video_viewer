import 'dart:io';
import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoSource {
  ///Constructs a [VideoPlayerController] playing a video from obtained from the network.
  static VideoPlayerController network(String source) {
    return VideoPlayerController.network(source);
  }

  ///Constructs a [VideoPlayerController] playing a video from an asset.
  static VideoPlayerController asset(String source) {
    return VideoPlayerController.asset(source);
  }

  ///Constructs a [VideoPlayerController] playing a video from a file.
  ///This will load the file from the file-URI given by: 'file://${file.path}'.
  static VideoPlayerController file(File file) {
    return VideoPlayerController.file(file);
  }

  ///Constructs a [VideoPlayerController] playing a video from obtained from the network and save that on cache.
  static Future<VideoPlayerController> cachedNetwork(String source) async {
    final BaseCacheManager _cacheManager = DefaultCacheManager();
    final fileInfo = await _cacheManager.getFileFromCache(source);

    if (fileInfo == null || fileInfo.file == null) {
      unawaited(_cacheManager.downloadFile(source));
      return VideoPlayerController.network(source);
    } else {
      return VideoPlayerController.file(fileInfo.file);
    }
  }
}

/// It is a function that returns a map from VideoSource.cachedNetwork, the input
/// data must be of type URL.
///
///INPUT:
///```dart
///{
///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
///}
/// ```
///OUTPUT:
///```dart
///{
///    "720p": VideoSource.cachedNetwork("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4"),
///    "1080p": VideoSource.cachedNetwork("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
///}
/// ```
Future<Map<String, VideoPlayerController>> getCachedVideoSources(
  Map<String, String> sources,
) async {
  Map<String, VideoPlayerController> videoSources = Map();
  for (String key in sources.keys)
    videoSources[key] = await VideoSource.cachedNetwork(sources[key]);
  return videoSources;
}

/// It is a function that returns a map from VideoSource.network, the input
/// data must be of type URL.
///
///INPUT:
///```dart
///{
///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
///}
/// ```
///OUTPUT:
///```dart
///{
///    "720p": VideoSource.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4"),
///    "1080p": VideoSource.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
///}
/// ```
Map<String, VideoPlayerController> getNetworkVideoSources(
    Map<String, String> sources) {
  Map<String, VideoPlayerController> videoSources = Map();
  for (String key in sources.keys)
    videoSources[key] = VideoSource.network(sources[key]);
  return videoSources;
}
