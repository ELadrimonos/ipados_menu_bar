part of '../ipados_menu_bar.dart';

/// Mixin that adds state functionality to menu items. In iPadOS' menu bar,
/// the state will be represented as a native icon (✓, *none*,-) using UIKit's
/// [UIMenuElement.State].
mixin StatefulMenuItem {
  late MenuItemState state;
}

/// Custom [PlatformMenuItem] class with a [MenuItemState.on], [MenuItemState.off]
/// or [MenuItemState.mixed] state. In iPadOS' menu bar, the state will be
/// represented as a native icon (✓, *none*,-) using UIKit's [UIMenuElement.State].
class StatefulPlatformMenuItem extends PlatformMenuItem with StatefulMenuItem {
  StatefulPlatformMenuItem({
    required super.label,
    required MenuItemState state,
    super.onSelected,
    super.onSelectedIntent,
    super.shortcut,
  }) {
    this.state =
        state; // Manually set state in constructor, or else late init fails
  }
}

/// Custom [PlatformMenuItemWithIcon] class with a [MenuItemState.on],
/// [MenuItemState.off] or [MenuItemState.mixed] state. In iPadOS' menu bar,
/// the state will be represented as a native icon (✓, *none*,-) using UIKit's
/// [UIMenuElement.State].
class StatefulPlatformMenuItemWithIcon extends PlatformMenuItemWithIcon
    with StatefulMenuItem {
  StatefulPlatformMenuItemWithIcon({
    required super.label,
    super.icon,
    super.iconWidget,
    required MenuItemState state,
    super.onSelected,
    super.onSelectedIntent,
    super.shortcut,
  }) : assert(
         (icon != null) != (iconWidget != null),
         'Exactly one of icon or iconWidget must be provided.',
       ) {
    this.state =
        state; // Manually set state in constructor, or else late init fails
  }
}
