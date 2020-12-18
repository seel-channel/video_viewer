import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

export 'package:video_player/video_player.dart';

/// It is a function that returns a map from VideoSource.network, the input
/// data must be of type URL.
///
///INPUT:
///```dart
///getNetworkVideoSources({
///    "720p": "https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4",
///    "1080p": "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
///})
/// ```
///
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
    videoSources[key] = VideoPlayerController.network(sources[key]);
  return videoSources;
}

/// It is a function that returns a map from VideoSource.network, the input
/// data must be of type URL.
///
///INPUT:
///```dart
///  getHLSVideoSources("https://sfux-ext.sfux.info/hls/chapter/105/1588724110/1588724110.m3u8")
/// ```
Future<Map<String, String>> getHLSVideoSources(
  String m3u8,
) async {
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

  Map<String, String> sources = Map();
  List<String> audioList = List();
  String m3u8Content;

  http.Response response = await http.get(m3u8);
  if (response.statusCode == 200) m3u8Content = utf8.decode(response.bodyBytes);

  List<RegExpMatch> matches = regExp.allMatches(m3u8Content).toList();
  List<RegExpMatch> audioMatches = regExpAudio.allMatches(m3u8Content).toList();

  matches.forEach((RegExpMatch regExpMatch) async {
    final String url = (regExpMatch.group(3)).toString();
    final String quality = (regExpMatch.group(1)).toString();
    String audio = "";
    String file = "";

    audioMatches.forEach((RegExpMatch regExpMatch2) async {
      String audiourl = (regExpMatch2.group(1)).toString();
      audioList.add(audiourl);
    });

    if (audioList.length != 0)
      audio =
          """#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="audio-medium",NAME="audio",AUTOSELECT=YES,DEFAULT=YES,CHANNELS="2",URI="${audioList.last}"\n""";
    file =
        """#EXTM3U\n#EXT-X-INDEPENDENT-SEGMENTS\n$audio#EXT-X-STREAM-INF:CLOSED-CAPTIONS=NONE,BANDWIDTH=1469712,RESOLUTION=$quality,FRAME-RATE=30.000\n$url""";

    sources[quality] = file;
  });

  return sources;
}
