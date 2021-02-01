import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';

import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/caption_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/quality_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/speed_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/main_menu.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final meta = query.videoMetadata(context);
    final items = meta.settingsMenuItems;

    final bool main = video.isShowingMainSettingsMenu;
    final List<bool> secondary = video.isShowingSecondarySettingsMenus;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Stack(children: [
        GestureDetector(
          onTap: () => query.video(context).hideSettingsMenu(),
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        CustomOpacityTransition(
          visible: !main,
          child: GestureDetector(
            onTap: video.closeAllSecondarySettingsMenus,
            child: Container(color: Colors.transparent),
          ),
        ),
        CustomOpacityTransition(visible: main, child: MainMenu()),
        CustomOpacityTransition(
          visible: secondary[0],
          child: const QualityMenu(),
        ),
        CustomOpacityTransition(
          visible: secondary[1],
          child: const SpeedMenu(),
        ),
        CustomOpacityTransition(
          visible: secondary[2],
          child: const CaptionMenu(),
        ),
        if (items != null)
          for (int i = 0; i < items.length; i++)
            CustomOpacityTransition(
              visible: secondary[i + kDefaultMenus],
              child: SecondaryMenu(children: [items[i].secondaryMenu]),
            ),
      ]),
    );
  }
}
