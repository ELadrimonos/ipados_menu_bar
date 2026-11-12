import 'dart:async';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, visibleForTesting;
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/helpers/icon_converter.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/src/messages.g.dart';

/// Custom [PlatformMenuDelegate] adding support for menus on iOS, specifically
/// for the new iPadOS 26 menu bar.
///
/// Use [IPadOSPlatformMenuDelegate.create] to instantiate this delegate.
/// The factory method ensures proper platform validation and automatically
/// falls back to [DefaultPlatformMenuDelegate] on non-iOS platforms.
///
/// Example:
/// ```dart
/// WidgetsBinding.instance.platformMenuDelegate =
///     IPadOSPlatformMenuDelegate.create();
/// ```
class IPadOSPlatformMenuDelegate extends PlatformMenuDelegate
    implements IpadOSMenuFlutterApi {
  /// Creates an instance of [IPadOSPlatformMenuDelegate] for iOS platforms,
  /// or [DefaultPlatformMenuDelegate] for other platforms.
  ///
  /// Optionally accepts a custom [binaryMessenger] for testing purposes.
  static PlatformMenuDelegate create({BinaryMessenger? binaryMessenger}) {
    if (defaultTargetPlatform != TargetPlatform.iOS) {
      return DefaultPlatformMenuDelegate();
    }
    return IPadOSPlatformMenuDelegate._internal(
      IpadOSMenuHostApi(binaryMessenger: binaryMessenger),
      binaryMessenger,
      <int, PlatformMenuItem>{},
    );
  }

  /// Internal constructor. Use [create] instead.
  IPadOSPlatformMenuDelegate._internal(
    this._hostApi,
    BinaryMessenger? binaryMessenger,
    this._idMap,
  ) {
    IpadOSMenuFlutterApi.setUp(this, binaryMessenger: binaryMessenger);
  }

  /// Creates a delegate that talks to `hostApi` without checking the platform.
  @visibleForTesting
  IPadOSPlatformMenuDelegate.forTesting(
    this._hostApi, {
    BinaryMessenger? binaryMessenger,
  }) : _idMap = <int, PlatformMenuItem>{} {
    IpadOSMenuFlutterApi.setUp(this, binaryMessenger: binaryMessenger);
  }

  final IpadOSMenuHostApi _hostApi;
  final Map<int, PlatformMenuItem> _idMap;
  int _serial = 0;
  BuildContext? _lockedContext;

  // Track which default menus are present
  final Set<String> _presentDefaultMenus = <String>{};
  final Map<String, List<NativeMenuItem>> _defaultMenuItems =
      <String, List<NativeMenuItem>>{};

  /// Removes all menus by setting an empty top-level menu list.
  @override
  void clearMenus() => setMenus(<PlatformMenuItem>[]);

  /// Serializes [topLevelMenus] and sends them to the native side, splitting
  /// them into default ([IPadMenu]) and custom menus.
  @override
  Future<void> setMenus(List<PlatformMenuItem> topLevelMenus) async {
    _idMap.clear();
    _presentDefaultMenus.clear();
    _defaultMenuItems.clear();

    final List<NativeMenuItem> customMenus = <NativeMenuItem>[];

    if (topLevelMenus.isNotEmpty) {
      for (final PlatformMenuItem childItem in topLevelMenus) {
        final pendingIcons = <(NativeMenuItem, Object)>[];
        if (childItem is IPadMenu) {
          _presentDefaultMenus.add(childItem.menuId);
          final menuItems = _getChildrenRepresentation(
            childItem.menus,
            pendingIcons,
          );
          await _processIcons(pendingIcons);
          _defaultMenuItems[childItem.menuId] = menuItems;
        } else {
          final customMenuItems = _customToChannelRepresentation(
            childItem,
            pendingIcons,
          );
          await _processIcons(pendingIcons);
          customMenus.addAll(customMenuItems);
        }
      }
    }

    await _hostApi.setMenus(
      NativeMenuConfiguration(
        customMenus: customMenus,
        defaultMenus: _presentDefaultMenus.toList(),
        defaultMenuItems: _defaultMenuItems,
      ),
    );
  }

  List<NativeMenuItem> _getChildrenRepresentation(
    List<PlatformMenuItem> items,
    List<(NativeMenuItem, Object)> pendingIcons,
  ) {
    final List<NativeMenuItem> result = <NativeMenuItem>[];
    for (final PlatformMenuItem item in items) {
      result.addAll(_customToChannelRepresentation(item, pendingIcons));
    }
    return result;
  }

  int _getId(PlatformMenuItem item) {
    _serial += 1;
    _idMap[_serial] = item;
    return _serial;
  }

  /// Transforms our flutter widgets into the data sent to swift.
  ///
  /// Icons are converted to bytes asynchronously, so the items that have one
  /// are added to [pendingIcons] to be processed by [_processIcons].
  List<NativeMenuItem> _customToChannelRepresentation(
    PlatformMenuItem item,
    List<(NativeMenuItem, Object)> pendingIcons,
  ) {
    final List<NativeMenuItem> result = [];

    if (item is PlatformMenu) {
      final List<NativeMenuItem> children = [];
      for (final child in item.menus) {
        children.addAll(_customToChannelRepresentation(child, pendingIcons));
      }

      final menu = NativeMenuItem(
        id: _getId(item),
        label: item.label,
        children: children,
        shortcut: _extractShortcut(item.shortcut),
      );
      final Object? icon = (item is PlatformMenuWithIcon)
          ? item.icon ?? item.iconWidget
          : null;
      if (icon != null) pendingIcons.add((menu, icon));
      result.add(menu);
    } else if (item is PlatformMenuItemGroup) {
      final List<NativeMenuItem> groupChildren = [];
      for (final member in item.members) {
        groupChildren.addAll(
          _customToChannelRepresentation(member, pendingIcons),
        );
      }
      result.add(NativeMenuItem(isGroup: true, children: groupChildren));
    } else {
      final bool enabled =
          item.onSelected != null || item.onSelectedIntent != null;

      final List<NativeMenuItem> children = [];
      for (final child in item.members) {
        children.addAll(_customToChannelRepresentation(child, pendingIcons));
      }

      final menuItem = NativeMenuItem(
        id: _getId(item),
        label: item.label,
        enabled: enabled,
        children: children,
        shortcut: _extractShortcut(item.shortcut),
        state: item is StatefulMenuItem
            ? NativeMenuState.values.byName(
                (item as StatefulMenuItem).state.name,
              )
            : null,
      );
      final Object? icon = (item is PlatformMenuItemWithIcon)
          ? item.icon ?? item.iconWidget
          : null;
      if (icon != null) pendingIcons.add((menuItem, icon));
      result.add(menuItem);
    }

    return result;
  }

  NativeShortcut? _extractShortcut(MenuSerializableShortcut? shortcut) {
    if (shortcut == null) {
      return null;
    }

    if (shortcut is SingleActivator) {
      return NativeShortcut(
        trigger: shortcut.trigger.keyLabel.toLowerCase(),
        modifiers: _extractModifiers(shortcut),
      );
    } else if (shortcut is CharacterActivator) {
      return NativeShortcut(
        trigger: shortcut.character.toLowerCase(),
        modifiers: <NativeMenuModifier>[],
      );
    }

    return null;
  }

  List<NativeMenuModifier> _extractModifiers(SingleActivator activator) {
    final List<NativeMenuModifier> modifiers = [];

    if (activator.control) modifiers.add(NativeMenuModifier.control);
    if (activator.shift) modifiers.add(NativeMenuModifier.shift);
    if (activator.alt) modifiers.add(NativeMenuModifier.alt);
    if (activator.meta) modifiers.add(NativeMenuModifier.meta); // Command key

    return modifiers;
  }

  /// Converts the icons of the given items to bytes before sending anything.
  Future<void> _processIcons(
    List<(NativeMenuItem, Object)> pendingIcons,
  ) async {
    for (final (menuItem, icon) in pendingIcons) {
      if (icon is IconData) {
        menuItem.iconBytes = await IconConverter.iconToBytes(
          icon,
          size: 54.0,
          color: const Color(0xFF000000),
        );
      } else if (icon is Widget) {
        menuItem.iconBytes = await IconConverter.iconWidgetToBytes(
          icon,
          size: 8.0,
        );
      }
    }
  }

  /// Locks the delegate to a single [context] during debugging to detect
  /// conflicting menu owners.
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

  /// Releases the debug lock previously acquired for [context].
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

  @override
  void menuSelected(int id) {
    final PlatformMenuItem? item = _idMap[id];
    if (item == null) {
      return;
    }

    item.onSelected?.call();
    if (item.onSelectedIntent != null) {
      final BuildContext? context =
          _lockedContext ?? FocusManager.instance.primaryFocus?.context;
      if (context != null) {
        Actions.maybeInvoke(context, item.onSelectedIntent!);
      }
    }
  }

  @override
  void menuOpened(int id) => _idMap[id]?.onOpen?.call();

  @override
  void menuClosed(int id) => _idMap[id]?.onClose?.call();

  /// Queries the native side for the default menus available on the current
  /// platform, returning `null` if the query fails.
  Future<Map<String, String>?> getAvailableDefaultMenus() async {
    try {
      return await _hostApi.getAvailableDefaultMenus();
    } catch (e) {
      return null;
    }
  }
}
