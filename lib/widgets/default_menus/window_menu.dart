import 'package:flutter/cupertino.dart';

// Note: This will be trickier to accomplish, as it has to respect the OS behavior,
// only adding upon listeners

/// Only use for callbacks when user switches layout, switches screen or
/// creates a new window.
class DefaultWindowMenu extends PlatformMenu {
  DefaultWindowMenu()
    : super(label: 'Window', menus: [
      PlatformMenuItemGroup(members: [
        PlatformMenuItem(label: 'Minimize'),
        PlatformMenuItem(label: 'Exit Full Screen'),
        PlatformMenuItem(label: 'Center'),
        // Doing my best translating from spanish by head
        PlatformMenu(label: 'Translate & Redimension', menus: []),
      ]),
  ]);
}
