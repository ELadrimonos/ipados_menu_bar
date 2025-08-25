part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenuItem] class with a new ***icon*** attribute.
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
