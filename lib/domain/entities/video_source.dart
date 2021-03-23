import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

export 'package:video_player/video_player.dart';

class VideoSize {
  VideoSize(this.width, this.height);
  final int width, height;
}

class VideoSource {
  VideoSource({
    required this.video,
    this.subtitle,
    this.intialSubtitle = "",
  });

  ///VideoPlayerController is from [video_player package.](https://pub.dev/packages/video_player)
  ///```dart
  ///VideoPlayerController.network("https://www.speechpad.com/proxy/get/marketing/samples/standard-captions-example.mp4"),
  ///```
  final VideoPlayerController video;

  ///```dart
  /////MULTI-SUBTITLES SUPPORT
  ///  {
  ///    "English": VideoViewerSubtitle.network(
  ///      "https://pastebin.com/raw/h9cP6N5N",
  ///      type: SubtitleType.webvtt,
  ///    ),
  ///    "Spanish": VideoViewerSubtitle.network(
  ///      "https://pastebin.com/raw/wrz69aay",
  ///      type: SubtitleType.webvtt,
  ///    ),
  ///  },
  ///```
  final Map<String, VideoViewerSubtitle>? subtitle;

  ///If [intialSubtitle] doesn't exist in [subtitle], then it won't select any
  ///subtitles and won't display anything until the user selects a subtitle.
  ///
  ///```dart
  /////EXAMPLE
  ///VideoSource(
  ///  intialSubtitle: "Spanish"
  ///  video: VideoPlayerController.network(...),
  ///  subtitle: {
  ///    "English": VideoViewerSubtitle.network(
  ///      "https://pastebin.com/raw/h9cP6N5N",
  ///      type: SubtitleType.webvtt,
  ///    ),
  ///    "Spanish": VideoViewerSubtitle.network(
  ///      "https://pastebin.com/raw/wrz69aay",
  ///      type: SubtitleType.webvtt,
  ///    ),
  ///  },
  ///)
  ///```
  final String intialSubtitle;

  /// It is a function that returns a map from VideoPlayerController.network, the input
  /// data must be of type URL.
  ///
  ///INPUT:
  ///```dart
  ///getNetworkVideoPlayerControllers({
  ///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
  ///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ///})
  /// ```
  ///
  ///OUTPUT:
  ///```dart
  ///{
  ///    "720p": VideoSource(video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4")),
  ///    "1080p": VideoSource(video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4")),
  ///}
  /// ```
  static Map<String, VideoSource> fromNetworkVideoSources(
      Map<String, String> sources) {
    Map<String, VideoSource> videoSource = {};
    for (String key in sources.keys)
      videoSource[key] = VideoSource(
        video: VideoPlayerController.network(sources[key]!),
      );
    return videoSource;
  }

  /// It is a function that returns a map (`quality: fileData`), the input
  /// data must be of type URL.
  ///
  ///EXAMPLE:
  ///```dart
  ///VideoSource.fromM3u8VideoUrl(
  ///   "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8",
  ///   formatter: (size) => "${size.height}p",
  ///)
  /// ```
  static Future<Map<String, VideoSource>> fromM3u8PlaylistUrl(
    String m3u8, {
    String Function(VideoSize video)? formatter,
    bool descending = true,
  }) async {
    final RegExp netRegx = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
    final RegExp netRegx2 = RegExp(r'(.*)\r?\/');
    final RegExp regExp = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );

    Map<String, String> sources = {};
    late String content;

    final response = await http.get(Uri.parse(m3u8));
    if (response.statusCode == 200) content = utf8.decode(response.bodyBytes);

    List<RegExpMatch> matches = regExp.allMatches(content).toList();

    matches.forEach((RegExpMatch regExpMatch) {
      final RegExpMatch? match = netRegx2.firstMatch(m3u8);
      final String sourceURL = (regExpMatch.group(3)).toString();
      final String quality = (regExpMatch.group(1)).toString();
      final bool isNetwork = netRegx.hasMatch(sourceURL);
      String url = sourceURL;

      if (!isNetwork) {
        final String? dataURL = match!.group(0);
        url = "$dataURL$sourceURL";
      }

      sources[quality] = url;
    });

    if (formatter != null) {
      Map<String, String> newSources = {};
      for (var entry in sources.entries) {
        final quality = entry.key.split("x");
        VideoSize size;
        if (quality.length == 2)
          size = VideoSize(
            int.tryParse(quality.elementAt(0)) ?? 0,
            int.tryParse(quality.elementAt(1)) ?? 0,
          );
        else
          size = VideoSize(0, 0);
        newSources[formatter(size)] = entry.value;
      }
      sources = newSources;
    }

    if (descending) {
      Map<String, String> newSources = {};
      for (var entry in sources.entries.toList().reversed)
        newSources[entry.key] = entry.value;
      sources = newSources;
    }

    return VideoSource.fromNetworkVideoSources(sources);
  }
}
