import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/video.dart';

class VideoViewer extends StatefulWidget {
  VideoViewer({
    Key key,
    this.source,
    VideoViewerStyle style,
    this.looping = false,
    this.autoPlay = false,
    this.rewindAmount = 10,
    this.forwardAmount = 10,
    this.defaultAspectRatio = 16 / 9,
  })  : this.style = style ?? VideoViewerStyle(),
        super(key: key);

  final bool autoPlay, looping;
  final VideoViewerStyle style;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final Map<String, VideoPlayerController> source;

  @override
  _VideoViewerState createState() => _VideoViewerState();
}

class _VideoViewerState extends State<VideoViewer> {
  GlobalKey<VideoReadyState> key = GlobalKey<VideoReadyState>();
  VideoPlayerController _controller;
  String _activedSource;

  @override
  void initState() {
    _activedSource = widget.source.keys.toList()[0];
    _controller = widget.source.values.toList()[0]
      ..initialize().then((_) {
        if (widget.autoPlay) _controller.play();
        _controller.setLooping(widget.looping);
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void disposeController() async {
    await _controller?.pause();
    await _controller.dispose();
    _controller = null;
  }

  @override
  Widget build(BuildContext context) {
    Widget returnWidget = _controller.value.initialized
        ? VideoReady(
            key: key,
            style: widget.style,
            source: widget.source,
            looping: widget.looping,
            controller: _controller,
            activedSource: _activedSource,
            rewindAmount: widget.rewindAmount,
            forwardAmount: widget.forwardAmount,
            defaultAspectRatio: widget.defaultAspectRatio,
          )
        : AspectRatio(
            aspectRatio: widget.defaultAspectRatio,
            child: widget.style.loading);
    return returnWidget;
  }
}
