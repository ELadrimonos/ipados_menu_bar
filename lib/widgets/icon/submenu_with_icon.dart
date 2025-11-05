part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] class with a new ***icon*** attribute.
class PlatformMenuWithIcon extends PlatformMenu {
  IconData? icon;
  Widget? iconWidget;

  PlatformMenuWithIcon({
    this.icon,
    this.iconWidget,
    required super.label,
    required super.menus,
  }) : assert(
         (icon == null) != (iconWidget == null),
         'Exactly one of icon or iconWidget must be provided.',
       );
}
