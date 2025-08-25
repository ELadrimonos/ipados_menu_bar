part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to replace the native "format" menu with
/// the items from this class. Making it easier and faster to link callbacks
/// from the app.
class IPadFormatMenu extends IPadMenu {
  @override
  String get menuId => 'format';

  IPadFormatMenu({
    // Font
    VoidCallback? onBold,
    Intent? onBoldIntent,
    VoidCallback? onItalic,
    Intent? onItalicIntent,
    VoidCallback? onUnderline,
    Intent? onUnderlineIntent,

    // Size
    VoidCallback? onBigger,
    Intent? onBiggerIntent,
    VoidCallback? onSmaller,
    Intent? onSmallerIntent,

    // Text Align
    VoidCallback? onAlignLeft,
    Intent? onAlignLeftIntent,
    VoidCallback? onCenter,
    Intent? onCenterIntent,
    VoidCallback? onJustify,
    Intent? onJustifyIntent,
    VoidCallback? onAlignRight,
    Intent? onAlignRightIntent,

    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'Format',
         menus: [
           PlatformMenuWithIcon(
             icon: CupertinoIcons.textformat,
             label: 'Font',
             menus: [
               PlatformMenuItemGroup(
                 members: [
                   PlatformMenuItemWithIcon(
                     label: 'Bold',
                     icon: CupertinoIcons.bold,
                     onSelected: onBold,
                     onSelectedIntent: onBoldIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Italic',
                     icon: CupertinoIcons.italic,
                     onSelected: onItalic,
                     onSelectedIntent: onItalicIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Underline',
                     icon: CupertinoIcons.underline,
                     onSelected: onUnderline,
                     onSelectedIntent: onUnderlineIntent,
                   ),
                 ],
               ),
               PlatformMenuItemGroup(
                 members: [
                   PlatformMenuItemWithIcon(
                     label: 'Bigger',
                     icon: CupertinoIcons.textformat_superscript,
                     onSelected: onBigger,
                     onSelectedIntent: onBiggerIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Smaller',
                     icon: CupertinoIcons.textformat_subscript,
                     onSelected: onSmaller,
                     onSelectedIntent: onSmallerIntent,
                   ),
                 ],
               ),
             ],
           ),
           PlatformMenuWithIcon(
             icon: CupertinoIcons.text_alignleft,
             label: 'Text',
             menus: [
               PlatformMenuItemWithIcon(
                 label: 'Align Left',
                 icon: CupertinoIcons.text_alignleft,
                 onSelected: onAlignLeft,
                 onSelectedIntent: onAlignLeftIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Center',
                 icon: CupertinoIcons.text_aligncenter,
                 onSelected: onCenter,
                 onSelectedIntent: onCenterIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Justify',
                 icon: CupertinoIcons.text_justify,
                 onSelected: onJustify,
                 onSelectedIntent: onJustifyIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Align Right',
                 icon: CupertinoIcons.text_alignright,
                 onSelected: onAlignRight,
                 onSelectedIntent: onAlignRightIntent,
               ),
             ],
           ),
           ...?additionalItems,
         ],
       );
}
