import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/domain/entities/subtitle.dart';
import 'package:video_viewer/domain/entities/video_source.dart';
import 'package:video_viewer/ui/settings_menu/widgets/helpers.dart';
import 'package:video_viewer/ui/settings_menu/widgets/seconday_menu.dart';

class CaptionMenu extends StatelessWidget {
  const CaptionMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final activeSource = video.activeSource;
    final activeCaption = video.activeCaption;
    final none = metadata.language.captionNone;

    return SecondaryMenu(
      children: [
        CustomInkWell(
          onTap: () {
            query
                .video(context)
                .changeSubtitle(subtitle: null, subtitleName: none);
          },
          child: CustomText(
            text: none,
            selected: activeCaption == none || activeCaption == null,
          ),
        ),
        for (MapEntry<String, VideoSource> entry in metadata.source.entries)
          if (entry.key == activeSource && entry.value.subtitle != null)
            for (MapEntry<String, VideoViewerSubtitle> subtitle
                in entry.value.subtitle.entries)
              CustomInkWell(
                onTap: () {
                  query.video(context).changeSubtitle(
                        subtitle: subtitle.value,
                        subtitleName: subtitle.key,
                      );
                },
                child: CustomText(
                  text: subtitle.key,
                  selected: subtitle.key == activeCaption,
                ),
              ),
      ],
    );
  }
}
