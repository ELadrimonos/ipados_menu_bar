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
/// for the new iPadOS 26 menu bar with multi-scene support.
class IPadOSPlatformMenuDelegate extends PlatformMenuDelegate {
  IPadOSPlatformMenuDelegate({MethodChannel? channel})
    : channel = channel ?? const MethodChannel('flutter/ipados_menu'),
      _idMap = <int, PlatformMenuItem>{} {
    this.channel.setMethodCallHandler(_methodCallHandler);
    _setupLifecycleObserver();
  }

  final MethodChannel channel;
  final Map<int, PlatformMenuItem> _idMap;
  int _serial = 0;
  BuildContext? _lockedContext;

  final Set<String> _presentDefaultMenus = <String>{};
  final Map<String, List<Map<String, Object?>>> _defaultMenuItems =
      <String, List<Map<String, Object?>>>{};
  String? _currentEntrypoint;
  final List<Map<String, Object?>> _presentCustomMenus =
      <Map<String, Object?>>[];

  late final String _sceneId = _generateSceneId();
  bool _isActive = false;

  String _generateSceneId() {
    return 'scene_${DateTime.now().millisecondsSinceEpoch}_${_serial}';
  }

  void _setupLifecycleObserver() {
    WidgetsBinding.instance.addObserver(_LifecycleObserver(this));
  }

  void _markAsActive() {
    if (!_isActive) {
      _isActive = true;
      if (kDebugMode) {
        debugPrint("[$_sceneId] Scene marked as active");
      }
      // Reenviar menús cuando la escena se vuelve activa
      _resendCurrentMenus();
    }
  }

  void _markAsInactive() {
    if (_isActive) {
      _isActive = false;
      if (kDebugMode) {
        debugPrint("[$_sceneId] Scene marked as inactive");
      }
    }
  }

  // CAMBIO: Reenviar menús actuales sin limpiar el estado
  void _resendCurrentMenus() {
    if (_presentDefaultMenus.isNotEmpty || _defaultMenuItems.isNotEmpty) {
      if (kDebugMode) {
        debugPrint("[$_sceneId] Resending current menus on activation");
      }

      final Map<String, Object?> payload = <String, Object?>{
        'customMenus': _presentCustomMenus.toList(),
        'defaultMenus': _presentDefaultMenus.toList(),
        'defaultMenuItems': _defaultMenuItems,
        'windowEntrypoint': _currentEntrypoint,
        'sceneId': _sceneId, // CAMBIO: Incluir ID de escena
      };

      channel.invokeMethod<void>(_kMenuSetMethod, payload);
    }
  }

  @override
  void clearMenus() => setMenus(<PlatformMenuItem>[]);

  @override
  void setMenus(List<PlatformMenuItem> topLevelMenus) async {
    if (kDebugMode) {
      debugPrint("[$_sceneId] Setting menus (count: ${topLevelMenus.length})");
    }

    final Set<int> newIds = <int>{};

    _presentDefaultMenus.clear();
    _defaultMenuItems.clear();
    _presentCustomMenus.clear(); // 👈 limpiar antes de reconstruir
    _currentEntrypoint = null;

    final List<Map<String, Object?>> customMenus = <Map<String, Object?>>[];

    if (topLevelMenus.isNotEmpty) {
      for (final PlatformMenuItem childItem in topLevelMenus) {
        if (childItem is IPadMenu) {
          _presentDefaultMenus.add(childItem.menuId);
          final menuItems = _getChildrenRepresentation(childItem.menus);
          await _processIconsAndSetMenus(menuItems);
          _defaultMenuItems[childItem.menuId] = menuItems;

          _collectIds(menuItems, newIds);

          if (childItem is IPadWindowMenu && childItem.entrypoint != null) {
            _currentEntrypoint = childItem.entrypoint;
            if (kDebugMode) {
              debugPrint("[$_sceneId] Found window menu with entrypoint: ${childItem.entrypoint}");
            }
          }
        } else {
          final customMenuItems = _customToChannelRepresentation(childItem);
          await _processIconsAndSetMenus(customMenuItems);
          customMenus.addAll(customMenuItems);
          _collectIds(customMenuItems, newIds);
        }
      }
    }

    _presentCustomMenus.addAll(customMenus);

    _idMap.removeWhere((id, _) => !newIds.contains(id));

    final Map<String, Object?> payload = <String, Object?>{
      'customMenus': _presentCustomMenus,
      'defaultMenus': _presentDefaultMenus.toList(),
      'defaultMenuItems': _defaultMenuItems,
      'windowEntrypoint': _currentEntrypoint,
      'sceneId': _sceneId,
    };

    if (kDebugMode) {
      debugPrint("[$_sceneId] Sending menu payload with entrypoint: $_currentEntrypoint");
    }

    _isActive = true;
    channel.invokeMethod<void>(_kMenuSetMethod, payload);
  }

  void _collectIds(List<Map<String, Object?>> items, Set<int> idSet) {
    for (final item in items) {
      if (item['id'] != null) {
        idSet.add(item['id'] as int);
      }
      if (item['children'] != null) {
        _collectIds(item['children'] as List<Map<String, Object?>>, idSet);
      }
    }
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

  /// Transforms our flutter widgets into a data map for swift
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

      if (item is StatefulMenuItem) {
        itemMap['state'] = (item as StatefulMenuItem).state.name;
      }

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
    if (activator.meta) modifiers.add('meta');

    return modifiers;
  }

  Future<void> _processIconsAndSetMenus(
    List<Map<String, Object?>> menus,
  ) async {
    for (final menu in menus) {
      await _processIconsRecursively(menu);
    }
  }

  Future<void> _processIconsRecursively(Map<String, Object?> menuItem) async {
    if (menuItem.containsKey('iconData') && menuItem['iconData'] != null) {
      final iconData = menuItem['iconData'] as IconData;

      final iconBytes = await IconConverter.iconToBytes(
        iconData,
        size: 54.0,
        color: CupertinoColors.black,
      );

      if (iconBytes != null) {
        menuItem['iconBytes'] = iconBytes;
      }
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
        "[$_sceneId] Method call received: ${call.method} with arguments: ${call.arguments}",
      );
    }

    final int id = call.arguments as int;
    if (!_idMap.containsKey(id)) {
      if (kDebugMode) debugPrint('[$_sceneId] Menu event for unknown id $id');
      return;
    }

    final PlatformMenuItem item = _idMap[id]!;

    switch (call.method) {
      case _kMenuSelectedCallbackMethod:
        if (kDebugMode) {
          debugPrint("[$_sceneId] Executing onSelected for: ${item.label}");
        }
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
        if (kDebugMode) {
          debugPrint('[$_sceneId] Unknown menu method: ${call.method}');
        }
    }
  }

  Future<Map<String, String>?> getAvailableDefaultMenus() async {
    try {
      final result = await channel.invokeMethod<Map<String, String>>(
        'Menu.getAvailableDefaultMenus',
      );
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[$_sceneId] Error getting available default menus: $e');
      }
      return null;
    }
  }

  void dispose() {
    _isActive = false;
    if (kDebugMode) {
      debugPrint("[$_sceneId] Delegate disposed");
    }
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final IPadOSPlatformMenuDelegate delegate;

  _LifecycleObserver(this.delegate);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        delegate._markAsActive();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        delegate._markAsInactive();
        break;
      case AppLifecycleState.detached:
        delegate.dispose();
        break;
      case AppLifecycleState.hidden:
        delegate._markAsInactive();
        break;
    }
  }
}
