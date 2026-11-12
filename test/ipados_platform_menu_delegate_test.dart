import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:ipados_menu_bar/src/messages.g.dart';

class _FakeHostApi extends IpadOSMenuHostApi {
  NativeMenuConfiguration? configuration;
  Map<String, String> availableMenus = {'file': 'File Menu'};
  bool failAvailableMenus = false;

  @override
  Future<void> setMenus(NativeMenuConfiguration configuration) async {
    this.configuration = configuration;
  }

  @override
  Future<Map<String, String>> getAvailableDefaultMenus() async {
    if (failAvailableMenus) throw PlatformException(code: 'error');
    return availableMenus;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeHostApi hostApi;
  late IPadOSPlatformMenuDelegate delegate;

  setUp(() {
    hostApi = _FakeHostApi();
    delegate = IPadOSPlatformMenuDelegate.forTesting(hostApi);
  });

  test('sends custom menus with children, shortcut and state', () async {
    var selected = 0;
    await delegate.setMenus([
      PlatformMenu(
        label: 'Custom',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Run',
                onSelected: () => selected++,
                shortcut: const SingleActivator(
                  LogicalKeyboardKey.keyR,
                  meta: true,
                  shift: true,
                ),
              ),
              PlatformMenuItem(label: 'Disabled'),
            ],
          ),
        ],
      ),
    ]);

    final config = hostApi.configuration!;
    expect(config.defaultMenus, isEmpty);
    final menu = config.customMenus.single;
    expect(menu.label, 'Custom');

    final group = menu.children.single;
    expect(group.isGroup, isTrue);

    final run = group.children.first;
    expect(run.label, 'Run');
    expect(run.enabled, isTrue);
    expect(run.shortcut!.trigger, 'r');
    expect(run.shortcut!.modifiers, [
      NativeMenuModifier.shift,
      NativeMenuModifier.meta,
    ]);
    expect(group.children.last.enabled, isFalse);

    delegate.menuSelected(run.id!);
    expect(selected, 1);
  });

  test('splits default menus from custom ones', () async {
    await delegate.setMenus([
      IPadFileMenu(
        additionalItems: [PlatformMenuItem(label: 'New', onSelected: () {})],
      ),
    ]);

    final config = hostApi.configuration!;
    expect(config.customMenus, isEmpty);
    expect(config.defaultMenus, ['file']);
    expect(config.defaultMenuItems['file']!.single.label, 'New');
  });

  test('maps stateful items and ignores unknown ids', () async {
    await delegate.setMenus([
      PlatformMenu(
        label: 'Custom',
        menus: [
          StatefulPlatformMenuItem(
            label: 'Toggle',
            state: MenuItemState.mixed,
            onSelected: () {},
          ),
        ],
      ),
    ]);

    final item = hostApi.configuration!.customMenus.single.children.single;
    expect(item.state, NativeMenuState.mixed);
    delegate.menuSelected(9999);
    delegate.menuOpened(9999);
    delegate.menuClosed(9999);
  });

  test('getAvailableDefaultMenus returns the native map or null', () async {
    expect(await delegate.getAvailableDefaultMenus(), {'file': 'File Menu'});
    hostApi.failAvailableMenus = true;
    expect(await delegate.getAvailableDefaultMenus(), isNull);
  });
}
