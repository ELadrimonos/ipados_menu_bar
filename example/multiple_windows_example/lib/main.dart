import 'dart:convert';

import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

// Every window (UIScene) runs its own FlutterEngine, so each entrypoint below
// installs its own menu delegate. The plugin shows the menus of the focused
// window and sends menu actions back to that window's engine.

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate =
      IPadOSPlatformMenuDelegate.create();

  runApp(const MyApp());
}

/// Entrypoint of the second kind of window. `args` holds the JSON-encoded
/// `IPadWindowMenu.arguments` of the window that opened it.
@pragma('vm:entry-point')
void secondMain(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate =
      IPadOSPlatformMenuDelegate.create();

  runApp(SecondApp(message: _greetingFrom(args)));
}

/// Entrypoint of a window without any Flutter menu.
@pragma('vm:entry-point')
void thirdMain() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate =
      IPadOSPlatformMenuDelegate.create();

  runApp(const ThirdApp());
}

String? _greetingFrom(List<String> args) {
  if (args.isEmpty) return null;
  try {
    final decoded = jsonDecode(args.first);
    return decoded is Map<String, dynamic>
        ? decoded['greeting'] as String?
        : null;
  } on FormatException {
    return null;
  }
}

class SecondApp extends StatefulWidget {
  final String? message;

  const SecondApp({super.key, this.message});

  @override
  State<SecondApp> createState() => _SecondAppState();
}

class _SecondAppState extends State<SecondApp> {
  String _lastAction = 'none';

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: const CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(start: 64),
          middle: Text('Second Window'),
        ),
        child: PlatformMenuBar(
          menus: [
            PlatformMenu(
              label: 'Pirate',
              menus: [
                PlatformMenuItem(
                  label: 'Yarr',
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyT,
                    meta: true,
                  ),
                  onSelected: () => setState(() => _lastAction = 'Yarr'),
                ),
                PlatformMenuItem(
                  label: 'Walk the plank',
                  onSelected: () =>
                      setState(() => _lastAction = 'Walk the plank'),
                ),
              ],
            ),
          ],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                const Text('This window runs its own engine and menus'),
                Text('Message received: ${widget.message}'),
                Text('Last menu action: $_lastAction'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ThirdApp extends StatelessWidget {
  const ThirdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(start: 64),
          middle: Text('Third Window'),
        ),
        backgroundColor: CupertinoColors.destructiveRed,
        child: Center(child: Text('This window has no Flutter menus')),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool toggledOption = false;
  bool expandedSideBar = false;
  MenuItemState openThirdInsteadOfSecond = MenuItemState.off;
  String _lastAction = 'none';

  MenuItemState _currentTriState = MenuItemState.off;
  IconData _currentTriStateIcon = CupertinoIcons.shield_slash;

  void _report(String action) => setState(() => _lastAction = action);

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
          padding: const EdgeInsetsDirectional.only(start: 64),
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
              onUndo: () => _report('Undo'),
              onRedo: () => _report('Redo'),
            ),
            IPadFileMenu(
              additionalItems: [
                PlatformMenuItemWithIcon(
                  label: 'New File',
                  icon: CupertinoIcons.doc,
                  onSelected: () => _report('New File'),
                ),
              ],
            ),
            IPadAppMenu(
              additionalItems: [
                PlatformMenuItem(
                  label: 'Hello from the app menu',
                  onSelected: () => _report('App menu'),
                ),
              ],
            ),
            // The system "New Window" item opens a window running this
            // entrypoint, see `AppDelegate.swift`.
            IPadWindowMenu(
              entrypoint: openThirdInsteadOfSecond == MenuItemState.on
                  ? 'thirdMain'
                  : 'secondMain',
              arguments: {'greeting': 'You are a Pirate!!'},
            ),
            IPadViewMenu(
              onShowSidebar: () => setState(() {
                expandedSideBar = !expandedSideBar;
              }),
              additionalItems: [
                StatefulPlatformMenuItem(
                  label: 'New window is third scene?',
                  state: openThirdInsteadOfSecond,
                  onSelected: () {
                    setState(() {
                      openThirdInsteadOfSecond =
                          openThirdInsteadOfSecond == MenuItemState.on
                          ? MenuItemState.off
                          : MenuItemState.on;
                    });
                  },
                ),
              ],
            ),
            PlatformMenu(
              label: 'Test Menu',
              menus: [
                PlatformMenuItemWithIcon(
                  icon: CupertinoIcons.plus,
                  label: 'Item 0 (Enabled: $toggledOption)',
                  onSelected: toggledOption ? () => _report('Item 0') : null,
                ),
                PlatformMenuItemGroup(
                  members: [
                    PlatformMenuItem(
                      label: 'Item 1',
                      onSelected: () => _report('Item 1'),
                    ),
                    PlatformMenuItem(
                      label: 'Item 2',
                      onSelected: () => _report('Item 2'),
                    ),
                  ],
                ),
                PlatformMenuItem(
                  label: 'Item 3',
                  onSelected: () => _report('Item 3'),
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
                    _lastAction = 'Toggled: $toggledOption';
                  }),
                  shortcut: const SingleActivator(
                    LogicalKeyboardKey.keyT,
                    meta: true,
                  ),
                ),
                StatefulPlatformMenuItemWithIcon(
                  label: '${_currentTriState.name} state',
                  icon: _currentTriStateIcon,
                  state: _currentTriState,
                  onSelected: _toggleTriStateAction,
                ),
                if (toggledOption)
                  PlatformMenuWithIcon(
                    icon: CupertinoIcons.ellipses_bubble,
                    label: 'Unlocked Secrets',
                    menus: [
                      PlatformMenuItem(
                        label: 'Secret item',
                        onSelected: () => _report('Secret item'),
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
                    children: [
                      const Text(
                        'Swipe down from the top of the screen to see the '
                        'menu bar. Open more windows from Window > New Window.',
                      ),
                      Text('Last menu action: $_lastAction'),
                      const SizedBox(
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
