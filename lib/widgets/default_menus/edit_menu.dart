import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

/// Custom [PlatformMenu] using a menuId to replace the native "edit" menu with
/// the items from this class. Making it easier and faster to link callbacks
/// from the app.
class IPadEditMenu extends IPadMenu {
  @override
  String get menuId => 'edit';

  IPadEditMenu({
    // Undo / Redo
    VoidCallback? onUndo,
    Intent? onUndoIntent,
    VoidCallback? onRedo,
    Intent? onRedoIntent,

    // Clipboard
    VoidCallback? onCut,
    Intent? onCutIntent,
    VoidCallback? onCopy,
    Intent? onCopyIntent,
    VoidCallback? onPaste,
    Intent? onPasteIntent,
    VoidCallback? onPasteStyle,
    Intent? onPasteStyleIntent,
    VoidCallback? onDelete,
    Intent? onDeleteIntent,
    VoidCallback? onSelectAll,
    Intent? onSelectAllIntent,

    // Find
    VoidCallback? onFind,
    Intent? onFindIntent,
    VoidCallback? onFindAndReplace,
    Intent? onFindAndReplaceIntent,
    VoidCallback? onFindNext,
    Intent? onFindNextIntent,
    VoidCallback? onFindPrevious,
    Intent? onFindPreviousIntent,
    VoidCallback? onUseSelectionForFind,
    Intent? onUseSelectionForFindIntent,

    // AutoFill
    VoidCallback? onAutoFillContact,
    Intent? onAutoFillContactIntent,
    VoidCallback? onAutoFillPasswords,
    Intent? onAutoFillPasswordsIntent,
    VoidCallback? onAutoFillCreditCard,
    Intent? onAutoFillCreditCardIntent,
    VoidCallback? onScanText,
    Intent? onScanTextIntent,

    // Others
    VoidCallback? onDictation,
    Intent? onDictationIntent,
    VoidCallback? onEmoji,
    Intent? onEmojiIntent,
    VoidCallback? onShowKeyboard,
    Intent? onShowKeyboardIntent,

    // Additional
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'Edit',
         menus: [
           PlatformMenuItemGroup(
             members: [
               PlatformMenuItemWithIcon(
                 icon: CupertinoIcons.arrow_uturn_left,
                 label: 'Undo',
                 onSelected: onUndo,
                 onSelectedIntent: onUndoIntent,
                 shortcut: SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
               ),
               PlatformMenuItemWithIcon(
                 icon: CupertinoIcons.arrow_uturn_right,
                 label: 'Redo',
                 onSelected: onRedo,
                 onSelectedIntent: onRedoIntent,
                 shortcut: SingleActivator(
                   LogicalKeyboardKey.keyZ,
                   meta: true,
                   shift: true,
                 ),
               ),
             ],
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.scissors,
             label: 'Cut',
             onSelected: onCut,
             onSelectedIntent: onCutIntent,
             shortcut: SingleActivator(LogicalKeyboardKey.keyX, meta: true),
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_doc,
             label: 'Copy',
             onSelected: onCopy,
             onSelectedIntent: onCopyIntent,
             shortcut: SingleActivator(LogicalKeyboardKey.keyC, meta: true),
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_clipboard,
             label: 'Paste',
             onSelected: onPaste,
             onSelectedIntent: onPasteIntent,
             shortcut: SingleActivator(LogicalKeyboardKey.keyV, meta: true),
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_clipboard_fill,
             label: 'Paste with the same style',
             onSelected: onPasteStyle,
             onSelectedIntent: onPasteStyleIntent,
             shortcut: SingleActivator(
               LogicalKeyboardKey.keyZ,
               meta: true,
               alt: true,
               shift: true,
             ),
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.trash,
             label: 'Delete',
             onSelected: onDelete,
             onSelectedIntent: onDeleteIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.textbox,
             label: 'Select All',
             onSelected: onSelectAll,
             onSelectedIntent: onSelectAllIntent,
             shortcut: SingleActivator(LogicalKeyboardKey.keyA, meta: true),
           ),

           /// Additional items go in between the "actions" items and the "find"
           /// items
           PlatformMenuItemGroup(members: [...?additionalItems]),
           PlatformMenuItemGroup(
             members: [
               PlatformMenuWithIcon(
                 icon: CupertinoIcons.doc_text_search,
                 label: 'Find',
                 menus: [
                   PlatformMenuItemGroup(
                     members: [
                       PlatformMenuItem(
                         label: 'Find',
                         onSelected: onFind,
                         onSelectedIntent: onFindIntent,
                         shortcut: SingleActivator(
                           LogicalKeyboardKey.keyF,
                           meta: true,
                         ),
                       ),
                       PlatformMenuItem(
                         label: 'Find & Replace',
                         onSelected: onFindAndReplace,
                         onSelectedIntent: onFindAndReplaceIntent,
                       ),
                       PlatformMenuItem(
                         label: 'Find Next',
                         onSelected: onFindNext,
                         onSelectedIntent: onFindNextIntent,
                         shortcut: SingleActivator(
                           LogicalKeyboardKey.keyG,
                           meta: true,
                         ),
                       ),
                       PlatformMenuItem(
                         label: 'Find Previous',
                         onSelected: onFindPrevious,
                         onSelectedIntent: onFindPreviousIntent,
                         shortcut: SingleActivator(
                           LogicalKeyboardKey.keyG,
                           meta: true,
                           shift: true,
                         ),
                       ),
                     ],
                   ),
                   PlatformMenuItem(
                     label: 'Use Selection to Find',
                     onSelected: onUseSelectionForFind,
                     onSelectedIntent: onUseSelectionForFindIntent,
                     shortcut: SingleActivator(
                       LogicalKeyboardKey.keyE,
                       meta: true,
                     ),
                   ),
                 ],
               ),
             ],
           ),
           PlatformMenuWithIcon(
             icon: CupertinoIcons.pencil_ellipsis_rectangle,
             label: 'AutoFill',
             menus: [
               PlatformMenuItemGroup(
                 members: [
                   PlatformMenuItemWithIcon(
                     icon: CupertinoIcons.person_circle,
                     label: 'Contact',
                     onSelected: onAutoFillContact,
                     onSelectedIntent: onAutoFillContactIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     icon: CupertinoIcons.lock_circle,
                     label: 'Passwords',
                     onSelected: onAutoFillPasswords,
                     onSelectedIntent: onAutoFillPasswordsIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     icon: CupertinoIcons.creditcard,
                     label: 'Credit Card',
                     onSelected: onAutoFillCreditCard,
                     onSelectedIntent: onAutoFillCreditCardIntent,
                   ),
                 ],
               ),
               PlatformMenuItemWithIcon(
                 icon: CupertinoIcons.doc_text_viewfinder,
                 label: 'Scan Text',
                 onSelected: onScanText,
                 onSelectedIntent: onScanTextIntent,
               ),
             ],
           ),

           // SingleActivator doesn't have a FN modificator, so dictation and
           // emoji won't have shortcut for now. I might make a custom classed
           // based on ShortcutActivator that allows the "planet" key as a
           // modificator.
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.mic,
             label: 'Dictation',
             onSelected: onDictation,
             onSelectedIntent: onDictationIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.smiley,
             label: 'Emoji',
             onSelected: onEmoji,
             onSelectedIntent: onEmojiIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.keyboard,
             label: 'Show Keyboard',
             onSelected: onShowKeyboard,
             onSelectedIntent: onShowKeyboardIntent,
           ),
         ],
       );
}
