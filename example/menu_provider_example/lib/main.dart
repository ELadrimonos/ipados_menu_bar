import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';
import 'package:provider/provider.dart';
import 'package:test_menubar/menu_bar_screen.dart';
import 'package:test_menubar/menu_provider.dart';

final routeObserver = RouteObserver<ModalRoute<void>>();

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate.create();
  runApp(
    ChangeNotifierProvider(
      create: (context) => MenuProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformMenuBar(
      menus: context.watch<MenuProvider>().currentMenus,
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        home: const MenuBarScreen(title: 'Screen With Menu Bar'),
      ),
    );
  }
}
