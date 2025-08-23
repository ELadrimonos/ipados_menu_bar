import 'package:flutter/cupertino.dart';

abstract class DefaultIpadMenu extends PlatformMenu {
  DefaultIpadMenu({required super.label, required super.menus});

  String get menuId;
}