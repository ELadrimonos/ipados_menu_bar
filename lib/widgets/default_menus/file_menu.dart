part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to access the native "file" menu adding
/// thea additional items from this class. In case you need to listen when the
/// app is closed, checking out [WidgetsBindingObserver] is highly recommended.
class IPadFileMenu extends IPadMenu {
  @override
  String get menuId => 'file';

  IPadFileMenu({List<PlatformMenuItem>? additionalItems})
    : super(
        label: 'File',
        menus: (additionalItems != null && additionalItems.isNotEmpty)
            ? additionalItems
            : [
                if (defaultTargetPlatform != TargetPlatform.iOS)
                  PlatformMenuItem(label: 'No items'),
              ],
      );
}
