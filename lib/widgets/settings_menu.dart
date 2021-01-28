import 'dart:ui';
import 'package:helpers/helpers.dart';
import 'package:flutter/material.dart';
import 'package:video_viewer/data/repositories/video.dart';
import 'package:video_viewer/widgets/helpers.dart';

class SettingsMenu extends StatefulWidget {
  SettingsMenu({Key key}) : super(key: key);

  @override
  _SettingsMenuState createState() => _SettingsMenuState();
}

class _SettingsMenuState extends State<SettingsMenu> {
  final VideoQuery _query = VideoQuery();

  bool showMenu = true;
  List<bool> show = [false, false];
  List<Widget> mainMenuItems = [];
  List<Widget> secondaryMenus = [];

  @override
  void initState() {
    Misc.onLayoutRendered(() {
      final meta = _query.videoMetadata(context);
      final items = meta.settingsMenuItems;

      if (items != null)
        for (int i = 0; i < items.length; i++) {
          show.add(false);
          mainMenuItems.add(_gestureMainMenuItem(
            index: i + 2,
            child: items[i].mainMenu,
          ));
          secondaryMenus.add(
            _SecondaryMenu(
              children: [items[i].secondaryMenu],
              closeMenu: closeAllAndShowMenu,
            ),
          );
        }
    });
    super.initState();
  }

  void closeAllAndShowMenu() {
    setState(() {
      showMenu = true;
      show.fillRange(0, show.length, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 1.0, sigmaY: 1.0),
      child: Stack(children: [
        GestureDetector(
          onTap: () => _query.video(context).isShowingSettingsMenu = false,
          child: Container(color: Colors.black.withOpacity(0.32)),
        ),
        CustomOpacityTransition(
          visible: !showMenu,
          child: GestureDetector(
            onTap: closeAllAndShowMenu,
            child: Container(color: Colors.transparent),
          ),
        ),
        CustomOpacityTransition(
          visible: showMenu,
          child: _MainMenu(
            onOpenMenu: (int index) => setState(() {
              showMenu = false;
              show[index] = true;
            }),
          ),
        ),
        CustomOpacityTransition(visible: show[1], child: settingsSpeedMenu()),
        CustomOpacityTransition(visible: show[0], child: settingsQualityMenu()),
        for (int i = 0; i < secondaryMenus.length; i++)
          CustomOpacityTransition(
            visible: show[i + 2],
            child: secondaryMenus[i],
          ),
      ]),
    );
  }

  Widget _gestureMainMenuItem({int index, Widget child}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          showMenu = false;
          show[index] = true;
        });
      },
      child: child,
    );
  }

  //---------------//
  //SECONDARY MENUS//
  //---------------//
  Widget settingsQualityMenu() {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final activeSource = video.activeSource;

    return _SecondaryMenu(
      closeMenu: closeAllAndShowMenu,
      children: [
        for (MapEntry<String, dynamic> entry in metadata.source.entries)
          _CustomInkWell(
            onTap: () {
              if (entry.key != activeSource)
                query
                    .video(context)
                    .changeSource(source: entry.value, activeSource: entry.key);
              closeAllAndShowMenu();
            },
            child: _CustomText(
                text: entry.key, selected: entry.key == activeSource),
          ),
      ],
    );
  }

  Widget settingsSpeedMenu() {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;

    return _SecondaryMenu(
      closeMenu: closeAllAndShowMenu,
      children: [
        for (double i = 0.5; i <= 2; i += 0.25)
          _CustomInkWell(
            onTap: () {
              query.video(context).controller.setPlaybackSpeed(i);
              closeAllAndShowMenu();
            },
            child: _CustomText(
                text: i == 1.0 ? metadata.language.normalSpeed : "x$i",
                selected: i == speed),
          ),
      ],
    );
  }
}

class _CustomText extends StatelessWidget {
  const _CustomText({
    Key key,
    @required this.text,
    @required this.selected,
  }) : super(key: key);

  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final metadata = VideoQuery().videoMetadata(context, listen: true);
    final style = metadata.style.settingsStyle;

    return Padding(
      padding: Margin.horizontal(8),
      child: Row(children: [
        Expanded(
          child: Text(
            text,
            style: metadata.style.textStyle.merge(
              TextStyle(
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ),
        if (selected) style.selected,
      ]),
    );
  }
}

class _CustomInkWell extends StatelessWidget {
  const _CustomInkWell({
    Key key,
    @required this.child,
    @required this.onTap,
  }) : super(key: key);

  final Widget child;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.white.withOpacity(0.2),
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _SecondaryMenu extends StatelessWidget {
  const _SecondaryMenu({
    Key key,
    this.children,
    this.closeMenu,
  }) : super(key: key);

  final List<Widget> children;
  final void Function() closeMenu;

  @override
  Widget build(BuildContext context) {
    final metadata = VideoQuery().videoMetadata(context, listen: true);
    final style = metadata.style.settingsStyle;

    return Center(
      child: Container(
        width: 150,
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: closeMenu,
              child: Row(children: [
                style.chevron,
                Expanded(
                  child: Text(
                    metadata.language.settings,
                    style: metadata.style.textStyle,
                  ),
                ),
              ]),
            ),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _MainMenu extends StatelessWidget {
  const _MainMenu({Key key, this.onOpenMenu}) : super(key: key);

  final void Function(int index) onOpenMenu;

  @override
  Widget build(BuildContext context) {
    final query = VideoQuery();
    final video = query.video(context, listen: true);
    final metadata = query.videoMetadata(context, listen: true);

    final speed = video.controller.value.playbackSpeed;
    final style = metadata.style.settingsStyle;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onOpenMenu(0),
            child: _MainMenuItem(
              icon: style.settings,
              title: metadata.language.quality,
              subtitle: video.activeSource,
            ),
          ),
          SizedBox(width: style.paddingBetween),
          GestureDetector(
            onTap: () => onOpenMenu(1),
            child: _MainMenuItem(
              icon: style.speed,
              title: metadata.language.speed,
              subtitle:
                  speed == 1.0 ? metadata.language.normalSpeed : "x$speed",
            ),
          ),
          // for (Widget child in mainMenuItems) ...[
          //   SizedBox(width: style.paddingBetween),
          //   child,
          // ],
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
