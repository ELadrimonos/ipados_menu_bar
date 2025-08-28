import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate();
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
  late IPadOSPlatformMenuDelegate _menuDelegate;
  bool toggledOption = false;
  bool expandedSideBar = false;

  @override
  void initState() {
    super.initState();
    _menuDelegate =
        WidgetsBinding.instance.platformMenuDelegate
            as IPadOSPlatformMenuDelegate;
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
          leading: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              setState(() {
                expandedSideBar = !expandedSideBar;
              });
            },
            child: const Icon(CupertinoIcons.sidebar_left),
          ),
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
            IPadViewMenu(
              onShowSidebar: () => setState(() {
                expandedSideBar = !expandedSideBar;
              }),
            ),
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
                // TODO Add stateful item using UIMenuElement.State
                PlatformMenuItemWithIcon(
                  icon: toggledOption
                      ? CupertinoIcons.checkmark_alt
                      : CupertinoIcons.xmark,
                  label: 'Toggled: $toggledOption',
                  onSelected: () => setState(() {
                    toggledOption = !toggledOption;
                  }),
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyT,
                    meta: true,
                  ),
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
          child: Row(
            children: [
              CupertinoSidebarCollapsible(
                isExpanded: expandedSideBar,
                child: Container(color: CupertinoColors.activeBlue, width: 300),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    spacing: 32,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(
                        "Swipe down from the top of the screen to see the magic happen",
                      ),
                      SizedBox(
                        width: 200,
                        height: 36,
                        child: CupertinoTextField(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
