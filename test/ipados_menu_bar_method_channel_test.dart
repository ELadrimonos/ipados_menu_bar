import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ipados_menu_bar/ipados_platform_menu_delegate.dart';

// TODO Update tests as to not use the default template tests
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('ipados_menu');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
          return '42';
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  /* test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });*/
}
