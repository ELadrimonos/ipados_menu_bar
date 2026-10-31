import 'package:pigeon/pigeon.dart';

/// Pigeon definition of the channel between Dart and the iPadOS plugin.
///
/// Regenerate with:
/// `dart run pigeon --input pigeons/menu_api.dart`
///
/// Swift output goes to `ios/Classes`; copy it to
/// `ios/ipados_menu_bar/Sources/ipados_menu_bar` to keep SPM in sync.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    swiftOut: 'ios/Classes/Messages.g.swift',
    dartPackageName: 'ipados_menu_bar',
  ),
)
/// Modifier keys of a keyboard shortcut.
enum NativeMenuModifier { shift, control, alt, meta }

/// Check state of a menu item, mirrors `UIMenuElement.State`.
enum NativeMenuState { on, off, mixed }

class NativeShortcut {
  NativeShortcut({required this.trigger, required this.modifiers});

  String trigger;
  List<NativeMenuModifier> modifiers;
}

/// A menu, submenu, group or item. Groups only use [children].
class NativeMenuItem {
  NativeMenuItem({
    this.id,
    this.label,
    this.enabled = true,
    this.isGroup = false,
    this.children = const <NativeMenuItem>[],
    this.iconBytes,
    this.shortcut,
    this.state,
  });

  int? id;
  String? label;
  bool enabled;
  bool isGroup;
  List<NativeMenuItem> children;
  Uint8List? iconBytes;
  NativeShortcut? shortcut;
  NativeMenuState? state;
}

class NativeMenuConfiguration {
  NativeMenuConfiguration({
    required this.customMenus,
    required this.defaultMenus,
    required this.defaultMenuItems,
  });

  List<NativeMenuItem> customMenus;
  List<String> defaultMenus;
  Map<String, List<NativeMenuItem>> defaultMenuItems;
}

@HostApi()
abstract class IpadOSMenuHostApi {
  void setMenus(NativeMenuConfiguration configuration);

  Map<String, String> getAvailableDefaultMenus();
}

@FlutterApi()
abstract class IpadOSMenuFlutterApi {
  void menuSelected(int id);

  void menuOpened(int id);

  void menuClosed(int id);
}
