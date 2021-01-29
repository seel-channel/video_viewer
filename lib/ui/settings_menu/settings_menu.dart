import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';

import 'package:video_viewer/ui/settings_menu/widgets/seconday_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/quality_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/speed_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/main_menu.dart';
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

  @override
  void initState() {
    show = List.filled(12, false);
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
    final meta = _query.videoMetadata(context);
    final items = meta.settingsMenuItems;

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
        CustomOpacityTransition(
          visible: show[0],
          child: QualityMenu(closeMenu: closeAllAndShowMenu),
        ),
        CustomOpacityTransition(
          visible: show[1],
          child: SpeedMenu(closeMenu: closeAllAndShowMenu),
        ),
        if (items != null)
          for (int i = 0; i < items.length; i++)
            CustomOpacityTransition(
              visible: show[i + 2],
              child: SecondaryMenu(
                children: [items[i].secondaryMenu],
                closeMenu: closeAllAndShowMenu,
              ),
            ),
      ]),
    );
  }
}
