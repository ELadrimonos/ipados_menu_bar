import 'package:flutter/cupertino.dart';

/// Abstract class for setting menus on iOS with a ***menuId*** to replace/access
/// native ones, while still working for other platforms as it extends from
/// [PlatformMenu].
abstract class IPadMenu extends PlatformMenu {
  IPadMenu({required super.label, required super.menus});

  String get menuId;
}
