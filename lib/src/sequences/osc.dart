import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:termare_view/src/painter/model/position.dart';
import 'package:termare_view/termare_view.dart';

bool Function(List<int>, List<int>) eq = const ListEquality<int>().equals;

class Osc {
  static String curSeq = '';
  static bool handle(TermareController controller, List<int> utf8CodeUnits) {
    final String currentChar = utf8.decode(utf8CodeUnits);
    if (eq(utf8CodeUnits, [0x07])) {
      print('Osc handle curSeq -> $curSeq');
      // 执行此次序列
      // 执行完清空
      curSeq = '';
      controller.oscStart = false;
      if (controller.verbose) {
        controller.log('$red OSC < Set window title and icon name >');
      }
    } else {
      curSeq += currentChar;
    }
    return true;
  }
}
