import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

export 'package:video_player/video_player.dart';

class VideoSource {
  VideoSource({
    @required this.video,
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
  final Map<String, VideoViewerSubtitle> subtitle;

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
  static Map<String, VideoSource> getNetworkVideoSources(
      Map<String, String> sources) {
    Map<String, VideoSource> videoSource = {};
    for (String key in sources.keys)
      videoSource[key] = VideoSource(
        video: VideoPlayerController.network(sources[key]),
      );
    return videoSource;
  }

  /// It is a function that returns a map (`quality: fileData`), the input
  /// data must be of type URL.
  ///
  ///EXAMPLE:
  ///```dart
  ///Future<Map<String, VideoPlayerController>> videoFrom3u8() async {
  ///   final String url = "https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8";
  ///   final Directory directory = await getApplicationDocumentsDirectory();
  ///   final Map<String, String> files = await getm3u8VideoFileData(url);
  ///   Map<String, VideoPlayerController> sources = {
  ///      "Auto": VideoPlayerController.network(url)
  ///   };
  ///
  ///   for (String quality in files.keys) {
  ///      final File file = File('${directory.path}/hls$quality.m3u8');
  ///      await file.writeAsString(files[quality]);
  ///      sources["${quality.split("x").last}p"] = VideoPlayerController.file(file);
  ///   }
  ///
  ///   return sources;
  ///}
  /// ```
  static Future<Map<String, String>> getm3u8VideoFileData(String m3u8) async {
    final RegExp netRegx = RegExp(r'^(http|https):\/\/([\w.]+\/?)\S*');
    final RegExp netRegx2 = RegExp(r'(.*)\r?\/');
    final RegExp regExpAudio = RegExp(
      r"""^#EXT-X-MEDIA:TYPE=AUDIO(?:.*,URI="(.*m3u8)")""",
      caseSensitive: false,
      multiLine: true,
    );
    final RegExp regExp = RegExp(
      r"#EXT-X-STREAM-INF:(?:.*,RESOLUTION=(\d+x\d+))?,?(.*)\r?\n(.*)",
      caseSensitive: false,
      multiLine: true,
    );

    Map<String, String> sources = {};
    List<String> audioList = [];
    String content;

    final response = await Dio().get<String>(m3u8);
    if (response.statusCode == 200) content = response.data;

    List<RegExpMatch> matches = regExp.allMatches(content).toList();
    List<RegExpMatch> audioMatches = regExpAudio.allMatches(content).toList();

    matches.forEach((RegExpMatch regExpMatch) {
      final RegExpMatch match = netRegx2.firstMatch(m3u8);
      final String sourceURL = (regExpMatch.group(3)).toString();
      final String quality = (regExpMatch.group(1)).toString();
      final bool isNetwork = netRegx.hasMatch(sourceURL);
      String url = sourceURL;

      if (!isNetwork) {
        final String dataURL = match.group(0);
        url = "$dataURL$sourceURL";
      }

      audioMatches.forEach((RegExpMatch regExpMatch2) {
        final RegExpMatch match = netRegx2.firstMatch(m3u8);
        final String audioURL = (regExpMatch2.group(1)).toString();
        final bool isNetwork = netRegx.hasMatch(audioURL);
        String audio = audioURL;

        if (!isNetwork) {
          final String audioDataURL = match.group(0);
          audio = "$audioDataURL$audioURL";
        }
        audioList.add(audio);
      });

      String audio = "";
      String file = "";
      if (audioList.length != 0) {
        audio =
            """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",URI="${audioList.last}"\n""";
      }

      file =
          """#EXTM3U\n#EXT-X-INDEPENDENT-SEGMENTS\n$audio#EXT-X-STREAM-INF:CLOSED-CAPTIONS=NONE,BANDWIDTH=1469712,RESOLUTION=$quality,FRAME-RATE=30.000\n$url""";

      sources[quality] = file;
    });

    return sources;
  }
}
