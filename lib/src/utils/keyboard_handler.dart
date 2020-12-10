import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare/src/combining_characters.dart';

typedef KeyboardInput = void Function(String data);

class KeyboardHandler {
  KeyboardHandler(this.keyboardInput);
  final KeyboardInput keyboardInput;
  bool enableShift = false;
  Future<dynamic> handleKeyEvent(RawKeyEvent message) async {
    final RawKeyEvent event = message;
    // print('event->$event');
    // TODO
    // shift按下时enable，抬起时enable为false

    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyId) {
        case 0x10007002a:
          // print('删除');
          keyboardInput?.call(utf8.decode(<int>[127]));
          return;
          break;
        case 0x100070028:
          keyboardInput?.call(utf8.decode(<int>[10]));
          return;
          break;
        case 0x1000700e1:
          print('shift 抬起');
          enableShift = true;
          return;
          break;
        case 0x100070050:
          // 左
          keyboardInput?.call(utf8.decode(<int>[2]));
          return;
        case 0x10007004f:
          // 右
          keyboardInput?.call(utf8.decode(<int>[6]));
          return;
        default:
      }
      if (enableShift) {
        print('当前shift已被按下');
        // 这儿在安卓与pc上不一样，安卓上是虚拟键盘，pc上是物理键盘
        if (PlatformUtil.isDesktop()) {
          keyboardInput?.call(utf8.decode(<int>[event.logicalKey.keyId]));
        } else {
          keyboardInput?.call(
            ShiftCombining.getCombiningChar(
              utf8.decode(
                [event.logicalKey.keyId],
              ),
            ),
          );
          // 玄学，勿动
          enableShift = false;
        }
      } else {
        if (event.logicalKey.keyId == 0x10200000004) {
          // 安卓的返回键
          print('安卓的返回键');
          return;
        }
        // print(event.logicalKey);
        print('event.logicalKey.keyId -> ${event.logicalKey.keyId}');
        keyboardInput?.call(utf8.decode([event.logicalKey.keyId]));
        // print(utf8.decode([event.logicalKey.keyId]));
      }
    }

    if (event is RawKeyUpEvent) {
      switch (event.logicalKey.keyId) {
        case 0x1000700e1:
          print('shift 抬起');
          enableShift = false;
          return;
          break;
      }
    }
  }
}
