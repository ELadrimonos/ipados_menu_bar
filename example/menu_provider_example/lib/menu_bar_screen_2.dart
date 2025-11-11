import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:test_menubar/main.dart';
import 'package:test_menubar/menu_provider.dart';

class MenuBarScreen2 extends StatefulWidget {
  const MenuBarScreen2({super.key, required this.title});

  final String title;

  @override
  State<MenuBarScreen2> createState() => _MenuBarScreen2State();
}

class _MenuBarScreen2State extends State<MenuBarScreen2> with RouteAware {
  bool _isActive = false; // 👈 NUEVO: Flag para rastrear si está activa

  @override
  void initState() {
    super.initState();
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
    // 👇 NUEVO: Solo actualizar si la pantalla está activa
    if (!_isActive && mounted) {
      return;
    }

    if (!mounted) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.setMenus([
      IPadAppMenu(additionalItems: [PlatformMenuItem(label: 'New Menu Item')]),
      IPadEditMenu(),
      PlatformMenuWithIcon(
        iconWidget: FlutterLogo(),
        label: 'Another Custom Menu',
        menus: [
          PlatformMenuItemWithIcon(
            iconWidget: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withAlpha(80),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 20,
              ),
            ),
            label: 'Magic Menu',
            onSelected: () {},
          ),
        ],
      ),
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
          spacing: 16,
          children: <Widget>[
            SizedBox(
              width: 200,
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Try Dictation Here",
                ),
              ),
            ),
            const Text('This is the second screen with a menu bar.'),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Go back to Screen Without Menu Bar'),
            ),
          ],
        ),
      ),
    );
  }
}
