import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

// Note: This will be trickier to accomplish, as it has to respect the OS behavior,
// only adding upon listeners

/// Only use for callbacks when user switches layout, switches screen or
/// creates a new window.
class IPadWindowMenu extends IPadMenu {
  @override
  String get menuId => 'window';

  // Should be logic only, don't render these items in the future
  IPadWindowMenu()
    : super(
        label: 'Window',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(label: 'Minimize'),
              PlatformMenuItem(label: 'Exit Full Screen'),
              PlatformMenuItem(label: 'Center'),
              // Doing my best translating from spanish by head
              PlatformMenu(label: 'Translate & Redimension', menus: []),
            ],
          ),
        ],
      );
}
