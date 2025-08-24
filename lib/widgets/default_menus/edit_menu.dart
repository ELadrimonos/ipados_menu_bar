import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

// TODO: Shortcuts & Emojis
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
               ),
               PlatformMenuItemWithIcon(
                 icon: CupertinoIcons.arrow_uturn_right,
                 label: 'Redo',
                 onSelected: onRedo,
                 onSelectedIntent: onRedoIntent,
               ),
             ],
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.scissors,
             label: 'Cut',
             onSelected: onCut,
             onSelectedIntent: onCutIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_doc,
             label: 'Copy',
             onSelected: onCopy,
             onSelectedIntent: onCopyIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_clipboard,
             label: 'Paste',
             onSelected: onPaste,
             onSelectedIntent: onPasteIntent,
           ),
           PlatformMenuItemWithIcon(
             icon: CupertinoIcons.doc_on_clipboard_fill,
             label: 'Paste with the same style',
             onSelected: onPasteStyle,
             onSelectedIntent: onPasteStyleIntent,
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
           ),
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
                       ),
                       PlatformMenuItem(
                         label: 'Find Previous',
                         onSelected: onFindPrevious,
                         onSelectedIntent: onFindPreviousIntent,
                       ),
                     ],
                   ),
                   PlatformMenuItem(
                     label: 'Use Selection for Find',
                     onSelected: onUseSelectionForFind,
                     onSelectedIntent: onUseSelectionForFindIntent,
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
