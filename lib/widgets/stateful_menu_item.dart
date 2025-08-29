part of '../ipados_menu_bar.dart';

/// Custom [PlatformMenuItem] class with a [MenuItemState.on], [MenuItemState.off]
/// or [MenuItemState.mixed] state. In iPadOS' menu bar, the state will be
/// represented as a native icon (✓,ⅹ,-) using UIKit's [UIMenuElement.State].
class StatefulPlatformMenuItem extends PlatformMenuItem {
  MenuItemState state;

  StatefulPlatformMenuItem({
    required super.label,
    required this.state,
    super.onSelected,
    super.onSelectedIntent,
    super.shortcut,
  });
}
