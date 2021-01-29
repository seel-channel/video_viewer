import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  String secondsFormatter(int seconds);
  VideoMetadata videoMetadata(BuildContext context, {bool listen = true});
  VideoViewerStyle videoStyle(BuildContext context, {bool listen = true});
  VideoViewerController video(BuildContext context, {bool listen = false});
}
