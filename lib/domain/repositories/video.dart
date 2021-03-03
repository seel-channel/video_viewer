import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  String secondsFormatter(int seconds);
  VideoViewerStyle videoStyle(BuildContext context, {bool listen = false});
  VideoViewerController video(BuildContext context, {bool listen = false});
  VideoViewerMetadata videoMetadata(BuildContext context,
      {bool listen = false});
}
