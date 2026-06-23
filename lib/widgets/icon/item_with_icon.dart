part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenuItem] class with a new ***icon*** attribute.
class PlatformMenuItemWithIcon extends PlatformMenuItem {
  /// Icon data shown next to the menu item.
  IconData? icon;

  /// Widget rendered as the menu item's icon, as an alternative to [icon].
  Widget? iconWidget;

  /// Creates a menu item with an icon. Exactly one of [icon] or [iconWidget]
  /// must be provided.
  PlatformMenuItemWithIcon({
    required super.label,
    this.icon,
    this.iconWidget,
    super.onSelected,
    super.onSelectedIntent,
    super.shortcut,
  }) : assert(
         (icon != null) != (iconWidget != null),
         'Exactly one of icon or iconWidget must be provided.',
       );
}
