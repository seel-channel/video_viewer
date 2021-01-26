import 'dart:async';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/data/repositories/provider.dart';
import 'package:video_viewer/domain/entities/language.dart';
import 'package:video_viewer/widgets/video_core.dart';

class FullScreenPage extends StatefulWidget {
  FullScreenPage({
    Key key,
    this.controller,
    this.source,
    this.activedSource,
    this.looping,
    this.rewindAmount,
    this.forwardAmount,
    this.defaultAspectRatio,
    this.fixedLandscape = true,
    this.language,
    this.settingsMenuItems,
  }) : super(key: key);

  final String activedSource;
  final bool looping;
  final bool fixedLandscape;
  final double defaultAspectRatio;
  final int rewindAmount, forwardAmount;
  final VideoViewerLanguage language;
  final Map<String, VideoSource> source;
  final VideoPlayerController controller;

  final List<SettingsMenuItem> settingsMenuItems;

  @override
  _FullScreenPageState createState() => _FullScreenPageState();
}

class _FullScreenPageState extends State<FullScreenPage> {
  final GlobalKey<VideoViewerCoreState> key = GlobalKey<VideoViewerCoreState>();
  VideoViewerStyle _style;
  bool _showVideo = false;
  Timer _closeOverlay;

  @override
  void initState() {
    changeOrientation();
    Misc.setSystemOverlay([]);
    Misc.onLayoutRendered(() {
      setState(() {
        final style = ProviderQuery().getVideoStyle(context);
        _style =
            style.thumbnail != null ? style.copywith(thumbnail: null) : style;
      });
      fullScreenOrientation();
    });
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
                child: VideoViewerCore(
                  key: key,
                  style: _style,
                  source: widget.source,
                  looping: widget.looping,
                  language: widget.language,
                  controller: widget.controller,
                  activedSource: widget.activedSource,
                  rewindAmount: widget.rewindAmount,
                  forwardAmount: widget.forwardAmount,
                  settingsMenuItems: widget.settingsMenuItems,
                  defaultAspectRatio: widget.defaultAspectRatio,
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
