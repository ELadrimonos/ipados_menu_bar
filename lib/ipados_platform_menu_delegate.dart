// Modificaciones para el archivo Dart (ipados_menu_bar.dart)

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/helpers/icon_converter.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

/// iPadOS exclusive channels
const String _kMenuSetMethod = 'Menu.setMenus';
const String _kMenuSelectedCallbackMethod = 'Menu.selectedCallback';
const String _kMenuItemOpenedMethod = 'Menu.opened';
const String _kMenuItemClosedMethod = 'Menu.closed';

/// Custom [PlatformMenuDelegate] adding support for menus on iOS, specifically
/// for the new iPadOS 26 menu bar.
class IPadOSPlatformMenuDelegate extends PlatformMenuDelegate {
  IPadOSPlatformMenuDelegate({MethodChannel? channel})
    : channel = channel ?? const MethodChannel('flutter/ipados_menu'),
      _idMap = <int, PlatformMenuItem>{} {
    this.channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel channel;
  final Map<int, PlatformMenuItem> _idMap;
  int _serial = 0;
  BuildContext? _lockedContext;

  // Track which default menus are present
  final Set<String> _presentDefaultMenus = <String>{};
  final Map<String, List<Map<String, Object?>>> _defaultMenuItems =
      <String, List<Map<String, Object?>>>{};

  @override
  void clearMenus() => setMenus(<PlatformMenuItem>[]);

  @override
  void setMenus(List<PlatformMenuItem> topLevelMenus) async {
    if (kDebugMode) {
      debugPrint(
        "IpadOSPlatformMenuDelegate.setMenus called with ${topLevelMenus.length} menus",
      );
    }

    _idMap.clear();
    _presentDefaultMenus.clear();
    _defaultMenuItems.clear();

    final List<Map<String, Object?>> customMenus = <Map<String, Object?>>[];

    if (topLevelMenus.isNotEmpty) {
      for (final PlatformMenuItem childItem in topLevelMenus) {
        if (kDebugMode) debugPrint("Processing menu: ${childItem.label}");

        if (childItem is IPadMenu) {
          _presentDefaultMenus.add(childItem.menuId);
          final menuItems = _getChildrenRepresentation(childItem.menus);
          await _processIconsAndSetMenus(menuItems);
          _defaultMenuItems[childItem.menuId] = menuItems;
          if (kDebugMode) debugPrint("Found default menu: ${childItem.menuId}");
        } else {
          final customMenuItems = _customToChannelRepresentation(childItem);
          await _processIconsAndSetMenus(customMenuItems);
          customMenus.addAll(customMenuItems);
        }
      }
    }

    final Map<String, Object?> payload = <String, Object?>{
      'customMenus': customMenus,
      'defaultMenus': _presentDefaultMenus.toList(),
      'defaultMenuItems': _defaultMenuItems,
    };

    if (kDebugMode) {
      debugPrint("Sending menu payload with processed icons and shortcuts");
    }

    channel.invokeMethod<void>(_kMenuSetMethod, payload);
  }

  List<Map<String, Object?>> _getChildrenRepresentation(
    List<PlatformMenuItem> items,
  ) {
    final List<Map<String, Object?>> result = <Map<String, Object?>>[];
    for (final PlatformMenuItem item in items) {
      result.addAll(_customToChannelRepresentation(item));
    }
    return result;
  }

  int _getId(PlatformMenuItem item) {
    _serial += 1;
    _idMap[_serial] = item;
    return _serial;
  }

  List<Map<String, Object?>> _customToChannelRepresentation(
    PlatformMenuItem item,
  ) {
    final List<Map<String, Object?>> result = [];

    if (item is PlatformMenu) {
      final List<Map<String, Object?>> children = [];
      for (final child in item.menus) {
        children.addAll(_customToChannelRepresentation(child));
      }

      result.add({
        'id': _getId(item),
        'label': item.label,
        'enabled': true,
        'children': children,
        'iconData': (item is PlatformMenuWithIcon) ? item.icon : null,
        'shortcut': _extractShortcut(item.shortcut),
      });
    } else if (item is PlatformMenuItemGroup) {
      final List<Map<String, Object?>> groupChildren = [];
      for (final member in item.members) {
        groupChildren.addAll(_customToChannelRepresentation(member));
      }
      result.add({'type': 'group', 'children': groupChildren});
    } else {
      final bool enabled =
          item.onSelected != null || item.onSelectedIntent != null;

      final Map<String, Object?> itemMap = {
        'id': _getId(item),
        'label': item.label,
        'enabled': enabled,
        'iconData': (item is PlatformMenuItemWithIcon) ? item.icon : null,
        'shortcut': _extractShortcut(item.shortcut),
      };

      if (item.members.isNotEmpty) {
        final List<Map<String, Object?>> children = [];
        for (final child in item.members) {
          children.addAll(_customToChannelRepresentation(child));
        }
        itemMap['children'] = children;
      }

      result.add(itemMap);
    }

    return result;
  }

  Map<String, Object?>? _extractShortcut(MenuSerializableShortcut? shortcut) {
    if (shortcut == null) {
      return null;
    }

    if (shortcut is SingleActivator) {
      return {
        'trigger': shortcut.trigger.keyLabel.toLowerCase(),
        'modifiers': _extractModifiers(shortcut),
      };
    } else if (shortcut is CharacterActivator) {
      return {
        'trigger': shortcut.character.toLowerCase(),
        'modifiers': <String>[],
      };
    }

    return null;
  }

  List<String> _extractModifiers(SingleActivator activator) {
    final List<String> modifiers = [];

    if (activator.control) modifiers.add('control');
    if (activator.shift) modifiers.add('shift');
    if (activator.alt) modifiers.add('alt');
    if (activator.meta) modifiers.add('meta'); // Command key on macOS

    return modifiers;
  }

  // Process before sending anything
  Future<void> _processIconsAndSetMenus(
    List<Map<String, Object?>> menus,
  ) async {
    for (final menu in menus) {
      await _processIconsRecursively(menu);
    }
  }

  Future<void> _processIconsRecursively(Map<String, Object?> menuItem) async {
    // Procesar icono del item actual
    if (menuItem.containsKey('iconData') && menuItem['iconData'] != null) {
      final iconData = menuItem['iconData'] as IconData;

      final iconBytes = await IconConverter.iconToBytes(
        iconData,
        size: 54.0,
        color: CupertinoColors
            .black, // Use black color, will be adapted in Swift side
      );

      if (iconBytes != null) {
        menuItem['iconBytes'] = iconBytes;
      }
      // Remove the iconData dart instance, we now work with bytes
      menuItem.remove('iconData');
    }

    if (menuItem.containsKey('children')) {
      final children = menuItem['children'] as List<Map<String, Object?>>;
      for (final child in children) {
        await _processIconsRecursively(child);
      }
    }
  }

  @override
  bool debugLockDelegate(BuildContext context) {
    assert(() {
      if (_lockedContext != null && _lockedContext != context) {
        return false;
      }
      _lockedContext = context;
      return true;
    }());
    return true;
  }

  @override
  bool debugUnlockDelegate(BuildContext context) {
    assert(() {
      if (_lockedContext != null && _lockedContext != context) {
        return false;
      }
      _lockedContext = null;
      return true;
    }());
    return true;
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    if (kDebugMode) {
      debugPrint(
        "Method call received: ${call.method} with arguments: ${call.arguments}",
      );
    }

    final int id = call.arguments as int;
    if (!_idMap.containsKey(id)) {
      if (kDebugMode) debugPrint('Menu event for unknown id $id');
      return;
    }

    final PlatformMenuItem item = _idMap[id]!;
    if (kDebugMode) debugPrint("Found menu item: ${item.label}");

    switch (call.method) {
      case _kMenuSelectedCallbackMethod:
        if (kDebugMode) debugPrint("Executing onSelected for: ${item.label}");
        item.onSelected?.call();
        if (item.onSelectedIntent != null) {
          final BuildContext? context =
              _lockedContext ?? FocusManager.instance.primaryFocus?.context;
          if (context != null) {
            Actions.maybeInvoke(context, item.onSelectedIntent!);
          }
        }
        break;
      case _kMenuItemOpenedMethod:
        item.onOpen?.call();
        break;
      case _kMenuItemClosedMethod:
        item.onClose?.call();
        break;
      default:
        if (kDebugMode) debugPrint('Unknown menu method: ${call.method}');
    }
  }

  // Legacy method kept for compatibility - now deprecated
  @Deprecated('Use DefaultPlatformMenu classes in the widget tree instead')
  Future<void> configureDefaultMenus(Map<String, dynamic> config) async {
    if (kDebugMode) {
      debugPrint(
        'configureDefaultMenus is deprecated. Use DefaultPlatformMenu classes instead.',
      );
    }
  }

  Future<Map<String, String>?> getAvailableDefaultMenus() async {
    try {
      final result = await channel.invokeMethod<Map<String, String>>(
        'Menu.getAvailableDefaultMenus',
      );
      return result;
    } catch (e) {
      if (kDebugMode) debugPrint('Error getting available default menus: $e');
      return null;
    }
  }
}
