import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

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
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.xmark, // Not same icon as iOS 26 :(
             label: 'Close Window',
             onSelectedIntent: onCloseWindowIntent,
             onSelected: onCloseWindow,
             shortcut: (onCloseWindow != null && onCloseWindowIntent == null)
                 ? SingleActivator(LogicalKeyboardKey.keyW, meta: true)
                 : null,
           ),
         ],
       );
}
