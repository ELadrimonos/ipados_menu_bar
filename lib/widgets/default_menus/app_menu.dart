part of '../../ipados_menu_bar.dart';

class IPadAppMenu extends IPadMenu {
  @override
  String get menuId => 'application';

  IPadAppMenu({List<PlatformMenuItem>? additionalItems})
      : super(label: 'App Info', menus: [...?additionalItems]);
}