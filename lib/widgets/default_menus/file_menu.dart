import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

// TODO Emojis
class DefaultFileMenu extends DefaultIpadMenu {
  @override
  String get menuId => 'file';

  DefaultFileMenu({
    VoidCallback? onCloseWindow,
    Intent? onCloseWindowIntent,
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'File',
         menus: [
           ...?additionalItems,
           PlatformMenuItem(
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
