part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] class with a new ***icon*** attribute.
class PlatformMenuWithIcon extends PlatformMenu {
  /// Icon data shown next to the submenu.
  IconData? icon;

  /// Widget rendered as the submenu's icon, as an alternative to [icon].
  Widget? iconWidget;

  /// Creates a submenu with an icon. Exactly one of [icon] or [iconWidget]
  /// must be provided.
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
