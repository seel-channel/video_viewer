import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  VideoMetadata getVideoMetadata(BuildContext context);

  VideoViewerStyle getVideoStyle(BuildContext context);

  VideoControllerNotifier getVideo(BuildContext context, {bool listen = false});

  VideoPlayerController updateVideoController(BuildContext context);

  VideoPlayerController getVideoController(BuildContext context);

  bool getVideoFullScreen(BuildContext context);

  void setVideoFullScreen(BuildContext context, bool value);

  bool getVideoBuffering(BuildContext context);

  void setVideoBuffering(BuildContext context, bool value);
}
