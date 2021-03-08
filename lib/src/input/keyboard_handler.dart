import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:termare_view/src/combining_characters.dart';

typedef KeyboardInput = void Function(String data);

class KeyboardHandler {
  static bool _isdesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  String getKeyEvent(RawKeyEvent message) {
    final RawKeyEvent event = message;
    // shift按下时enable，抬起时enable为false
    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyId) {
        case 0x10007002a:
          return utf8.decode(<int>[127]);
          break;
        case 0x100070028:
          return utf8.decode(<int>[10]);
          break;
        case 0x1000700e7:
          // enableCtrl = true;
          return null;
          break;
        case 0x1000700e1:
          // enableShift = true;
          return null;
          break;
        case 0x100070052:
          // 上 A 112 - 96 80 - 64 ctrl p
          return utf8.decode([27, 91, 65]);
        // return utf8.decode([16]);
        case 0x100070051:
          // 下 B 110 - 96 78 -64 ctrl n
          return utf8.decode([27, 91, 66]);
          return utf8.decode([14]);
        case 0x10007004f:
          // 右 C
          return utf8.decode([27, 91, 67]);
          return utf8.decode([6]);
        case 0x100070050:
          // 左 D
          return utf8.decode([27, 91, 68]);
          return utf8.decode([2]);
        default:
      }
    }

    if (event is RawKeyUpEvent) {
      switch (event.logicalKey.keyId) {
        case 0x1000700e1:
          print('shift 抬起');
          // enableShift = false;
          return null;
          break;
        case 0x1000700e7:
          print('ctrl 抬起');
          // enableCtrl = false;
          return null;
          break;
      }
    }
    return null;
  }
}
