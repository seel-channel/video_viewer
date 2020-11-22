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
  SettingsStyle style;

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

  @override
  Widget build(BuildContext context) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: 400),
      visible: widget.visible,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
        child: Stack(
          children: [
            GestureDetector(
              onTap: widget.changeState,
              child: Container(color: Colors.black.withOpacity(0.32)),
            ),
            OpacityTransition(
              visible: !showMenu,
              child: GestureDetector(
                onTap: closeAllAndShowMenu,
                child: Container(color: Colors.transparent),
              ),
            ),
            OpacityTransition(
              visible: showMenu,
              child: iconsMainMenu(),
            ),
            OpacityTransition(
              visible: show[0],
              child: settingsQualityMenu(),
            ),
            OpacityTransition(
              visible: show[1],
              child: settingsSpeedMenu(),
            ),
          ],
        ),
      ),
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
      padding: Margin.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: textStyle),
          Text(subtitle,
              style: textStyle.merge(
                  TextStyle(fontWeight: FontWeight.normal, fontSize: 10))),
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
  GlobalKey<VideoReadyState> key = GlobalKey<VideoReadyState>();
  bool isFullScreen = false;

  @override
  void initState() {
    Misc.onLayoutRendered(() {
      key.currentState.fullScreen = true;
      fullScreenOrientation();
    });
    super.initState();
  }

  Future<bool> _returnButton() async {
    await Misc.setSystemOverlay(SystemOverlay.values);
    return true;
  }

  void fullScreenOrientation() async {
    await Misc.setSystemOverlay([]);
    await Misc.setSystemOrientation(SystemOrientation.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: _returnButton,
        child: Center(
          child: Hero(
            tag: "VideoReady",
            child: VideoReady(
              key: key,
              style: widget.style,
              source: widget.source,
              looping: widget.looping,
              controller: widget.controller,
              activedSource: widget.activedSource,
              rewindAmount: widget.rewindAmount,
              forwardAmount: widget.forwardAmount,
              defaultAspectRatio: widget.defaultAspectRatio,
              onChangeSource: (controller, activedSource) =>
                  widget.changeSource(controller, activedSource),
            ),
          ),
        ),
      ),
    );
  }
}
