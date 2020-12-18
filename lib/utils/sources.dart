import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';

export 'package:video_player/video_player.dart';

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
///    "720p": VideoPlayerController.network("https://github.com/intel-iot-devkit/sample-videos/blob/master/classroom.mp4"),
///    "1080p": VideoPlayerController.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"),
///}
/// ```
Map<String, VideoPlayerController> getNetworkVideoSources(
    Map<String, String> sources) {
  Map<String, VideoPlayerController> videoSource = Map();
  for (String key in sources.keys)
    videoSource[key] = VideoPlayerController.network(sources[key]);
  return videoSource;
}

/// It is a function that returns a map (`quality: fileData`), the input
/// data must be of type URL.
///
///EXAMPLE:
///```dart
///Future<Map<String, VideoPlayerController>> createFiles(String url) async {
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
Future<Map<String, String>> getm3u8VideoFileData(String m3u8) async {
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

  Map<String, String> sources = Map();
  List<String> audioList = List();
  String content;

  final http.Response response = await http.get(m3u8);
  if (response.statusCode == 200) content = utf8.decode(response.bodyBytes);

  List<RegExpMatch> matches = regExp.allMatches(content).toList();
  List<RegExpMatch> audioMatches = regExpAudio.allMatches(content).toList();

  matches.forEach((RegExpMatch regExpMatch) {
    final String sourceurl = (regExpMatch.group(3)).toString();
    final String quality = (regExpMatch.group(1)).toString();
    final bool isNetwork = netRegx.hasMatch(sourceurl);
    final RegExpMatch match = netRegx2.firstMatch(m3u8);
    String audio = "";
    String file = "";
    String url = sourceurl;

    if (!isNetwork) {
      final dataurl = match.group(0);
      url = "$dataurl$sourceurl";
    }

    audioMatches.forEach((RegExpMatch regExpMatch2) {
      final String audiourl = (regExpMatch2.group(1)).toString();
      final bool isNetwork = netRegx.hasMatch(audiourl);
      final RegExpMatch match = netRegx2.firstMatch(m3u8);
      String auurl = audiourl;
      if (!isNetwork) {
        final String audataurl = match.group(0);
        auurl = "$audataurl$audiourl";
      }
      audioList.add(auurl);
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
