import 'package:flutter/material.dart';

const int kDefaultMenus = 3;

class SettingsMenuItem {
  SettingsMenuItem({
    @required this.secondaryMenu,
    this.mainMenu,
    this.themed,
  });

  ///If **themed** is not-null, this argument is ignored.
  final Widget mainMenu;

  final Widget secondaryMenu;

  final SettingsMenuItemThemed themed;
}

class SettingsMenuItemThemed {
  SettingsMenuItemThemed({
    @required this.icon,
    @required this.title,
    @required this.subtitle,
  });

  final Widget icon;
  final String title, subtitle;
}
