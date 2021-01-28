import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/settings_menu/widgets/seconday_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/main_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/helpers.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class SettingsMenu extends StatefulWidget {
  SettingsMenu({Key key}) : super(key: key);

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  final VideoQuery _query = VideoQuery();

  bool showMenu = true;
  List<bool> show = [false, false];
  List<Widget> mainMenuItems = [];
  List<Widget> secondaryMenus = [];

  @override
  void initState() {
    Misc.onLayoutRendered(() {
      final meta = _query.videoMetadata(context);
      final items = meta.settingsMenuItems;

      if (items != null)
        for (int i = 0; i < items.length; i++) {
          show.add(false);
          mainMenuItems.add(_gestureMainMenuItem(
            index: i + 2,
            child: items[i].mainMenu,
          ));
          secondaryMenus.add(
            SecondaryMenu(
              children: [items[i].secondaryMenu],
              closeMenu: closeAllAndShowMenu,
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
          onTap: () => _query.video(context).isShowingSettingsMenu = false,
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        CustomOpacityTransition(
          visible: !showMenu,
          child: GestureDetector(
            onTap: closeAllAndShowMenu,
            child: Container(color: Colors.transparent),
          ),
        ),
        CustomOpacityTransition(
          visible: showMenu,
          child: MainMenu(
            onOpenMenu: (int index) => setState(() {
              showMenu = false;
              show[index] = true;
            }),
          ),
        ),
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

  Widget _gestureMainMenuItem({int index, Widget child}) {
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

  //---------------//
  //SECONDARY MENUS//
  //---------------//
  Widget settingsQualityMenu() {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final activeSource = video.activeSource;

    return SecondaryMenu(
      closeMenu: closeAllAndShowMenu,
      children: [
        for (MapEntry<String, dynamic> entry in metadata.source.entries)
          CustomInkWell(
            onTap: () {
              if (entry.key != activeSource)
                query
                    .video(context)
                    .changeSource(source: entry.value, activeSource: entry.key);
              closeAllAndShowMenu();
            },
            child: CustomText(
                text: entry.key, selected: entry.key == activeSource),
          ),
      ],
    );
  }

  Widget settingsSpeedMenu() {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;

    return SecondaryMenu(
      closeMenu: closeAllAndShowMenu,
      children: [
        for (double i = 0.5; i <= 2; i += 0.25)
          CustomInkWell(
            onTap: () {
              query.video(context).controller.setPlaybackSpeed(i);
              closeAllAndShowMenu();
            },
            child: CustomText(
                text: i == 1.0 ? metadata.language.normalSpeed : "x$i",
                selected: i == speed),
          ),
      ],
    );
  }
}
