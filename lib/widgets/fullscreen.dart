import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/widgets/video.dart';
import 'package:video_viewer/utils/misc.dart';
import 'package:video_viewer/utils/styles.dart';

class FullScreenPage extends StatefulWidget {
  FullScreenPage({
    Key key,
    this.controller,
    this.style,
    this.source,
    this.activedSource,
    this.looping,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.changeSource,
  }) : super(key: key);

  final String activedSource;
  final bool looping;
  final VideoViewerStyle style;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoPlayerController controller;
  final Map<String, VideoPlayerController> source;
  final void Function(VideoPlayerController, String) changeSource;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  VideoViewerStyle style;
  GlobalKey<VideoReadyState> key = GlobalKey<VideoReadyState>();
  bool isFullScreen = false;
  bool showVideo = false;

  @override
  void initState() {
    style = widget.style.thumbnail != null
        ? mergeVideoViewerStyle(style: widget.style)
        : widget.style;
    Misc.onLayoutRendered(() => fullScreenOrientation());
    super.initState();
  }

  Future<bool> _returnButton() async {
    await resetOrientationValues();
    return true;
  }

  Future<void> resetOrientationValues() async {
    setState(() => showVideo = false);
    await Misc.wait(style.transitions);
    await Misc.setSystemOverlay(SystemOverlay.values);
  }

  void fullScreenOrientation() async {
    await Misc.setSystemOverlay([]);
    await Misc.setSystemOrientation(SystemOrientation.values);
    key.currentState.fullScreen = true;
    setState(() => showVideo = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: _returnButton,
        child: Center(
          child: BooleanTween(
            tween: Tween<double>(begin: 0, end: 1.0),
            curve: Curves.ease,
            animate: showVideo,
            duration: Duration(milliseconds: style.transitions),
            builder: (value) {
              return Opacity(
                opacity: value,
                child: VideoReady(
                  key: key,
                  style: style,
                  source: widget.source,
                  looping: widget.looping,
                  controller: widget.controller,
                  activedSource: widget.activedSource,
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  defaultAspectRatio: widget.defaultAspectRatio,
                  onChangeSource: (controller, activedSource) =>
                      widget.changeSource(controller, activedSource),
                  exitFullScreen: () async {
                    await resetOrientationValues();
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
