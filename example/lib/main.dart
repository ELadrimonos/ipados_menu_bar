import 'package:cupertino_sidebar/cupertino_sidebar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate();

  runApp(MyApp());
}

@pragma('vm:entry-point')
void secondMain() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate();
  runApp(SecondApp());
}

@pragma('vm:entry-point')
void thirdMain() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate();
  runApp(ThirdApp());
}

class SecondApp extends StatelessWidget {
  const SecondApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(start: 64),
          middle: const Text('Second Window'),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Esta es una instancia separada'),
              SizedBox(height: 20),
            ],
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
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          padding: EdgeInsetsDirectional.only(start: 64),
          middle: const Text('Third Window'),
        ),
        backgroundColor: CupertinoColors.destructiveRed,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('This is a different window'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  bool toggledOption = false;
  bool expandedSideBar = false;
  MenuItemState openThirdInsteadOfSecond = MenuItemState.off;

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
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    debugPrint("Main scene STATE: $state");

    if (state == AppLifecycleState.resumed) {
      debugPrint("Main scene HAS RESUMIDO!!");
      // CAMBIO: Forzar rebuild de menús al resumir
      setState(() {
        // Trigger rebuild que enviará los menús actualizados
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      home: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
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
              entrypoint: openThirdInsteadOfSecond == MenuItemState.on
                  ? 'thirdMain'
                  : 'secondMain',
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
                      switch (openThirdInsteadOfSecond) {
                        case MenuItemState.on:
                          openThirdInsteadOfSecond = MenuItemState.off;
                          break;
                        default:
                          openThirdInsteadOfSecond = MenuItemState.on;
                          break;
                      }
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
                      /*
                      Text(
                        "Active scene: ${_menuDelegate.activeSceneId ?? 'none'}",
                        style: CupertinoTheme.of(context).textTheme.tabLabelTextStyle,
                      ),

                       */
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
