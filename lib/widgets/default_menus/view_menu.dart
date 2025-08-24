import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

class IPadViewMenu extends IPadMenu {
  @override
  String get menuId => 'view';

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
