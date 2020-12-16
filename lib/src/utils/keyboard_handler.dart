import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:termare_view/src/combining_characters.dart';

typedef KeyboardInput = void Function(String data);

class KeyboardHandler {
  bool enableShift = false;
  static bool _isdesktop() {
    return Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  }

  String getKeyEvent(RawKeyEvent message) {
    final RawKeyEvent event = message;
    print('event->$event');
    // TODO
    // shift按下时enable，抬起时enable为false

    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyId) {
        case 0x10007002a:
          // print('删除');
          return utf8.decode(<int>[127]);
          break;
        case 0x100070028:
          return utf8.decode(<int>[10]);
          break;
        case 0x1000700e1:
          print('shift 抬起');
          enableShift = true;
          return null;
          break;
        case 0x100070050:
          // 左
          return utf8.decode(<int>[2]);
        case 0x10007004f:
          // 右
          return utf8.decode(<int>[6]);
        default:
      }
      if (enableShift) {
        print('当前shift已被按下');
        // 这儿在安卓与pc上不一样，安卓上是虚拟键盘，pc上是物理键盘
        if (_isdesktop()) {
          return utf8.decode(<int>[event.logicalKey.keyId]);
        } else {
          // 玄学，勿动
          enableShift = false;
          return ShiftCombining.getCombiningChar(
            utf8.decode(
              [event.logicalKey.keyId],
            ),
          );
        }
      } else {
        if (event.logicalKey.keyId == 0x10200000004) {
          // 安卓的返回键
          print('安卓的返回键');
          return null;
        }
        if (event.logicalKey.keyId == 0x100070052) {
          print('安卓的上键');
          return utf8.decode([112 - 96]);
        }
        if (event.logicalKey.keyId == 0x100070051) {
          print('安卓的上键');
          return utf8.decode([110 - 96]);
        }
        // print(event.logicalKey);
        // print('event.logicalKey.keyId -> ${event.logicalKey.keyId}');

        return utf8.decode(<int>[event.logicalKey.keyId]);
        // print(utf8.decode([event.logicalKey.keyId]));
      }
    }

    if (event is RawKeyUpEvent) {
      switch (event.logicalKey.keyId) {
        case 0x1000700e1:
          print('shift 抬起');
          enableShift = false;
          return null;
          break;
      }
    }
    return null;
  }
}
