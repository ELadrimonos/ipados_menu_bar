part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] using a menuId to replace the native "format" menu with
/// the items from this class. Making it easier and faster to link callbacks
/// from the app.
class IPadFormatMenu extends IPadMenu {
  /// Native menu identifier mapped to the system "format" menu.
  @override
  String get menuId => 'format';

  /// Creates a format menu wiring font, size, text-alignment and optional
  /// [additionalItems] to the given callbacks and intents.
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
             icon: _MenuIcons.textformat,
             label: 'Font',
             menus: [
               PlatformMenuItemGroup(
                 members: [
                   PlatformMenuItemWithIcon(
                     label: 'Bold',
                     icon: _MenuIcons.bold,
                     onSelected: onBold,
                     onSelectedIntent: onBoldIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Italic',
                     icon: _MenuIcons.italic,
                     onSelected: onItalic,
                     onSelectedIntent: onItalicIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Underline',
                     icon: _MenuIcons.underline,
                     onSelected: onUnderline,
                     onSelectedIntent: onUnderlineIntent,
                   ),
                 ],
               ),
               PlatformMenuItemGroup(
                 members: [
                   PlatformMenuItemWithIcon(
                     label: 'Bigger',
                     icon: _MenuIcons.textformatSuperscript,
                     onSelected: onBigger,
                     onSelectedIntent: onBiggerIntent,
                   ),
                   PlatformMenuItemWithIcon(
                     label: 'Smaller',
                     icon: _MenuIcons.textformatSubscript,
                     onSelected: onSmaller,
                     onSelectedIntent: onSmallerIntent,
                   ),
                 ],
               ),
             ],
           ),
           PlatformMenuWithIcon(
             icon: _MenuIcons.textAlignleft,
             label: 'Text',
             menus: [
               PlatformMenuItemWithIcon(
                 label: 'Align Left',
                 icon: _MenuIcons.textAlignleft,
                 onSelected: onAlignLeft,
                 onSelectedIntent: onAlignLeftIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Center',
                 icon: _MenuIcons.textAligncenter,
                 onSelected: onCenter,
                 onSelectedIntent: onCenterIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Justify',
                 icon: _MenuIcons.textJustify,
                 onSelected: onJustify,
                 onSelectedIntent: onJustifyIntent,
               ),
               PlatformMenuItemWithIcon(
                 label: 'Align Right',
                 icon: _MenuIcons.textAlignright,
                 onSelected: onAlignRight,
                 onSelectedIntent: onAlignRightIntent,
               ),
             ],
           ),
           ...?additionalItems,
         ],
       );
}
