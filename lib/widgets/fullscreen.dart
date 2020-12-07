import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/widgets/video.dart';
import 'package:video_viewer/utils/styles.dart';
import 'package:video_viewer/utils/misc.dart';

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
    this.fixedLandscape = true,
  }) : super(key: key);

  final String activedSource;
  final bool looping;
  final bool fixedLandscape;
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
  final GlobalKey<VideoReadyState> key = GlobalKey<VideoReadyState>();
  VideoViewerStyle _style;
  bool _showVideo = false;
  Timer _closeOverlay;

  @override
  void initState() {
    _style = widget.style.thumbnail != null
        ? mergeVideoViewerStyle(style: widget.style)
        : widget.style;
    changeOrientation();
    Misc.onLayoutRendered(() => fullScreenOrientation());
    super.initState();
  }

  void fullScreenOrientation() {
    _closeOverlay = Misc.periodic(3000, () => Misc.setSystemOverlay([]));
    key.currentState.fullScreen = true;
    setState(() => _showVideo = true);
  }

  void changeOrientation() {
    Misc.setSystemOrientation(
      widget.fixedLandscape
          ? [
              ...SystemOrientation.landscapeLeft,
              ...SystemOrientation.landscapeRight
            ]
          : SystemOrientation.values,
    );
  }

  Future<bool> _returnButton() async {
    await resetOrientationValues();
    return true;
  }

  void _exitFullscreen() async {
    await resetOrientationValues();
    Navigator.of(context).pop();
  }

  Future<void> resetOrientationValues() async {
    _closeOverlay?.cancel();
    setState(() => _showVideo = false);
    await Misc.wait(_style.transitions);
    await Misc.setSystemOrientation(SystemOrientation.portraitUp);
    await Misc.setSystemOverlay(SystemOverlay.values);
    Misc.delayed(3200, () {
      Misc.setSystemOrientation(SystemOrientation.values);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fixedLandscape) changeOrientation();
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: _returnButton,
        child: Center(
          child: BooleanTween(
            tween: Tween<double>(begin: 0, end: 1.0),
            curve: Curves.ease,
            animate: _showVideo,
            duration: Duration(milliseconds: _style.transitions),
            builder: (value) {
              return Opacity(
                opacity: value,
                child: VideoReady(
                  key: key,
                  style: _style,
                  source: widget.source,
                  looping: widget.looping,
                  controller: widget.controller,
                  activedSource: widget.activedSource,
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  defaultAspectRatio: widget.defaultAspectRatio,
                  onChangeSource: (controller, activedSource) =>
                      widget.changeSource(controller, activedSource),
                  exitFullScreen: _exitFullscreen,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
