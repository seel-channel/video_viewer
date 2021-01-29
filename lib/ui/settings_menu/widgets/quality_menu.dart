import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/ui/settings_menu/widgets/helpers.dart';
import 'package:video_viewer/ui/settings_menu/widgets/seconday_menu.dart';

class QualityMenu extends StatelessWidget {
  const QualityMenu({Key key, @required this.closeMenu}) : super(key: key);

  final void Function() closeMenu;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final activeSource = video.activeSource;

    return SecondaryMenu(
      closeMenu: closeMenu,
      children: [
        for (MapEntry<String, VideoSource> entry in metadata.source.entries)
          CustomInkWell(
            onTap: () {
              if (entry.key != activeSource)
                query.video(context).changeSource(
                      source: entry.value.video,
                      activeSource: entry.key,
                    );
              closeMenu?.call();
            },
            child: CustomText(
              text: entry.key,
              selected: entry.key == activeSource,
            ),
          ),
      ],
    );
  }
}
