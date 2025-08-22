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
      'hidden': ['format', 'file', 'edit'],
    });
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
            PlatformMenu(
              label: 'Test Menu',
              menus: [
                //TODO Hacer divider tras el group (y antes si hay algun otro item delante)
                PlatformMenuItemGroup(members: [
                  PlatformMenuItem(
                    label: 'Item 1',
                    onSelected: () => debugPrint("Item 1 selected"),
                  ),
                ]),
                PlatformMenuItem(
                  label: 'Item 2',
                  onSelected: () => debugPrint("Item 2 selected"),
                ),
              ],
            ),
            PlatformMenu(
              label: 'Another Test Menu',
              menus: [
                PlatformMenuItem(
                  label: 'Toggled: $toggledOption',
                  onSelected: () => setState(() {
                    toggledOption = !toggledOption;
                  }),
                ),
                if (toggledOption)
                  PlatformMenu(
                    label: "Unlocked Secrets",
                    menus: [
                      PlatformMenuItem(
                        label: 'Secret item',
                        onSelected: () => debugPrint("Secret selected"),
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
