import 'package:flutter/services.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  IPadOSPlatformMenuDelegate.create(channel: const MethodChannel('custom'));
  IPadOSPlatformMenuDelegate.create();
}
