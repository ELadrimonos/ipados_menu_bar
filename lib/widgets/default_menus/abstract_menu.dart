import 'package:flutter/cupertino.dart';

abstract class IPadMenu extends PlatformMenu {
  IPadMenu({required super.label, required super.menus});

  String get menuId;
}
