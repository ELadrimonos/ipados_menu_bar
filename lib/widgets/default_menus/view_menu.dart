import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

class IPadViewMenu extends IPadMenu {
  @override
  String get menuId => 'view';

  IPadViewMenu({List<PlatformMenuItem>? additionalItems})
    : super(label: 'View', menus: [...?additionalItems]);
}
