part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to access the native "application" menu
/// adding the additional items from this class.
class IPadAppMenu extends IPadMenu {
  @override
  String get menuId => 'application';

  IPadAppMenu({List<PlatformMenuItem>? additionalItems})
    : super(
        label: 'App Info',
        menus: (additionalItems != null && additionalItems.isNotEmpty)
            ? additionalItems
            : [
                if (defaultTargetPlatform != TargetPlatform.iOS)
                  PlatformMenuItem(label: ''),
              ],
      );
}
