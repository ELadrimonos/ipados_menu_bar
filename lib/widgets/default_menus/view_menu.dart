part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to replace the native "view" menu with
/// the items from this class. Making it easier and faster to link callbacks
/// from the app.
/// Additional items in this menu should be used to switch screens or other
/// UI-related actions.
class IPadViewMenu extends IPadMenu {
  /// Native menu identifier mapped to the system "view" menu.
  @override
  String get menuId => 'view';

  /// Creates a view menu wiring the show-sidebar action and optional
  /// [additionalItems] to the given callbacks and intents.
  IPadViewMenu({
    VoidCallback? onShowSidebar,
    Intent? onShowSidebarIntent,
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'View',
         menus: [
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.sidebar_left,
             label: 'Show Sidebar',
             onSelected: onShowSidebar,
             onSelectedIntent: onShowSidebarIntent,
             shortcut: SingleActivator(
               LogicalKeyboardKey.keyS,
               shift: true, // Wrong key, I know...
               meta: true,
             ),
           ),
           ...?additionalItems,
         ],
       );
}
