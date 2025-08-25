part of '../../ipados_menu_bar.dart';

// Note: This will be trickier to accomplish, as it has to respect the OS behavior,
// only adding upon listeners

/// Custom [PlatformMenu] using a menuId to replace the native "window" menu
/// with listeners for when users switches layout, switches screen or
/// create a new window.
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
              PlatformMenu(label: 'Translate & Resize', menus: []),
            ],
          ),
        ],
      );
}
