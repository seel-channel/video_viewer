import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu_item.dart';

class QualityMenu extends StatelessWidget {
  const QualityMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);

    final activeSourceName = video.activeSourceName;

    return SecondaryMenu(children: [
      for (MapEntry<String, VideoSource> entry in video.source!.entries)
        SecondaryMenuItem(
          onTap: () async {
            final video = query.video(context);
            video.closeAllSecondarySettingsMenus();
            video.closeSettingsMenu();
            if (entry.key != activeSourceName) {
              await video.changeSource(source: entry.value, name: entry.key);
            }
          },
          text: entry.key,
          selected: entry.key == activeSourceName,
        ),
    ]);
  }
}
