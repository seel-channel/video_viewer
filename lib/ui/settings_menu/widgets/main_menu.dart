import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/ui/settings_menu/settings_menu.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key key, @required this.onOpenMenu}) : super(key: key);

  final void Function(int index) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;
    final style = metadata.style.settingsStyle;
    final items = metadata.settingsMenuItems;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onOpenMenu(0),
            behavior: HitTestBehavior.opaque,
            child: _MainMenuItem(
              icon: style.settings,
              title: metadata.language.quality,
              subtitle: video.activeSource,
            ),
          ),
          SizedBox(width: style.paddingBetween),
          GestureDetector(
            onTap: () => onOpenMenu(1),
            behavior: HitTestBehavior.opaque,
            child: _MainMenuItem(
              icon: style.speed,
              title: metadata.language.speed,
              subtitle:
                  speed == 1.0 ? metadata.language.normalSpeed : "x$speed",
            ),
          ),
          SizedBox(width: style.paddingBetween),
          GestureDetector(
            onTap: () => onOpenMenu(2),
            behavior: HitTestBehavior.opaque,
            child: _MainMenuItem(
              icon: style.caption,
              title: metadata.language.caption,
              subtitle: video.activeCaption ?? metadata.language.captionNone,
            ),
          ),
          if (items != null)
            for (int i = 0; i < items.length; i++) ...[
              SizedBox(width: style.paddingBetween),
              GestureDetector(
                onTap: () => onOpenMenu(i + kDefaultMenus),
                behavior: HitTestBehavior.opaque,
                child: items[i].mainMenu,
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
    this.title,
    this.subtitle,
    this.icon,
  }) : super(key: key);

  final String title, subtitle;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final metadata = query.videoMetadata(context, listen: true);

    final style = metadata.style.settingsStyle;
    final textStyle = metadata.style.textStyle;

    return Container(
      color: Colors.transparent,
      padding: Margin.all(style.paddingBetween / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          Text(title, style: textStyle),
          Text(
            subtitle,
            style: textStyle.merge(TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: textStyle.fontSize -
                  metadata.style.inLandscapeEnlargeTheTextBy,
            )),
          ),
        ],
      ),
    );
  }
}
