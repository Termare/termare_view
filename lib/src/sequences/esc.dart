import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:termare_view/src/painter/position.dart';
import 'package:termare_view/src/utils/custom_log.dart';
import 'package:termare_view/termare_view.dart';

bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

class Esc {
  static void handle(TermareController controller, List<int> utf8CodeUnits) {
    final String currentChar = utf8.decode(utf8CodeUnits);
    // log('currentChar -> $pink< $currentChar >');
    controller.escapeStart = false;
    if (eq(utf8CodeUnits, [0x5b])) {
      // ascii 91 是字符 -> [，‘esc [’开启了 csi 序列。
      controller.csiStart = true;
    } else if (eq(utf8CodeUnits, [0x5d])) {
      // ascii 93 是字符 -> ]，‘esc ]’开启了 osc 序列。
      Log.i(' oscStart');
      controller.oscStart = true;
    } else if (currentChar == '7') {
      controller.tmpPointer = controller.currentPointer;
      controller.tmpTextAttributes = controller.textAttributes;
      Log.i('< 保存光标以及字符属性 >');
    } else if (currentChar == '8') {
      controller.currentPointer = controller.tmpPointer;
      controller.textAttributes = controller.tmpTextAttributes;
      Log.i('< 恢复光标以及字符属性 >');
    } else if (currentChar == 'D') {
      controller.moveToNextLinePosition();
      Log.i('< ESC Index >');
    } else if (currentChar == 'E') {
      controller.moveToNextLinePosition();
      controller.moveToLineFirstPosition();
      Log.i('< ESC Next Line >');
    } else if (currentChar == 'H') {
      Log.i('< ESC Horizontal Tabulation Set >');
    } else if (currentChar == 'M') {
      controller.moveToRelativeRow(-1);
      Log.i('< ESC Reverse Index >');
    } else if (currentChar == 'P') {
      controller.dcsStart = true;
      Log.i('< ESC Device Control String >');
    } else if (currentChar == '[') {
      controller.csiStart = true;
      Log.i('< ESC Control Sequence Introducer >');
    } else if (currentChar == r'\') {
      Log.i('< ESC String Terminator >');
    } else if (currentChar == ']') {
      Log.i('< ESC Operating System Command >');
    } else if (currentChar == '^') {
      Log.i('< ESC Privacy Message >');
    } else if (currentChar == '_') {
      Log.i('< ESC Application Program Command >');
    } else if (currentChar == 'B') {
      Log.i('< United States (USASCII), VT100. >');
    } else {
      controller.escapeStart = true;
    }
  }
}
