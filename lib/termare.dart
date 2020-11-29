import 'dart:async';

import 'package:flutter/services.dart';

export 'src/termare_pty.dart';
export 'src/termare_controller.dart';
export 'src/termare_view.dart';
export 'src/theme/term_theme.dart';

class Termare {
  // File().
  static const MethodChannel _channel = const MethodChannel('termare');

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }
}
