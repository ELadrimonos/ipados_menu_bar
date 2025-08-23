import 'package:flutter/cupertino.dart';

class PlatformMenuItemWithIcon extends PlatformMenuItem {
  IconData icon;

  PlatformMenuItemWithIcon({
    required super.label,
    required this.icon,
    super.onSelected,
    super.onSelectedIntent,
    super.shortcut,
  });
}
