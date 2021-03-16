import 'package:flutter/material.dart';

const int kDefaultMenus = 3;

class SettingsMenuItem {
  ///Add a [SettingMenuItem] next to the last default SettingsMenuItem
  SettingsMenuItem({
    required this.secondaryMenu,
    this.mainMenu,
    this.themed,
    this.secondaryMenuWidth = 150,
  });

  ///If **themed** is not-null, this argument is ignored.
  final Widget? mainMenu;

  ///When you tap the mainMenu item will show this secondayMenu.
  final Widget secondaryMenu;

  ///Its the width of the secondary menu
  final double secondaryMenuWidth;

  ///If you want your MainItem with the theme of the others MenuItems use that.
  ///**Note:** If SettingsMenuItemThemed is not-null then [mainMenu] argument will be ignored.
  final SettingsMenuItemThemed? themed;
}

class SettingsMenuItemThemed {
  ///It create a new MenuItem with the theme of the others MenuItems
  SettingsMenuItemThemed({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final Widget icon;
  final String title, subtitle;
}
