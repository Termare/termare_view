import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:termare/termare.dart';

void main() {
  const MethodChannel channel = MethodChannel('termare');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    // expect(await Termare.platformVersion, '42');
  });
}
