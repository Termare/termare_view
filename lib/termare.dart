import 'dart:async';

import 'package:flutter/services.dart';

export 'src/termare_view.dart';
export 'src/termare_controller.dart';

class Termare {
  static const MethodChannel _channel = const MethodChannel('termare');

  // static Future<String> get platformVersion async {
  //   final String version = await _channel.invokeMethod('getPlatformVersion');
  //   return version;
  // }
}
