import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/settings_menu_item.dart';

import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/caption_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/quality_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/speed_menu.dart';
import 'package:video_viewer/ui/settings_menu/main_menu.dart';
import 'package:video_viewer/ui/widgets/transitions.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final meta = query.videoMetadata(context);
    final items = meta.style.settingsStyle.items;

    final bool main = video.isShowingMainSettingsMenu;
    final List<bool> secondary = video.isShowingSecondarySettingsMenus;

    return Stack(children: [
      GestureDetector(
        onTap: () {
          final controller = query.video(context);
          controller.closeSettingsMenu();
          controller.showAndHideOverlay(true);
        },
        child: Container(color: Colors.black.withOpacity(0.32)),
      ),
      CustomOpacityTransition(
        visible: !main,
        child: GestureDetector(
          onTap: video.closeAllSecondarySettingsMenus,
          child: Container(color: Colors.transparent),
        ),
      ),
      CustomOpacityTransition(visible: main, child: MainMenu()), //MAIN MENU
      CustomOpacityTransition(
        visible: secondary[0],
        child: QualityMenu(),
      ),
      CustomOpacityTransition(
        visible: secondary[1],
        child: SpeedMenu(),
      ),
      CustomOpacityTransition(
        visible: secondary[2],
        child: CaptionMenu(),
      ),
      if (items != null)
        for (int i = 0; i < items.length; i++)
          CustomOpacityTransition(
            visible: secondary[i + kDefaultMenus],
            child: SecondaryMenu(
              width: items[i].secondaryMenuWidth,
              children: [items[i].secondaryMenu],
            ),
          ),
    ]);
  }
}
