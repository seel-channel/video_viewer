import 'dart:io';
import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class VideoSource {
  static VideoPlayerController network(String source) {
    return VideoPlayerController.network(source);
  }

  static VideoPlayerController asset(String source) {
    return VideoPlayerController.asset(source);
  }

  static VideoPlayerController file(File file) {
    return VideoPlayerController.file(file);
  }

  static Future<VideoPlayerController> cachedNetwork(String source) async {
    final BaseCacheManager _cacheManager = DefaultCacheManager();
    final fileInfo = await _cacheManager.getFileFromCache(source);

    if (fileInfo == null || fileInfo.file == null) {
      unawaited(_cacheManager.downloadFile(source));
      //await _cacheManager.getSingleFile(source);
      return VideoPlayerController.network(source);
    } else {
      return VideoPlayerController.file(fileInfo.file);
    }
  }
}

///Es una función que devuelve un mapa de VideoSource.cachedNetwork, la entrada
///de datos debe de ser del tipo URL.
///
///Por ejemplo:
///```dart
///{
///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
///}
/// ```
Future<Map<String, VideoPlayerController>> getCachedVideoSources(
  Map<String, String> sources,
) async {
  Map<String, VideoPlayerController> videoSources = Map();
  for (String key in sources.keys) {
    videoSources[key] = await VideoSource.cachedNetwork(sources[key]);
  }
  return videoSources;
}

///Es una función que devuelve un mapa de VideoSource.network, la entrada
///de datos debe de ser del tipo URL.
///
///Por ejemplo:
///```dart
///{
///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
///}
/// ```
Map<String, VideoPlayerController> getNetworkVideoSources(
    Map<String, String> sources) {
  Map<String, VideoPlayerController> videoSources = Map();
  for (String key in sources.keys)
    videoSources[key] = VideoSource.network(sources[key]);
  return videoSources;
}
