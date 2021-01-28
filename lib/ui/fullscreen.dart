import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/video_core/video_core.dart';

class FullScreenPage extends StatefulWidget {
  FullScreenPage({Key key}) : super(key: key);

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final VideoQuery _query = VideoQuery();
  bool _fixedLandscape = false;
  Timer _closeOverlay;

  @override
  void initState() {
    _resetSystem();
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      _closeOverlay = Misc.periodic(3000, _resetSystem);
      _fixedLandscape = metadata.onFullscreenFixLandscape;
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _closeOverlay?.cancel();
    _closeOverlay = null;
    super.dispose();
  }

  void _resetSystem() {
    Misc.setSystemOverlay([]);
    Misc.setSystemOrientation(
      _fixedLandscape
          ? [
              ...SystemOrientation.landscapeLeft,
              ...SystemOrientation.landscapeRight
            ]
          : SystemOrientation.values,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          await _query.video(context).closeFullScreen(context);
          return false;
        },
        child: Center(child: VideoViewerCore()),
      ),
    );
  }
}
