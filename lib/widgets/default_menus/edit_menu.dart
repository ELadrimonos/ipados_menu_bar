import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

// TODO: Shortcuts & Emojis
class DefaultEditMenu extends DefaultIpadMenu {
  DefaultEditMenu({
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
          PlatformMenuItem(
            label: 'Undo',
            onSelected: onUndo,
            onSelectedIntent: onUndoIntent,
          ),
          PlatformMenuItem(
            label: 'Redo',
            onSelected: onRedo,
            onSelectedIntent: onRedoIntent,
          ),
        ],
      ),
      PlatformMenuItem(
        label: 'Cut',
        onSelected: onCut,
        onSelectedIntent: onCutIntent,
      ),
      PlatformMenuItem(
        label: 'Copy',
        onSelected: onCopy,
        onSelectedIntent: onCopyIntent,
      ),
      PlatformMenuItem(
        label: 'Paste',
        onSelected: onPaste,
        onSelectedIntent: onPasteIntent,
      ),
      PlatformMenuItem(
        label: 'Paste with the same style',
        onSelected: onPasteStyle,
        onSelectedIntent: onPasteStyleIntent,
      ),
      PlatformMenuItem(
        label: 'Delete',
        onSelected: onDelete,
        onSelectedIntent: onDeleteIntent,
      ),
      PlatformMenuItem(
        label: 'Select All',
        onSelected: onSelectAll,
        onSelectedIntent: onSelectAllIntent,
      ),
      PlatformMenuItemGroup(
        members: [
          PlatformMenu(
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
      PlatformMenu(
        label: 'AutoFill',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Contact',
                onSelected: onAutoFillContact,
                onSelectedIntent: onAutoFillContactIntent,
              ),
              PlatformMenuItem(
                label: 'Passwords',
                onSelected: onAutoFillPasswords,
                onSelectedIntent: onAutoFillPasswordsIntent,
              ),
              PlatformMenuItem(
                label: 'Credit Card',
                onSelected: onAutoFillCreditCard,
                onSelectedIntent: onAutoFillCreditCardIntent,
              ),
            ],
          ),
          PlatformMenuItem(
            label: 'Scan Text',
            onSelected: onScanText,
            onSelectedIntent: onScanTextIntent,
          ),
        ],
      ),
      PlatformMenuItem(
        label: 'Dictation',
        onSelected: onDictation,
        onSelectedIntent: onDictationIntent,
      ),
      PlatformMenuItem(
        label: 'Emoji',
        onSelected: onEmoji,
        onSelectedIntent: onEmojiIntent,
      ),
      PlatformMenuItem(
        label: 'Show Keyboard',
        onSelected: onShowKeyboard,
        onSelectedIntent: onShowKeyboardIntent,
      ),
      ...?additionalItems,
    ],
  );
}