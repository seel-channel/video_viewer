import 'package:flutter/material.dart';

const int kDefaultMenus = 3;

class SettingsMenuItem {
  final Widget mainMenu;
  final Widget secondaryMenu;

  SettingsMenuItem({@required this.mainMenu, @required this.secondaryMenu});
}
