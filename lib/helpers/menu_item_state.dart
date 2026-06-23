part of '../../ipados_menu_bar.dart';

/// Enum used to represent a menu item state, copying UIKit's [UIMenuElement.State]
/// behavior
enum MenuItemState {
  /// Item is enabled/checked, shown with a checkmark (✓).
  on,

  /// Item is disabled/unchecked, shown without any indicator.
  off,

  /// Item is in a mixed/partial state, shown with a dash (-).
  mixed,
}
