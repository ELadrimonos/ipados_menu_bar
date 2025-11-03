import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_menubar/main.dart';
import 'package:test_menubar/menu_bar_screen_2.dart';
import 'package:test_menubar/menu_provider.dart';

class NoMenuBarScreen extends StatefulWidget {
  const NoMenuBarScreen({super.key});

  @override
  State<NoMenuBarScreen> createState() => _NoMenuBarScreenState();
}

class _NoMenuBarScreenState extends State<NoMenuBarScreen> with RouteAware {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() {
    // Esta pantalla acaba de ser pushed
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didPopNext() {
    // Volvimos a esta pantalla desde otra
    _isActive = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateMenus());
  }

  @override
  void didPushNext() {
    // Se ha navegado a otra pantalla desde esta
    _isActive = false;
  }

  @override
  void didPop() {
    // Esta pantalla está siendo removida
    _isActive = false;
  }

  void _updateMenus() {
    if (!_isActive && mounted) {
      // Solo actualizar si esta pantalla está activa
      return;
    }

    if (!mounted) return;

    final menuProvider = Provider.of<MenuProvider>(context, listen: false);
    menuProvider.setMenus([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Screen Without Menu Bar'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MenuBarScreen2(title: 'Screen With Menu Bar 2')),
            );
          },
          child: const Text('Go to Screen With Menu Bar 2'),
        ),
      ),
    );
  }
}