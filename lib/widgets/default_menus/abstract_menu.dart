part of '../../ipados_menu_bar.dart';

/// Abstract class for setting menus on iOS with a ***menuId*** to replace/access
/// native ones, while still working for other platforms as it extends from
/// [PlatformMenu].
abstract class IPadMenu extends PlatformMenu {
  /// Creates an [IPadMenu] with the given [label] and child [menus].
  IPadMenu({required super.label, required super.menus});

  /// Native menu identifier used to replace/access the corresponding system menu.
  String get menuId;
}
