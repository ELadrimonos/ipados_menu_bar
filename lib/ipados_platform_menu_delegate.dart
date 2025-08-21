import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'apple_default_menu_items_enum.dart';

/// iPadOS exclusive channels
const String _kMenuSetMethod = 'Menu.setMenus';
const String _kMenuSelectedCallbackMethod = 'Menu.selectedCallback';
const String _kMenuItemOpenedMethod = 'Menu.opened';
const String _kMenuItemClosedMethod = 'Menu.closed';

// TODO Access the default items as PlatformMenu widgets and customize them
//  using a dictionary with their IDs and allow
//  linking default menu items to actions inside dart code

// TODO Place custom menus between View and Format, following Apple's Design Guidelines
// link: https://developer.apple.com/videos/play/wwdc2025/208/?time=648

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
    print(
      "IpadOSPlatformMenuDelegate.setMenus called with ${topLevelMenus.length} menus",
    );

    _idMap.clear();
    final List<Map<String, Object?>> representation = <Map<String, Object?>>[];

    if (topLevelMenus.isNotEmpty) {
      for (final PlatformMenuItem childItem in topLevelMenus) {
        print("Processing menu: ${childItem.label}");
        representation.addAll(
          childItem.toChannelRepresentation(this, getId: _getId),
        );
      }
    }

    final Map<String, Object?> windowMenu = <String, Object?>{
      '0': representation,
    };
    print("Sending menu representation: $windowMenu");
    channel.invokeMethod<void>(_kMenuSetMethod, windowMenu);
  }

  int _getId(PlatformMenuItem item) {
    _serial += 1;
    _idMap[_serial] = item;
    return _serial;
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
    print(
      "Method call received: ${call.method} with arguments: ${call.arguments}",
    );

    final int id = call.arguments as int;
    if (!_idMap.containsKey(id)) {
      print('Menu event for unknown id $id');
      return;
    }

    final PlatformMenuItem item = _idMap[id]!;
    print("Found menu item: ${item.label}");

    switch (call.method) {
      case _kMenuSelectedCallbackMethod:
        print("Executing onSelected for: ${item.label}");
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
        print('Unknown menu method: ${call.method}');
    }
  }

  Future<void> configureDefaultMenus(Map<String, dynamic> config) async {
    try {
      await channel.invokeMethod<void>('Menu.configureDefaultMenus', config);
    } catch (e) {
      debugPrint('Error configuring default menus: $e');
    }
  }

  Future<Map<String, String>?> getAvailableDefaultMenus() async {
    try {
      final result = await channel.invokeMethod<Map<String, String>>(
        'Menu.getAvailableDefaultMenus',
      );
      return result;
    } catch (e) {
      debugPrint('Error getting available default menus: $e');
      return null;
    }
  }
}
