import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/widgets/video_core.dart';

class FullScreenPage extends StatefulWidget {
  FullScreenPage({Key key}) : super(key: key);

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final VideoQuery _query = VideoQuery();
  bool _showVideo = false, fixedLandscape = false;
  Timer _closeOverlay;

  @override
  void initState() {
    _resetSystem();
    Misc.onLayoutRendered(() {
      final metadata = _query.videoMetadata(context);
      // final style = metadata.style;
      // _style =
      //     style.thumbnail != null ? style.copywith(thumbnail: null) : style;
      _closeOverlay = Misc.periodic(3000, _resetSystem);
      _showVideo = true;
      fixedLandscape = metadata.onFullscreenFixLandscape;
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
    changeOrientation();
  }

  void changeOrientation() {
    Misc.setSystemOrientation(
      fixedLandscape
          ? [
              ...SystemOrientation.landscapeLeft,
              ...SystemOrientation.landscapeRight
            ]
          : SystemOrientation.values,
    );
  }

  Future<bool> _returnButton() async {
    await _query.video(context).closeFullScreen(context);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final metadata = _query.videoMetadata(context, listen: true);
    final style = metadata.style;

    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: _returnButton,
        child: Center(
          child: BooleanTween(
            tween: Tween<double>(begin: 0, end: 1.0),
            curve: Curves.ease,
            animate: _showVideo,
            duration: Duration(milliseconds: style.transitions),
            builder: (value) {
              return Opacity(
                opacity: value,
                child: VideoViewerCore(),
              );
            },
          ),
        ),
      ),
    );
  }
}
