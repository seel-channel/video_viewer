import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:video_viewer/domain/entities/styles/video_viewer.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/bloc/metadata.dart';
import 'package:video_viewer/widgets/helpers.dart';

class SettingsMenu extends StatefulWidget {
  SettingsMenu({
    Key key,
    @required this.onChangeVisible,
  }) : super(key: key);

  final void Function() onChangeVisible;

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  VideoPlayerController _controller;
  SettingsMenuStyle _style;
  VideoMetadata _meta;
  TextStyle _textStyle;
  String _activeSource;

  bool showMenu = true;
  List<bool> show = [false, false];
  List<Widget> mainMenuItems = [];
  List<Widget> secondaryMenus = [];

  @override
  void initState() {
    Misc.onLayoutRendered(() {
      final query = VideoQuery();
      final meta = query.getVideoMetadata(context);
      final video = query.getVideo(context);
      final style = meta.style;
      final items = meta.settingsMenuItems;

      _meta = meta;
      _style = style.settingsStyle;
      _controller = video.controller;
      _activeSource = video.activeSource;
      _textStyle = style.textStyle;
      if (items != null)
        for (int i = 0; i < items.length; i++) {
          show.add(false);
          mainMenuItems.add(_gestureMainMenuItem(
            index: i + 2,
            child: items[i].mainMenu,
          ));
          secondaryMenus.add(
            secondaryMenuContainer(
              [items[i].secondaryMenu],
            ),
          );
        }
    });
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Stack(children: [
        GestureDetector(
          onTap: widget.onChangeVisible,
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        CustomOpacityTransition(
          visible: !showMenu,
          child: GestureDetector(
            onTap: closeAllAndShowMenu,
            child: Container(color: Colors.transparent),
          ),
        ),
        CustomOpacityTransition(visible: showMenu, child: mainMenu()),
        CustomOpacityTransition(visible: show[1], child: settingsSpeedMenu()),
        CustomOpacityTransition(visible: show[0], child: settingsQualityMenu()),
        for (int i = 0; i < secondaryMenus.length; i++)
          CustomOpacityTransition(
            visible: show[i + 2],
            child: secondaryMenus[i],
          ),
      ]),
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
    final double speed = _controller.value.playbackSpeed;
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _gestureMainMenuItem(
            index: 0,
            child: settingsItemMenu(
              _meta.language.quality,
              _activeSource,
              _style.settings,
            ),
          ),
          SizedBox(width: _style.paddingBetween),
          _gestureMainMenuItem(
            index: 1,
            child: settingsItemMenu(
              _meta.language.speed,
              speed == 1.0 ? _meta.language.normalSpeed : "x$speed",
              _style.speed,
            ),
          ),
          for (Widget child in mainMenuItems) ...[
            SizedBox(width: _style.paddingBetween),
            child,
          ],
        ],
      ),
    );
  }

  Widget settingsItemMenu(String title, String subtitle, Widget icon) {
    return Container(
      color: Colors.transparent,
      padding: Margin.all(_style.paddingBetween / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: _textStyle),
          Text(
            subtitle,
            style: _textStyle.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize:
                  _textStyle.fontSize - _meta.style.inLandscapeEnlargeTheTextBy,
            )),
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
      for (MapEntry<String, dynamic> entry in _meta.source.entries)
        inkWellDesigned(
          onTap: () {
            if (entry.key != _activeSource)
              VideoQuery()
                  .getVideo(context)
                  .changeSource(source: entry.value, activeSource: entry.key);
            closeAllAndShowMenu();
          },
          child: textDesigned(entry.key, entry.key == _activeSource),
        ),
    ]);
  }

  Widget settingsSpeedMenu() {
    return secondaryMenuContainer([
      for (double i = 0.5; i <= 2; i += 0.25)
        inkWellDesigned(
          onTap: () {
            VideoQuery().updateVideoController(context).setPlaybackSpeed(i);
            closeAllAndShowMenu();
          },
          child: textDesigned(
            i == 1.0 ? _meta.language.normalSpeed : "x$i",
            i == _controller.value.playbackSpeed,
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
                _style.chevron,
                Expanded(
                  child: Text(_meta.language.settings, style: _textStyle),
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
            style: _textStyle.merge(TextStyle(fontWeight: FontWeight.normal)),
          ),
        ),
        if (selected) _style.selected,
      ]),
    );
  }
}
