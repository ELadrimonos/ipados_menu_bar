import 'package:flutter/cupertino.dart';

class PlatformMenuWithIcon extends PlatformMenu {
  IconData icon;

  PlatformMenuWithIcon({
    required this.icon,
    required super.label,
    required super.menus,
  });
}
