import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

class IPadFormatMenu extends IPadMenu {
  @override
  String get menuId => 'format';

  IPadFormatMenu({List<PlatformMenuItem>? additionalItems})
    : super(
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
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Italic',
                    icon: CupertinoIcons.italic,
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Underline',
                    icon: CupertinoIcons.underline,
                  ),
                ],
              ),
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItemWithIcon(
                    label: 'Bigger',
                    icon: CupertinoIcons.textformat_superscript,
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Smaller',
                    icon: CupertinoIcons.textformat_subscript,
                  ),
                ],
              ),
            ],
          ),
          PlatformMenuWithIcon(
            icon: CupertinoIcons.text_alignleft,
            label: 'Text',
            menus: [
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItemWithIcon(
                    label: 'Bold',
                    icon: CupertinoIcons.bold,
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Italic',
                    icon: CupertinoIcons.italic,
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Underline',
                    icon: CupertinoIcons.underline,
                  ),
                ],
              ),
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItemWithIcon(
                    label: 'Bigger',
                    icon: CupertinoIcons.textformat_superscript,
                  ),
                  PlatformMenuItemWithIcon(
                    label: 'Smaller',
                    icon: CupertinoIcons.textformat_subscript,
                  ),
                ],
              ),
            ],
          ),

          ...?additionalItems,
        ],
      );
}
