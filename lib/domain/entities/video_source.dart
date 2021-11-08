import 'dart:convert';
import 'dart:io';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:video_player/video_player.dart';

class VideoSource {
  VideoSource({
    required this.video,
    this.ads,
    this.subtitle,
    this.intialSubtitle = "",
    this.range,
  });

  ///It's the ads list it's going to show
  final List<VideoViewerAd>? ads;

  ///It's the range of the video where it's going to play. For example, you want to play the video from `Duration.zero` to `Duration(minutes: 2)`
  final Tween<Duration>? range;

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

  ///It's a function that returns a map from VideoPlayerController.network, the input
  ///data must be of type URL.
  ///
  ///If **[subtitle]** is no-null, set for all URLs the same subtitles.
  ///
  ///INPUT:
  ///```dart
  ///VideoSource.fromNetworkVideoSources({
  ///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
  ///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
  ///})
  /// ```
  ///
  ///
  ///OUTPUT:
  ///```dart
  ///{
  ///    "720p": VideoSource(
  ///       video: VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4"),
  ///       intialSubtitle: initialSubtitle
  ///       subtitle: subtitle,
  ///    ),
  ///    "1080p": VideoSource(
  ///       video: VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
  ///       intialSubtitle: initialSubtitle
  ///       subtitle: subtitle,
  ///    ),
  ///}
  /// ```
  static Map<String, VideoSource> fromNetworkVideoSources(
    Map<String, String> sources, {
    String initialSubtitle = "",
    Map<String, VideoViewerSubtitle>? subtitle,
    List<VideoViewerAd>? ads,
    Tween<Duration>? range,
  }) {
    Map<String, VideoSource> videoSource = {};
    for (String key in sources.keys)
      videoSource[key] = VideoSource(
        video: VideoPlayerController.network(sources[key]!),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
      );
    return videoSource;
  }

  ///It's a function that returns a map from VideoPlayerController.network, the input
  ///data must be of type URL.
  ///
  ///EXAMPLE:
  ///```dart
  ///VideoSource.fromM3u8VideoUrl(
  ///   "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8",
  ///   formatter: (quality) => quality == "Auto" ? "Automatic" : "${quality.split("x").last}p",
  ///)
  /// ```
  static Future<Map<String, VideoSource>> fromM3u8PlaylistUrl(
    String m3u8, {
    String initialSubtitle = "",
    Map<String, VideoViewerSubtitle>? subtitle,
    List<VideoViewerAd>? ads,
    Tween<Duration>? range,
    String Function(String quality)? formatter,
    bool descending = true,
  }) async {
    //REGULAR EXPRESIONS//
    final RegExp netRegxUrl = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
    final RegExp netRegx2 = RegExp(r'(.*)\r?\/');
    final RegExp regExpPlaylist = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );
    final RegExp regExpAudio = RegExp(
      r"""^#EXT-X-MEDIA:TYPE=AUDIO(?:.*,URI="(.*m3u8)")""",
      caseSensitive: false,
      multiLine: true,
    );

    //GET m3u8 file
    late String content = "";
    final http.Response response = await http.get(Uri.parse(m3u8));
    if (response.statusCode == 200) content = utf8.decode(response.bodyBytes);
    final String? directoryPath;
    if (kIsWeb) {
      directoryPath = null;
    } else {
      directoryPath = (await getTemporaryDirectory()).path;
    }

    //Find matches
    List<RegExpMatch> playlistMatches =
        regExpPlaylist.allMatches(content).toList();
    List<RegExpMatch> audioMatches = regExpAudio.allMatches(content).toList();

    Map<String, dynamic> sources = {};
    Map<String, String> sourceUrls = {};
    final List<String> audioUrls = [];

    for (final RegExpMatch playlistMatch in playlistMatches) {
      final RegExpMatch? playlist = netRegx2.firstMatch(m3u8);
      final String sourceURL = (playlistMatch.group(3)).toString();
      final String quality = (playlistMatch.group(1)).toString();
      final bool isNetwork = netRegxUrl.hasMatch(sourceURL);
      String playlistUrl = sourceURL;

      if (!isNetwork) {
        final String? dataURL = playlist!.group(0);
        playlistUrl = "$dataURL$sourceURL";
      }

      //Find audio url
      for (final RegExpMatch audioMatch in audioMatches) {
        final String audio = (audioMatch.group(1)).toString();
        final bool isNetwork = netRegxUrl.hasMatch(audio);
        final RegExpMatch? match = netRegx2.firstMatch(playlistUrl);
        String audioUrl = audio;

        if (!isNetwork && match != null) {
          audioUrl = "${match.group(0)}$audio";
        }
        audioUrls.add(audioUrl);
      }

      final String audioMetadata;
      if (audioUrls.length > 0) {
        audioMetadata =
            """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",URI="${audioUrls.last}"\n""";
      } else {
        audioMetadata = "";
      }
      if (directoryPath != null) {
        final File file = File('$directoryPath/hls$quality.m3u8');
        file.writeAsStringSync(
          """#EXTM3U\n#EXT-X-INDEPENDENT-SEGMENTS\n$audioMetadata#EXT-X-STREAM-INF:CLOSED-CAPTIONS=NONE,BANDWIDTH=1469712,RESOLUTION=$quality,FRAME-RATE=30.000\n$playlistUrl""",
        );
        sources[quality] = file;
      } else {
        sourceUrls[quality] = playlistUrl;
      }
    }

    Map<String, VideoSource> videoSource = {};
    void addAutoSource() {
      videoSource["Auto"] = VideoSource(
        video: VideoPlayerController.network(m3u8),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
      );
    }

    if (descending) addAutoSource();
    for (final entry in getSource(descending, sources, sourceUrls)) {
      final String key = formatter?.call(entry.key) ?? entry.key;
      videoSource[key] = VideoSource(
        video: directoryPath == null
            ? VideoPlayerController.network(sourceUrls[entry.key]!)
            : VideoPlayerController.file(sources[entry.key]!),
        intialSubtitle: initialSubtitle,
        subtitle: subtitle,
        range: range,
        ads: ads,
      );
    }
    if (!descending) addAutoSource();
    return videoSource;
  }

  static Iterable<MapEntry<String, dynamic>> getSource(bool descending,
      Map<String, dynamic> sources, Map<String, String> sourceUrls) {
    Map<String, dynamic> tmp = sources;
    if (kIsWeb) {
      tmp = sourceUrls;
    }
    return descending ? tmp.entries.toList().reversed : tmp.entries;
  }
}
