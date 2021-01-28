import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:video_viewer/domain/repositories/video.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';
import 'package:video_viewer/video_viewer.dart';

class VideoQuery extends VideoQueryRepository {
  @override
  VideoMetadata videoMetadata(BuildContext context, {bool listen = true}) {
    return Provider.of<VideoMetadata>(context, listen: listen);
  }

  @override
  VideoControllerNotifier video(BuildContext context, {bool listen = false}) {
    return Provider.of<VideoControllerNotifier>(context, listen: listen);
  }

  @override
  VideoViewerStyle videoStyle(BuildContext context, {bool listen = true}) {
    return Provider.of<VideoMetadata>(context, listen: listen).style;
  }
}
