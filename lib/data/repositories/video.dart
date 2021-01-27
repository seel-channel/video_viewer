import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/domain/repositories/video.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

class VideoQuery extends VideoQueryRepository {
  VideoMetadata videoMetadata(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<VideoMetadata>(context, listen: listen);
  }

  VideoControllerNotifier video(
    BuildContext context, {
    bool listen = false,
  }) {
    return Provider.of<VideoControllerNotifier>(context, listen: listen);
  }
}
