import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/video_core/video_core.dart';

class FullScreenPage extends StatefulWidget {
  const FullScreenPage({Key? key}) : super(key: key);

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final VideoQuery _query = VideoQuery();
  bool _fixedLandscape = false;
  Timer? _systemResetTimer;

  @override
  void initState() {
    super.initState();
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      _systemResetTimer = Misc.periodic(3000, _resetSystem);
      _fixedLandscape = metadata.onFullscreenFixLandscape;
      Future.delayed(metadata.style.transitions, _resetSystem);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _systemResetTimer?.cancel();
    _systemResetTimer = null;
    super.dispose();
  }

  void _resetSystem() {
    Misc.setSystemOverlay([]);
    if (_fixedLandscape)
      Misc.setSystemOrientation([
        ...SystemOrientation.landscapeLeft,
        ...SystemOrientation.landscapeRight
      ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          await _query.video(context).openOrCloseFullscreen(context);
          return false;
        },
        child: Center(
          child: VideoViewerCore(),
        ),
      ),
    );
  }
}
