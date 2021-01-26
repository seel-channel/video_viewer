import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/repositories/provider.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

class ProviderQuery extends ProviderQueryRepository {
  VideoMetadata getVideoMetadata(BuildContext context) {
    return Provider.of<VideoMetadata>(context);
  }

  VideoViewerStyle getVideoStyle(BuildContext context) {
    return Provider.of<VideoMetadata>(context).style;
  }

  VideoControllerNotifier getVideo(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<VideoControllerNotifier>(context, listen: listen);
  }

  VideoPlayerController updateVideoController(BuildContext context) {
    return Provider.of<VideoControllerNotifier>(context, listen: false)
        .controller;
  }

  VideoPlayerController getVideoController(BuildContext context) {
    return Provider.of<VideoControllerNotifier>(context).controller;
  }

  bool getVideoFullScreen(BuildContext context) {
    return Provider.of<VideoControllerNotifier>(context).isFullScreen;
  }

  void setVideoFullScreen(BuildContext context, bool value) {
    Provider.of<VideoControllerNotifier>(context, listen: false).isFullScreen =
        value;
  }

  bool getVideoBuffering(BuildContext context) {
    return Provider.of<VideoControllerNotifier>(context).isBuffering;
  }

  void setVideoBuffering(BuildContext context, bool value) {
    Provider.of<VideoControllerNotifier>(context, listen: false).isBuffering =
        value;
  }
}
