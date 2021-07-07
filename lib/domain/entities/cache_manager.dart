import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:helpers/helpers/print.dart';
import 'package:pedantic/pedantic.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer/domain/entities/video_source.dart';

class VideoViewerCacheManager {
  VideoViewerCacheManager({
    Duration stalePeriod = const Duration(days: 7),
    int maxVideoCacheObjects = 24,
  }) {
    final String key = 'customCacheKey';
    _cacheManager = CacheManager(
      Config(
        key,
        stalePeriod: stalePeriod,
        maxNrOfCacheObjects: maxVideoCacheObjects,
        fileService: HttpFileService(),
      ),
    );
  }

  late BaseCacheManager _cacheManager;

  Future<VideoPlayerController> getControllerForVideo(
    VideoPlayerController video,
  ) async {
    if (video.dataSourceType == DataSourceType.network) {
      final String url = video.dataSource;
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo == null) {
        printYellow('[VideoViewerCacheManager]: No video in cache');
        printYellow('[VideoViewerCacheManager]: Saving video to cache');
        unawaited(
            _cacheManager.downloadFile(url, authHeaders: video.httpHeaders));
        return VideoPlayerController.network(url);
      } else {
        printYellow('[VideoViewerCacheManager]: Loading video from cache');
        return VideoPlayerController.file(fileInfo.file);
      }
    } else {
      return video;
    }
  }
}
