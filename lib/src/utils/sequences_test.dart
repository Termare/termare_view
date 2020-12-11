import 'dart:convert';

import 'package:termare_view/src/termare_controller.dart';

class SequencesTest {
  static Future<void> testChinese(TermareController controller) async {
    controller.write('${'啊' * 17}\x08\x08 \n');
  }

  static Future<void> testColorText(TermareController controller) async {
    controller.write('\x1B[1;31m Text\x1B[0m\n');
  }

  static Future<void> testMang(TermareController controller) async {
    final List<String> list = [
      '⣿',
      '⣷',
      '⣯',
      '⣟',
      '⡿',
      '⣿',
      '⢿',
      '⣻',
      '⣽',
      '⣾'
    ];
    for (final String str in list) {
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
      await Future<void>.delayed(const Duration(milliseconds: 500));
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
  }
}
