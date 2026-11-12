import 'package:material_ui/material_ui.dart';

class MenuProvider extends ChangeNotifier {
  List<PlatformMenu> _currentMenus = [];

  List<PlatformMenu> get currentMenus => _currentMenus;

  void setMenus(List<PlatformMenu> menus) {
    _currentMenus = menus;
    notifyListeners();
  }
}
