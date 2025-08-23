import 'package:flutter/cupertino.dart';

//TODO Shortcuts
class DefaultEditMenu extends PlatformMenu {
  DefaultEditMenu({
    VoidCallback? onUndo,
    Intent? onUndoIntent,
    VoidCallback? onRedo,
    VoidCallback? onCut,
    VoidCallback? onCopy,
    VoidCallback? onPaste,
    VoidCallback? onPasteStyle,
    VoidCallback? onDelete,
    VoidCallback? onSelectAll,
    VoidCallback? onFind,
    VoidCallback? onFindAndReplace,
    VoidCallback? onFindNext,
    VoidCallback? onFindPrevious,
    VoidCallback? onUseSelectionForFind,
    VoidCallback? onAutoFillContact,
    VoidCallback? onAutoFillPasswords,
    VoidCallback? onAutoFillCreditCard,
    VoidCallback? onScanText,
    VoidCallback? onDictation,
    VoidCallback? onEmoji,
    VoidCallback? onShowKeyboard,
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'Edit',
         menus: [
           PlatformMenuItemGroup(
             members: [
               PlatformMenuItem(
                 label: 'Undo',
                 onSelected: onUndo,
                 onSelectedIntent: onUndoIntent,
               ),
               PlatformMenuItem(label: 'Redo', onSelected: onRedo),
             ],
           ),
           PlatformMenuItem(label: 'Cut'),
           PlatformMenuItem(label: 'Copy'),
           PlatformMenuItem(label: 'Paste'),
           PlatformMenuItem(label: 'Paste with the same style'),
           PlatformMenuItem(label: 'Delete'),
           PlatformMenuItem(label: 'Select All'),
           PlatformMenuItemGroup(
             members: [
               PlatformMenu(
                 label: 'Find',
                 menus: [
                   PlatformMenuItemGroup(
                     members: [
                       PlatformMenuItem(label: 'Find'),
                       PlatformMenuItem(label: 'Find & Replace'),
                       PlatformMenuItem(label: 'Find Next'),
                       PlatformMenuItem(label: 'Find Previous'),
                     ],
                   ),
                   PlatformMenuItem(label: 'Use Selection for Find')
                 ],
               ),
             ],
           ),
           if (additionalItems != null) ...additionalItems,
         ],
       );
}
