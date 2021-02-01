import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/ui/settings_menu/widgets/helpers.dart';
import 'package:video_viewer/ui/settings_menu/widgets/secondary_menu.dart';

class QualityMenu extends StatelessWidget {
  const QualityMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final activeSource = video.activeSource;

    return SecondaryMenu(
      children: [
        for (MapEntry<String, VideoSource> entry in metadata.source.entries)
          CustomInkWell(
            onTap: () {
              if (entry.key != activeSource)
                query.video(context).changeSource(
                      source: entry.value,
                      sourceName: entry.key,
                    );
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
