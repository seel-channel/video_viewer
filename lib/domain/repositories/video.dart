import 'package:flutter/material.dart';
import 'package:video_viewer/domain/bloc/controller.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';

abstract class VideoQueryRepository {
  VideoMetadata videoMetadata(BuildContext context, {bool listen = false});
  VideoControllerNotifier video(BuildContext context, {bool listen = false});
}
