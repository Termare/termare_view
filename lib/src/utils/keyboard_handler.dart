import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:termare/src/combining_characters.dart';
import 'package:termare/termare.dart';

class KeyboardHandler {
  final TermareController controller;
  bool enableShift = false;
  KeyboardHandler(this.controller);
  Future<dynamic> handleKeyEvent(dynamic message) async {
    final RawKeyEvent event =
        RawKeyEvent.fromMessage(message as Map<String, dynamic>);
    print('event.logicalKey.debugName->${event.logicalKey.debugName}');
    print('event->$event');

    if (event is RawKeyDownEvent) {
      switch (event.logicalKey.keyId) {
        case 0x10007002a:
          controller.write(utf8.decode(<int>[127]));
          return;
          break;
        case 0x100070028:
          controller.write(utf8.decode(<int>[10]));
          return;
          break;
        case 0x1000700e1:
          enableShift = true;
          return;
          break;
        case 0x100070050:
          // 左
          controller.write(utf8.decode(<int>[2]));
          return;
        case 0x10007004f:
          // 右
          controller.write(utf8.decode(<int>[6]));
          return;
        default:
      }
      if (enableShift) {
        controller.write(
          ShiftCombining.getCombiningChar(
            utf8.decode(
              [event.logicalKey.keyId],
            ),
          ),
        );
        enableShift = false;
      } else {
        print(event.logicalKey);
        controller.write(utf8.decode([event.logicalKey.keyId]));
        print(utf8.decode([event.logicalKey.keyId]));
      }
    }
    // if (event is RawKeyUpEvent) {
    //   print(event.data.keyLabel);
    // }
  }
}
