part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenuItem] class with a new ***icon*** attribute.
class PlatformMenuItemWithIcon extends PlatformMenuItem {
  IconData? icon;
  Widget? iconWidget;

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
