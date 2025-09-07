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

  MenuItemState _currentTriState = MenuItemState.off;
  IconData _currentTriStateIcon = CupertinoIcons.shield_slash;

  void _toggleTriStateAction() {
    setState(() {
      if (_currentTriState == MenuItemState.off) {
        _currentTriState = MenuItemState.on;
        _currentTriStateIcon = CupertinoIcons.shield_fill;
      } else if (_currentTriState == MenuItemState.on) {
        _currentTriState = MenuItemState.mixed;
        _currentTriStateIcon = CupertinoIcons.shield_lefthalf_fill;
      } else {
        _currentTriState = MenuItemState.off;
        _currentTriStateIcon = CupertinoIcons.shield_slash;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // CupertinoNavigationBar should have a left padding of 64 to give
          // space for items when theres windows controls present on the app
          padding: EdgeInsetsDirectional.only(start: 64),
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
            IPadFileMenu(
              additionalItems: [
                PlatformMenuItemWithIcon(
                  label: 'New File',
                  icon: CupertinoIcons.doc,
                ),
              ],
            ),
            IPadWindowMenu(
              onNewWindow: () => debugPrint("ABOUT TO CREATE NEW WINDOW!"),
              onShowAllWindows: () => debugPrint("ABOUT TO SHOW ALL WINDOWS!")
            ),
            IPadViewMenu(
              onShowSidebar: () => setState(() {
                expandedSideBar = !expandedSideBar;
              }),
            ),
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
            IPadFormatMenu(),
            PlatformMenu(
              label: 'Another Test Menu',
              menus: [
                StatefulPlatformMenuItem(
                  state: toggledOption ? MenuItemState.on : MenuItemState.off,
                  label: 'Toggled: $toggledOption',
                  onSelected: () => setState(() {
                    toggledOption = !toggledOption;
                  }),
                  shortcut: SingleActivator(
                    LogicalKeyboardKey.keyT,
                    meta: true,
                  ),
                ),
                StatefulPlatformMenuItemWithIcon(
                  label: "${_currentTriState.name} state",
                  icon: _currentTriStateIcon,
                  state: _currentTriState,
                  onSelected: _toggleTriStateAction,
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
