import 'package:flutter/material.dart';

class MenuProvider extends ChangeNotifier {
  List<PlatformMenu> _currentMenus = [];

  List<PlatformMenu> get currentMenus => _currentMenus;

  void setMenus(List<PlatformMenu> menus) {
    _currentMenus = menus;
    notifyListeners();
  }
}
