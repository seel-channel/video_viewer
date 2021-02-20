import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class SpeedMenu extends StatelessWidget {
  const SpeedMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;

    return SecondaryMenu(
      children: [
        for (double i = 0.5; i <= 2; i += 0.25)
          CustomInkWell(
            onTap: () {
              final video = query.video(context);
              video.controller.setPlaybackSpeed(i);
              video.closeAllSecondarySettingsMenus();
            },
            child: CustomText(
                text: i == 1.0 ? metadata.language.normalSpeed : "x$i",
                selected: i == speed),
          ),
      ],
    );
  }
}
