import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';

import 'package:video_viewer/domain/entities/settings_menu_item.dart';
import 'package:video_viewer/data/repositories/video.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;
    final style = metadata.style.settingsStyle;
    final items = style.items;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _MainMenuItem(
            index: 0,
            icon: style.settings,
            title: Text(metadata.language.quality),
            subtitle: Text(video.activeSource),
          ),
          SizedBox(width: style.paddingBetween),
          _MainMenuItem(
            index: 1,
            icon: style.speed,
            title: Text(metadata.language.speed),
            subtitle:
                Text(speed == 1.0 ? metadata.language.normalSpeed : "x$speed"),
          ),
          SizedBox(width: style.paddingBetween),
          _MainMenuItem(
            index: 2,
            icon: style.caption,
            title: Text(metadata.language.caption),
            subtitle:
                Text(video.activeCaption ?? metadata.language.captionNone),
          ),
          if (items != null)
            for (int i = 0; i < items.length; i++) ...[
              SizedBox(width: style.paddingBetween),
              items[i].themed == null
                  ? GestureDetector(
                      onTap: () => query
                          .video(context)
                          .openSecondarySettingsMenu(i + kDefaultMenus),
                      behavior: HitTestBehavior.opaque,
                      child: items[i].mainMenu,
                    )
                  : _MainMenuItem(
                      index: i + kDefaultMenus,
                      icon: items[i].themed.icon,
                      title: items[i].themed.title,
                      subtitle: items[i].themed.subtitle,
                    ),
            ],
        ],
      ),
    );
  }
}

class _MainMenuItem extends StatelessWidget {
  const _MainMenuItem({
    Key key,
    @required this.index,
    @required this.icon,
    @required this.title,
    @required this.subtitle,
  }) : super(key: key);

  final Widget title, subtitle, icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);

    final style = metadata.style.settingsStyle;
    final textStyle = metadata.style.textStyle;

    return GestureDetector(
      onTap: () => query.video(context).openSecondarySettingsMenu(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: Colors.transparent,
        padding: Margin.all(style.paddingBetween / 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            DefaultTextStyle(child: title, style: textStyle),
            DefaultTextStyle(
              child: subtitle,
              style: textStyle.merge(TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: textStyle.fontSize -
                    metadata.style.inLandscapeEnlargeTheTextBy,
              )),
            )
          ],
        ),
      ),
    );
  }
}
