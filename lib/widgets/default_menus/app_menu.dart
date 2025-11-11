part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to access the native "application" menu
/// adding the additional items from this class.
class IPadAppMenu extends IPadMenu {
  @override
  String get menuId => 'application';

  IPadAppMenu({List<PlatformMenuItem>? additionalItems})
    : super(
        label: 'App Info',
        menus: [
          if (PlatformProvidedMenuItem.hasMenu(
            PlatformProvidedMenuItemType.about,
          ))
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.about,
                ),
              ],
            ),
          if (additionalItems != null && additionalItems.isNotEmpty)
            PlatformMenuItemGroup(members: additionalItems),
          if (PlatformProvidedMenuItem.hasMenu(
            PlatformProvidedMenuItemType.servicesSubmenu,
          ))
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.servicesSubmenu,
                ),
              ],
            ),
          if (PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.hide,
              ) ||
              PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.hideOtherApplications,
              ) ||
              PlatformProvidedMenuItem.hasMenu(
                PlatformProvidedMenuItemType.showAllApplications,
              ))
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hide,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.hideOtherApplications,
                ),
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.showAllApplications,
                ),
              ],
            ),
          if (PlatformProvidedMenuItem.hasMenu(
            PlatformProvidedMenuItemType.quit,
          ))
            const PlatformMenuItemGroup(
              members: [
                PlatformProvidedMenuItem(
                  type: PlatformProvidedMenuItemType.quit,
                ),
              ],
            ),
          // Fallback: makes sure there's always 1 element so it doesn't crash
          if (![
                PlatformProvidedMenuItemType.about,
                PlatformProvidedMenuItemType.servicesSubmenu,
                PlatformProvidedMenuItemType.hide,
                PlatformProvidedMenuItemType.quit,
              ].any(PlatformProvidedMenuItem.hasMenu) &&
              (additionalItems == null || additionalItems.isEmpty) &&
              defaultTargetPlatform != TargetPlatform.iOS)
            const PlatformMenuItem(label: 'No items'),
        ],
      );
}
