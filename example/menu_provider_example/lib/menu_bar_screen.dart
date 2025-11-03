import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:test_menubar/main.dart';
import 'package:test_menubar/no_menu_bar_screen.dart';
import 'package:test_menubar/menu_provider.dart';

class MenuBarScreen extends StatefulWidget {
  const MenuBarScreen({super.key, required this.title});

  final String title;

  @override
  State<MenuBarScreen> createState() => _MenuBarScreenState();
}

enum ActionType {
  none,
  increment,
  decrement
}

class _MenuBarScreenState extends State<MenuBarScreen> with RouteAware {
  int _counter = 0;
  bool _isActive = false;
  ActionType _lastAction = ActionType.none;


  @override
  void initState() {
    super.initState();
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didPopNext() {
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didPushNext() {
    _isActive = false;
  }

  @override
  void didPop() {
    _isActive = false;
  }

  void _updateMenus() {
    if (!_isActive && mounted) {
      return;
    }

    if (!mounted) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.setMenus([
      IPadAppMenu(
      ),
      IPadFileMenu(),
      IPadEditMenu(
          onUndo: _lastAction == ActionType.none ? null : () {
            setState(() {
              if (_lastAction == ActionType.increment) {
                  _counter--;
              } else {
                _counter++;
              }
              _lastAction = ActionType.none;
            });
            _updateMenus();
          },
      ),
      IPadFormatMenu(),
      PlatformMenu(
        label: 'Write',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Increment Counter',
                onSelected: () {
                  setState(() {
                    _counter++;
                    _lastAction = ActionType.increment;
                  });
                  _updateMenus();
                },
              ),
              PlatformMenuItem(
                label: 'Decrement Counter',
                onSelected: () {
                  setState(() {
                    _counter--;
                    _lastAction = ActionType.decrement;
                  });
                  _updateMenus();
                },
              ),
            ],
          ),
        ],
      ),
      PlatformMenu(
        label: 'Read',
        menus: [
          PlatformMenuItemGroup(
            members: [
              PlatformMenuItem(
                label: 'Print counter value',
                onSelected: () {
                  print("Current value: ${_counter}");
                },
              )
            ],
          ),
        ],
      ),
      IPadViewMenu(),
      IPadWindowMenu(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NoMenuBarScreen()),
                );
              },
              child: const Text('Go to Screen Without Menu Bar'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _counter++;
            _lastAction = ActionType.increment;
          });
          _updateMenus();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}