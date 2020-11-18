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
    this.source,
    this.visible,
    this.controller,
    this.changeState,
    this.changeSource,
    this.activedSource,
  }) : super(key: key);

  final bool visible;
  final String activedSource;
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

  void closeAllAndShowMenu() {
    setState(() {
      showMenu = true;
      show.fillRange(0, show.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return OpacityTransition(
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
              child: settingsIconsMenu(),
            ),
            OpacityTransition(
              visible: show[0],
              child: settingsQuality(),
            ),
            OpacityTransition(
              visible: show[1],
              child: settingsSpeed(),
            ),
          ],
        ),
      ),
    );
  }

  Widget settingsItem(String title, String subtitle, Widget icon) {
    return Container(
      color: Colors.transparent,
      padding: Margin.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: TextStyle(color: Colors.white)),
          Text(subtitle, style: TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }

  Widget settingsIconsMenu() {
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
            child: settingsItem(
              "Quality",
              widget.activedSource,
              Icon(Icons.settings, color: Colors.white),
            ),
          ),
          SizedBox(width: 40),
          GestureDetector(
            onTap: () {
              setState(() {
                showMenu = false;
                show[1] = true;
              });
            },
            child: settingsItem(
              "Speed",
              speed == 1.0 ? "Normal" : "x$speed",
              Icon(Icons.speed, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget changeSettingsContainer(List<Widget> children) {
    return Center(
      child: Container(
        width: 150,
        color: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: closeAllAndShowMenu,
              child: Row(children: [
                Icon(Icons.chevron_left, color: Colors.white),
                Text("Settings", style: TextStyle(color: Colors.white)),
              ]),
            ),
            SizedBox(height: 5),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _textSettings(String text, bool selected) {
    return Padding(
      padding: Margin.horizontal(8),
      child: Row(children: [
        Expanded(child: Text(text, style: TextStyle(color: Colors.white))),
        if (selected) Icon(Icons.done, color: Colors.white, size: 20),
      ]),
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

  Widget settingsQuality() {
    return changeSettingsContainer([
      for (MapEntry entry in widget.source.entries)
        _inkWellDesigned(
          onTap: () {
            widget.changeSource(entry.value, entry.key);
            closeAllAndShowMenu();
            showMenu = false;
          },
          child: _textSettings(entry.key, entry.key == widget.activedSource),
        ),
    ]);
  }

  Widget settingsSpeed() {
    return changeSettingsContainer([
      for (double i = 0.5; i <= 2; i += 0.25)
        _inkWellDesigned(
          onTap: () {
            widget.controller.setPlaybackSpeed(i);
            closeAllAndShowMenu();
          },
          child: _textSettings(
            i == 1.0 ? "Normal" : "x$i",
            i == widget.controller.value.playbackSpeed,
          ),
        ),
    ]);
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
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        // if (orientation == Orientation.landscape && !isFullScreen) {
        //   isFullScreen = true;
        //   Misc.setSystemOverlay([]);
        //   Misc.delayed(100, () => Misc.setSystemOverlay([]));
        //   Misc.delayed(200, () => Misc.setSystemOverlay([]));
        // } else if (orientation == Orientation.portrait && isFullScreen) {
        //   isFullScreen = false;
        //   Misc.setSystemOverlay([]);
        //   Misc.delayed(200, () => Misc.setSystemOverlay([]));
        //   Misc.delayed(400, () => Misc.setSystemOverlay([]));
        // }

        return Scaffold(
          backgroundColor: Colors.black,
          body: WillPopScope(
            onWillPop: _returnButton,
            child: Center(
              child: Hero(
                tag: 'VideoReady',
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
      },
    );
  }
}
