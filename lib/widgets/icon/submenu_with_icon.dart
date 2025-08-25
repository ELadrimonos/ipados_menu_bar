part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] class with a new ***icon*** attribute.
class PlatformMenuWithIcon extends PlatformMenu {
  IconData icon;

  PlatformMenuWithIcon({
    required this.icon,
    required super.label,
    required super.menus,
  });
}
