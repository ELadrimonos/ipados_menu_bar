import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IpadOSPlatformMenuDelegate();
  debugPrint(
    "Platform menu delegate set: ${WidgetsBinding.instance.platformMenuDelegate}",
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late IpadOSPlatformMenuDelegate _menuDelegate;
  bool toggledOption = false;

  @override
  void initState() {
    super.initState();
    _menuDelegate =
        WidgetsBinding.instance.platformMenuDelegate
            as IpadOSPlatformMenuDelegate;
    _configureDefaultMenus();
  }

  Future<void> _configureDefaultMenus() async {
    // Deprecated method, start working with the new widgets
    /*
    await _menuDelegate.configureDefaultMenus({
            'file': {
        'additionalItems': [
          {'id': 100, 'label': 'Mi Nuevo Archivo', 'enabled': true},
          {'id': 101, 'label': 'Mi Abrir Especial', 'enabled': true},
        ],
      },
      'edit': {
        'additionalItems': [
          {'id': 102, 'label': 'Mi Función Personalizada', 'enabled': true},
        ],
      },
      'hidden': [],
    });
    */
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Text('iPadOS 26+ menu bar plugin example app'),
        ),
        child: PlatformMenuBar(
          menus: [
            IPadEditMenu(
              onUndo: () => debugPrint('Undo action!'),
              onRedo: () => debugPrint('Redo action!'),
            ),
            IPadFileMenu(),
            IPadWindowMenu(),
            IPadViewMenu(),
            IPadFormatMenu(),
            PlatformMenu(
              label: 'Test Menu',
              menus: [
                PlatformMenuItemWithIcon(
                  icon: CupertinoIcons.plus,
                  label: 'Item 0 (Enabled: $toggledOption)',
                  onSelected: toggledOption
                      ? () => debugPrint("Item 0 selected")
                      : null,
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Item 1',
                      onSelected: () => debugPrint("Item 1 selected"),
                    ),
                    PlatformMenuItem(
                      label: 'Item 2',
                      onSelected: () => debugPrint("Item 2 selected"),
                    ),
                  ],
                ),

                // NOTE Item 3 is nested in the same group scope as item 0, so it
                // will have a leading padding because item 0 has an icon.
                // To counter this behavior, use PlatformMenuItemGroup for each
                // section.
                PlatformMenuItem(
                  label: 'Item 3',
                  onSelected: () => debugPrint("Item 3 selected"),
                ),

                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Item 4',
                      onSelected: () => debugPrint("Item 4 selected"),
                    ),
                    PlatformMenuItem(
                      label: 'Item 5',
                      onSelected: () => debugPrint("Item 5 selected"),
                    ),
                  ],
                ),
              ],
            ),
            PlatformMenu(
              label: 'Another Test Menu',
              menus: [
                PlatformMenuItemWithIcon(
                  icon: toggledOption
                      ? CupertinoIcons.checkmark_alt
                      : CupertinoIcons.xmark,
                  label: 'Toggled: $toggledOption',
                  onSelected: () => setState(() {
                    toggledOption = !toggledOption;
                  }),
                ),
                if (toggledOption)
                  PlatformMenuWithIcon(
                    icon: CupertinoIcons.ellipses_bubble,
                    label: "Unlocked Secrets",
                    menus: [
                      PlatformMenuItem(
                        label: 'Secret item',
                        onSelected: () => debugPrint("Secret selected"),
                      ),
                      PlatformMenuItem(
                        label: 'Button that gives you 1M dollars',
                      ),
                    ],
                  ),
              ],
            ),
          ],
          child: Center(
            child: Text(
              "Swipe down from the top of the screen to see the magic happen",
            ),
          ),
        ),
      ),
    );
  }
}
