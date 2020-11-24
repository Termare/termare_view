import 'dart:convert';

import 'package:termare/src/termare_controller.dart';

class SequencesTest {
  static Future<void> testChinese(TermareController controller) async {
    controller.write('${'啊' * 17}\x08\x08 \n');
  }

  static Future<void> testColorText(TermareController controller) async {
    controller.write('\x1B[1;31m Text\x1B[0m\n');
  }

  static Future<void> testMang(TermareController controller) async {
    List<String> list = ['⣿', '⣷', '⣯', '⣟', '⡿', '⣿', '⢿', '⣻', '⣽', '⣾'];
    for (String str in list) {
      controller.write('$str\b');
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  static Future<void> testIsOut(TermareController controller) async {
    controller.write('\n');
    for (int i = 0; i < 5500; i++) {
      controller.write('${'${i % 10}' * 40}\n');
      controller.autoScroll = true;
      controller.dirty = true;
      controller.notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    controller.write('${'b' * 40}\n');
    controller.write('${'c' * 40}\n');
  }

  static void testC0(TermareController controller) {
    controller.write('\n');
    controller.write('bell test\x07\n');
    controller.write('Backspace Teaa\x08\x08st\n');
    controller.write('Horizontal\x09Tabulation\n');
    // 因为\x0a转换成string就是\n，所以不会被序列单独检测到
    controller.write('Line Feed\x0a\n');
    controller.write('Line Feed\x0b\n');
    controller.write('Line Feed\x0c\n');
    controller.write('${'a' * 47}\x0dbbb\n');
    // controller.write() 'Last login: Fri Nov 20 08:16:19 on console 啊';
    controller.write(utf8.decode([
      27,
      91,
      48,
      49,
      59,
      51,
      52,
      109,
      97,
      99,
      99,
      116,
      27,
      91,
      48,
      109,
    ]));
  }
}
