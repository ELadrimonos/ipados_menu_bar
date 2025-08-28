part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to replace the native "file" menu with
/// the items from this class. Making it easier and faster to link callbacks
/// from the app.
class IPadFileMenu extends IPadMenu {
  @override
  String get menuId => 'file';

  IPadFileMenu({
    VoidCallback? onCloseWindow,
    Intent? onCloseWindowIntent,
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'File',
         menus: [
           ...?additionalItems,
           /* Should be logic only, don't render this item in the future */
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.xmark,
             label: 'Close Window',
             onSelectedIntent: onCloseWindowIntent,
             onSelected: onCloseWindow,
             shortcut: SingleActivator(LogicalKeyboardKey.keyW, meta: true),
           ),
         ],
       );
}
