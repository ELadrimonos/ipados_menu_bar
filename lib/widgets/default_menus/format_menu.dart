import 'package:flutter/cupertino.dart';
import 'package:ipados_menu_bar/widgets/default_menus/abstract_menu.dart';

//TODO Cambiar en el constructor a additionalItems y poner unos items por defecto
class DefaultFormatMenu extends DefaultIpadMenu {

  @override
  String get menuId => 'format';

  DefaultFormatMenu({required super.label, required super.menus});
}
