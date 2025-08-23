import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

// TODO Emojis
class DefaultFileMenu extends PlatformMenu {
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
