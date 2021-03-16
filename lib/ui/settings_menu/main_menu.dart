import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/widgets/helpers.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller!.value.playbackSpeed;
    final style = metadata.style.settingsStyle;
    final items = style.items;

    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: [
          _MainMenuItem(
            index: 0,
            icon: style.settings,
            title: metadata.language.quality,
            subtitle: video.activeSource!,
          ),
          _MainMenuItem(
            index: 1,
            icon: style.speed,
            title: metadata.language.speed,
            subtitle: speed == 1.0 ? metadata.language.normalSpeed : "x$speed",
          ),
          if (video.source![video.activeSource!]!.subtitle != null)
            _MainMenuItem(
              index: 2,
              icon: style.caption,
              title: metadata.language.caption,
              subtitle: video.activeCaption ?? metadata.language.captionNone,
            ),
          if (items != null)
            for (int i = 0; i < items.length; i++) ...[
              items[i].themed == null
                  ? SplashCircularIcon(
                      onTap: () => query
                          .video(context)
                          .openSecondarySettingsMenu(i + kDefaultMenus),
                      padding: Margin.all(style.paddingBetween / 2),
                      child: items[i].mainMenu,
                    )
                  : _MainMenuItem(
                      index: i + kDefaultMenus,
                      icon: items[i].themed!.icon,
                      title: items[i].themed!.title,
                      subtitle: items[i].themed!.subtitle,
                    ),
            ],
        ],
      ),
    );
  }
}

class _MainMenuItem extends StatelessWidget {
  const _MainMenuItem({
    Key? key,
    required this.index,
    required this.icon,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  final Widget icon;
  final String title, subtitle;
  final int index;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);

    final style = metadata.style.settingsStyle;
    final textStyle = metadata.style.textStyle;

    return SplashCircularIcon(
      padding: Margin.all(style.paddingBetween),
      onTap: () => query.video(context).openSecondarySettingsMenu(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          AutoSizeText(title, style: textStyle),
          AutoSizeText(
            subtitle,
            style: textStyle.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: textStyle.fontSize! - 2,
            )),
          )
        ],
      ),
    );
  }
}
