import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';
import 'package:video_viewer/widgets/video.dart';

String secondsFormatter(int seconds) {
  int secondsBool = seconds;
  int minutes = (seconds.abs() / 60).floor();
  seconds = (seconds.abs() - (minutes * 60));
  int hours = (minutes.abs() / 60).floor();
  String minutesStr = minutes < 10 ? "0$minutes" : "$minutes";
  String secondsStr = seconds < 10 ? "0$seconds" : "$seconds";
  String hoursStr = hours == 0
      ? ""
      : hours < 10
          ? "0$hours:"
          : "$hours:";
  return secondsBool < 0
      ? "-$hoursStr$minutesStr:$secondsStr"
      : "$hoursStr$minutesStr:$secondsStr";
}

VideoViewerStyle mergeVideoViewerStyle({
  VideoViewerStyle style,
  TextStyle textStyle,
}) {
  return VideoViewerStyle(
    thumbnail: null,
    loading: style.loading,
    buffering: style.buffering,
    textStyle:
        textStyle != null ? style.textStyle.merge(textStyle) : style.textStyle,
    settingsStyle: style.settingsStyle,
    volumeBarStyle: style.volumeBarStyle,
    progressBarStyle: style.progressBarStyle,
    playAndPauseStyle: style.playAndPauseStyle,
    forwardAndRewindStyle: style.forwardAndRewindStyle,
  );
}

class SettingsMenu extends StatefulWidget {
  SettingsMenu({
    Key key,
    this.style,
    this.source,
    this.visible,
    this.controller,
    this.changeState,
    this.changeSource,
    this.activedSource,
  }) : super(key: key);

  final bool visible;
  final String activedSource;
  final VideoViewerStyle style;
  final void Function() changeState;
  final VideoPlayerController controller;
  final Map<String, VideoPlayerController> source;
  final void Function(VideoPlayerController, String) changeSource;

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  List<bool> show = [false, false];
  bool showMenu = true;
  TextStyle textStyle;
  SettingsMenuStyle style;

  @override
  void initState() {
    style = widget.style.settingsStyle;
    textStyle = widget.style.textStyle;
    super.initState();
  }

  void closeAllAndShowMenu() {
    setState(() {
      showMenu = true;
      show.fillRange(0, show.length, false);
    });
  }

  //RESPONSIVE TEXT
  @override
  void didUpdateWidget(SettingsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style.textStyle != textStyle)
      setState(() {
        textStyle = widget.style.textStyle;
      });
  }

  @override
  Widget build(BuildContext context) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: widget.style.transitions),
      visible: widget.visible,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.changeState,
              child: Container(color: Colors.black.withOpacity(0.32)),
            ),
            _fadeTransition(
              visible: !showMenu,
              child: GestureDetector(
                onTap: closeAllAndShowMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
            _fadeTransition(
              visible: showMenu,
              child: iconsMainMenu(),
            ),
            _fadeTransition(
              visible: show[0],
              child: settingsQualityMenu(),
            ),
            _fadeTransition(
              visible: show[1],
              child: settingsSpeedMenu(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fadeTransition({bool visible, Widget child}) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: (widget.style.transitions / 2).round()),
      visible: visible,
      child: child,
    );
  }

  //---------//
  //MAIN MENU//
  //---------//
  Widget iconsMainMenu() {
    double speed = widget.controller.value.playbackSpeed;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                showMenu = false;
                show[0] = true;
              });
            },
            child: settingsItemMenu(
              "Quality",
              widget.activedSource,
              style.settings,
            ),
          ),
          SizedBox(width: style.paddingBetween),
          GestureDetector(
            onTap: () {
              setState(() {
                showMenu = false;
                show[1] = true;
              });
            },
            child: settingsItemMenu(
              "Speed",
              speed == 1.0 ? "Normal" : "x$speed",
              style.speed,
            ),
          ),
        ],
      ),
    );
  }

  Widget settingsItemMenu(String title, String subtitle, Widget icon) {
    return Container(
      color: Colors.transparent,
      padding: Margin.all(style.paddingBetween / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: textStyle),
          Text(
            subtitle,
            style: textStyle.merge(TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: textStyle.fontSize -
                    widget.style.inLandscapeEnlargeTheTextBy)),
          ),
        ],
      ),
    );
  }

  //---------------//
  //SECONDARY MENUS//
  //---------------//
  Widget settingsQualityMenu() {
    return _secondaryMenuContainer([
      for (MapEntry<String, dynamic> entry in widget.source.entries)
        _inkWellDesigned(
          onTap: () {
            if (entry.key != widget.activedSource)
              widget.changeSource(entry.value, entry.key);
            closeAllAndShowMenu();
          },
          child: _textDesigned(entry.key, entry.key == widget.activedSource),
        ),
    ]);
  }

  Widget settingsSpeedMenu() {
    return _secondaryMenuContainer([
      for (double i = 0.5; i <= 2; i += 0.25)
        _inkWellDesigned(
          onTap: () {
            widget.controller.setPlaybackSpeed(i);
            closeAllAndShowMenu();
          },
          child: _textDesigned(
            i == 1.0 ? "Normal" : "x$i",
            i == widget.controller.value.playbackSpeed,
          ),
        ),
    ]);
  }

  Widget _secondaryMenuContainer(List<Widget> children) {
    return Center(
      child: Container(
        width: 150,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: closeAllAndShowMenu,
              child: Row(children: [
                style.chevron,
                Expanded(child: Text("Settings", style: textStyle)),
              ]),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _inkWellDesigned({Widget child, void Function() onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white.withOpacity(0.2),
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget _textDesigned(String text, bool selected) {
    return Padding(
      padding: Margin.horizontal(8),
      child: Row(children: [
        Expanded(
          child: Text(text,
              style: textStyle.merge(TextStyle(fontWeight: FontWeight.normal))),
        ),
        if (selected) style.selected,
      ]),
    );
  }
}

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
