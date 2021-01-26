import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

export 'package:video_player/video_player.dart';

class VideoSource {
  final VideoPlayerController video;
  final VideoViewerSubtitle subtitle;

  VideoSource({this.video, this.subtitle});
}
