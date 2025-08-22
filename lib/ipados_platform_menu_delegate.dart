import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/services.dart';

/// iPadOS exclusive channels
const String _kMenuSetMethod = 'Menu.setMenus';
const String _kMenuSelectedCallbackMethod = 'Menu.selectedCallback';
const String _kMenuItemOpenedMethod = 'Menu.opened';
const String _kMenuItemClosedMethod = 'Menu.closed';

// TODO Access the default items as PlatformMenu widgets and customize them
//  using a dictionary with their IDs and allow
//  linking default menu items to actions inside dart code
//  or just be able to assign callbacks using a predefined class

class IpadOSPlatformMenuDelegate extends PlatformMenuDelegate {
  IpadOSPlatformMenuDelegate({MethodChannel? channel})
    : channel = channel ?? const MethodChannel('flutter/ipados_menu'),
      _idMap = <int, PlatformMenuItem>{} {
    this.channel.setMethodCallHandler(_methodCallHandler);
  }

  final MethodChannel channel;
  final Map<int, PlatformMenuItem> _idMap;
  int _serial = 0;
  BuildContext? _lockedContext;

  @override
  void clearMenus() => setMenus(<PlatformMenuItem>[]);

  @override
  void setMenus(List<PlatformMenuItem> topLevelMenus) {
    if (kDebugMode) {
      debugPrint(
        "IpadOSPlatformMenuDelegate.setMenus called with ${topLevelMenus.length} menus",
      );
    }

    _idMap.clear();
    final List<Map<String, Object?>> representation = <Map<String, Object?>>[];

    if (topLevelMenus.isNotEmpty) {
      for (final PlatformMenuItem childItem in topLevelMenus) {
        if (kDebugMode) debugPrint("Processing menu: ${childItem.label}");
        representation.addAll(_customToChannelRepresentation(childItem));
      }
    }

    final Map<String, Object?> windowMenu = <String, Object?>{
      '0': representation,
    };
    if (kDebugMode) debugPrint("Sending menu representation: $windowMenu");
    channel.invokeMethod<void>(_kMenuSetMethod, windowMenu);
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
      });
    } else if (item is PlatformMenuItemGroup) {
      /// A group is traslated as "divider/group" in UIKit
      final List<Map<String, Object?>> groupChildren = [];
      for (final member in item.members) {
        groupChildren.addAll(_customToChannelRepresentation(member));
      }
      result.add({'type': 'group', 'children': groupChildren});
    } else {
      /// Disable item on native side if no method is passed
      final bool enabled =
          item.onSelected != null || item.onSelectedIntent != null;

      final Map<String, Object?> itemMap = {
        'id': _getId(item),
        'label': item.label,
        'enabled': enabled,
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

  Future<void> configureDefaultMenus(Map<String, dynamic> config) async {
    try {
      await channel.invokeMethod<void>('Menu.configureDefaultMenus', config);
    } catch (e) {
      if (kDebugMode) debugPrint('Error configuring default menus: $e');
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
