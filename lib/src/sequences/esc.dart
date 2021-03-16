import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/termare_view.dart';

bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

class Esc {
  static bool handle(TermareController controller, List<int> utf8CodeUnits) {
    final String currentChar = utf8.decode(utf8CodeUnits);
    // log('currentChar -> $pink< $currentChar >');
    controller.escapeStart = false;
    if (eq(utf8CodeUnits, [0x5b])) {
      // ascii 91 是字符 -> [，‘esc [’开启了 csi 序列。
      controller.csiStart = true;
    } else if (eq(utf8CodeUnits, [0x5d])) {
      // ascii 93 是字符 -> ]，‘esc ]’开启了 osc 序列。
      controller.log('$red oscStart');
      controller.oscStart = true;
    } else if (currentChar == '7') {
      controller.tmpPointer = controller.currentPointer;
      controller.tmpTextAttributes = controller.textAttributes;
      controller.log(' -> $green< 保存光标以及字符属性 >');
    } else if (currentChar == '8') {
      controller.currentPointer = controller.tmpPointer;
      controller.textAttributes = controller.tmpTextAttributes;
      controller.log(' -> $green< 恢复光标以及字符属性 >');
    } else if (currentChar == 'D') {
      controller.moveToNextLinePosition();
      controller.log('$green < ESC Index >');
    } else if (currentChar == 'E') {
      controller.moveToNextLinePosition();
      controller.moveToLineFirstPosition();
      controller.log('$green < ESC Next Line >');
    } else if (currentChar == 'H') {
      controller.log('$green < ESC Horizontal Tabulation Set >');
    } else if (currentChar == 'M') {
      controller.moveToRelativeRow(-1);
      controller.log('$green < ESC Reverse Index >');
    } else if (currentChar == 'P') {
      controller.dcsStart = true;
      controller.log('$green < ESC Device Control String >');
    } else if (currentChar == '[') {
      controller.csiStart = true;
      controller.log('$green < ESC Control Sequence Introducer >');
    } else if (currentChar == r'\') {
      controller.log('$green < ESC String Terminator >');
    } else if (currentChar == ']') {
      controller.log('$green < ESC Operating System Command >');
    } else if (currentChar == '^') {
      controller.log('$green < ESC Privacy Message >');
    } else if (currentChar == '_') {
      controller.log('$green < ESC Application Program Command >');
    }
  }
}
