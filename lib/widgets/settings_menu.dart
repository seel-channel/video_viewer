import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/utils/language.dart';
import 'package:video_player/video_player.dart';
import 'package:video_viewer/video_viewer.dart';

class SettingsMenu extends StatefulWidget {
  SettingsMenu({
    Key key,
    this.style,
    this.source,
    this.controller,
    this.changeVisible,
    this.changeSource,
    this.activedSource,
    this.language,
    this.items,
  }) : super(key: key);

  final String activedSource;
  final VideoViewerStyle style;
  final void Function() changeVisible;
  final VideoPlayerController controller;
  final List<SettingsMenuItem> items;
  final Map<String, VideoPlayerController> source;
  final VideoViewerLanguage language;
  final void Function(VideoPlayerController, String) changeSource;

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  SettingsMenuStyle style;
  TextStyle textStyle;

  bool showMenu = true;
  List<bool> show = [false, false];
  List<Widget> mainMenuItems = [];
  List<Widget> secondaryMenus = [];

  @override
  void initState() {
    style = widget.style.settingsStyle;
    textStyle = widget.style.textStyle;
    if (widget.items != null)
      for (int i = 0; i < widget.items.length; i++) {
        show.add(false);
        mainMenuItems.add(_gestureMainMenuItem(
          index: i + 2,
          child: widget.items[i].mainMenu,
        ));
        secondaryMenus.add(
          secondaryMenuContainer(
            [widget.items[i].secondaryMenu],
          ),
        );
      }
    super.initState();
  }

  @override
  void didUpdateWidget(SettingsMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.style.textStyle != textStyle)
      setState(() => textStyle = widget.style.textStyle);
  }

  void closeAllAndShowMenu() {
    setState(() {
      showMenu = true;
      show.fillRange(0, show.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Stack(children: [
        GestureDetector(
          onTap: widget.changeVisible,
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        fadeTransition(
          visible: !showMenu,
          child: GestureDetector(
            onTap: closeAllAndShowMenu,
            child: Container(color: Colors.transparent),
          ),
        ),
        fadeTransition(visible: showMenu, child: mainMenu()),
        fadeTransition(visible: show[1], child: settingsSpeedMenu()),
        fadeTransition(visible: show[0], child: settingsQualityMenu()),
        for (int i = 0; i < secondaryMenus.length; i++)
          fadeTransition(visible: show[i + 2], child: secondaryMenus[i]),
      ]),
    );
  }

  Widget fadeTransition({bool visible, Widget child}) {
    return OpacityTransition(
      curve: Curves.ease,
      duration: Duration(milliseconds: (widget.style.transitions / 2).round()),
      visible: visible,
      child: child,
    );
  }

  Widget _gestureMainMenuItem({int index, child}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showMenu = false;
          show[index] = true;
        });
      },
      child: child,
    );
  }

  //---------//
  //MAIN MENU//
  //---------//
  Widget mainMenu() {
    final double speed = widget.controller.value.playbackSpeed;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _gestureMainMenuItem(
            index: 0,
            child: settingsItemMenu(
              widget.language.quality,
              widget.activedSource,
              style.settings,
            ),
          ),
          SizedBox(width: style.paddingBetween),
          _gestureMainMenuItem(
            index: 1,
            child: settingsItemMenu(
              widget.language.speed,
              speed == 1.0 ? widget.language.normalSpeed : "x$speed",
              style.speed,
            ),
          ),
          for (Widget child in mainMenuItems) ...[
            SizedBox(width: style.paddingBetween),
            child,
          ],
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
    return secondaryMenuContainer([
      for (MapEntry<String, dynamic> entry in widget.source.entries)
        inkWellDesigned(
          onTap: () {
            if (entry.key != widget.activedSource)
              widget.changeSource(entry.value, entry.key);
            closeAllAndShowMenu();
          },
          child: textDesigned(entry.key, entry.key == widget.activedSource),
        ),
    ]);
  }

  Widget settingsSpeedMenu() {
    return secondaryMenuContainer([
      for (double i = 0.5; i <= 2; i += 0.25)
        inkWellDesigned(
          onTap: () {
            widget.controller.setPlaybackSpeed(i);
            closeAllAndShowMenu();
          },
          child: textDesigned(
            i == 1.0 ? widget.language.normalSpeed : "x$i",
            i == widget.controller.value.playbackSpeed,
          ),
        ),
    ]);
  }

  Widget secondaryMenuContainer(List<Widget> children) {
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
                Expanded(
                  child: Text(widget.language.settings, style: textStyle),
                ),
              ]),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget inkWellDesigned({Widget child, void Function() onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white.withOpacity(0.2),
        onTap: onTap,
        child: child,
      ),
    );
  }

  Widget textDesigned(String text, bool selected) {
    return Padding(
      padding: Margin.horizontal(8),
      child: Row(children: [
        Expanded(
          child: Text(
            text,
            style: textStyle.merge(TextStyle(fontWeight: FontWeight.normal)),
          ),
        ),
        if (selected) style.selected,
      ]),
    );
  }
}
